import 'dart:async';
import 'dart:typed_data' show Uint8List;

import 'package:usb_serial/usb_serial.dart';

import '../../core/commands.dart';
import '../../exceptions/printer_exception.dart';
import '../../models/printer_connection_state.dart';
import '../../models/printer_device.dart';
import 'usb_connector_interface.dart';

/// USB connector for Android using the `usb_serial` plugin.
///
/// Scans for connected USB serial devices via [UsbSerial.listDevices].
/// Requests USB permission before opening the port, then configures it for
/// 115200 baud 8N1 communication (standard for ESC/POS USB printers).
class UsbConnectorImpl extends UsbConnectorBase {
  UsbPort? _port;

  PrinterConnectionState _state = PrinterConnectionState.disconnected;
  final StreamController<PrinterConnectionState> _stateController =
      StreamController<PrinterConnectionState>.broadcast();

  @override
  Stream<PrinterConnectionState> get stateStream => _stateController.stream;

  @override
  PrinterConnectionState get state => _state;

  @override
  Stream<List<UsbPrinterDevice>> scan({
    Duration timeout = const Duration(seconds: 5),
  }) async* {
    _setState(PrinterConnectionState.scanning);
    final List<UsbDevice> devices = await UsbSerial.listDevices();
    _setState(PrinterConnectionState.disconnected);

    if (devices.isNotEmpty) {
      yield devices
          .map((d) => UsbPrinterDevice(
                name: d.productName ?? 'USB Device ${d.vid}:${d.pid}',
                identifier: '${d.vid}:${d.pid}',
                usbPlatform: UsbPlatform.android,
              ))
          .toList();
    }
  }

  @override
  Future<void> stopScan() async {
    if (_state == PrinterConnectionState.scanning) {
      _setState(PrinterConnectionState.disconnected);
    }
  }

  @override
  Future<void> connect(
    UsbPrinterDevice device, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _assertState(PrinterConnectionState.disconnected, 'connect');
    _setState(PrinterConnectionState.connecting);

    // Find the matching USB device.
    final List<UsbDevice> devices = await UsbSerial.listDevices();
    UsbDevice? found;
    for (final UsbDevice d in devices) {
      if ('${d.vid}:${d.pid}' == device.identifier) {
        found = d;
        break;
      }
    }

    if (found == null) {
      _setState(PrinterConnectionState.error);
      _setState(PrinterConnectionState.disconnected);
      throw PrinterNotFoundException(
        'USB device ${device.identifier} not found',
      );
    }

    UsbPort? port;
    try {
      port = await found.create();
      if (port == null) throw Exception('Could not create UsbPort');

      final bool opened = await port.open();
      if (!opened) throw Exception('UsbPort.open() returned false');

      await port.setDTR(true);
      await port.setRTS(true);
      port.setPortParameters(
        kDefaultBaudRate,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      // Send ESC @ to initialise the printer.
      await port.write(Uint8List.fromList(cInit.codeUnits));

      _port = port;
      _setState(PrinterConnectionState.connected);
    } catch (e) {
      await port?.close();
      _setState(PrinterConnectionState.error);
      _setState(PrinterConnectionState.disconnected);
      throw PrinterConnectionException(
        'Failed to open USB device ${device.identifier}',
        cause: e,
      );
    }
  }

  @override
  Future<void> writeBytes(List<int> bytes) async {
    _assertState(PrinterConnectionState.connected, 'writeBytes');
    _setState(PrinterConnectionState.printing);
    try {
      await _port!.write(Uint8List.fromList(bytes));
      _setState(PrinterConnectionState.connected);
    } catch (e) {
      _setState(PrinterConnectionState.error);
      _setState(PrinterConnectionState.disconnected);
      throw PrinterWriteException('USB write failed', cause: e);
    }
  }

  @override
  Future<void> disconnect() async {
    if (_state == PrinterConnectionState.disconnected) return;
    _setState(PrinterConnectionState.disconnecting);
    try {
      await _port?.close();
    } finally {
      _port = null;
      _setState(PrinterConnectionState.disconnected);
    }
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _stateController.close();
  }

  void _setState(PrinterConnectionState next) {
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  void _assertState(PrinterConnectionState required, String operation) {
    if (_state != required) {
      throw PrinterStateException(
        'Cannot $operation: expected $required but was $_state',
        currentState: _state,
        requiredState: required,
      );
    }
  }
}
