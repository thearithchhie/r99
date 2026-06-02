import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart' as bluetooth_image;
import 'package:image/image.dart' as img;
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

class IOSBluetoothImagePrinterService {
  IOSBluetoothImagePrinterService._();

  static final Map<String, bluetooth_image.BluetoothDevice> _knownDevices = {};
  static String? _connectedAddress;

  static bool get isAvailable => Platform.isIOS;

  static bool isDevice(PrinterDevice? device) {
    return isAvailable && device is BlePrinterDevice && _knownDevices.containsKey(device.deviceId);
  }

  static Future<List<BlePrinterDevice>> scanDevices({
    Duration firstResultWindow = const Duration(milliseconds: 800),
    Duration timeout = const Duration(seconds: 4),
    void Function(List<BlePrinterDevice> devices)? onDevicesChanged,
  }) async {
    final foundDevices = <String, bluetooth_image.BluetoothDevice>{};
    final firstResult = Completer<void>();

    void publishDevices() {
      final printerDevices = _mapDevices(foundDevices.values);
      onDevicesChanged?.call(printerDevices);
    }

    final subscription = bluetooth_image.FlutterBluetoothPrinter.discovery.listen((state) {
      if (state is bluetooth_image.DiscoveryResult) {
        for (final device in state.devices) {
          foundDevices[device.address] = device;
        }
        publishDevices();
        if (foundDevices.isNotEmpty && !firstResult.isCompleted) {
          firstResult.complete();
        }
      } else if (state is bluetooth_image.BluetoothDevice) {
        foundDevices[state.address] = state;
        publishDevices();
        if (!firstResult.isCompleted) {
          firstResult.complete();
        }
      }
    });

    try {
      await Future.any([
        firstResult.future.then((_) => Future<void>.delayed(firstResultWindow)),
        Future<void>.delayed(timeout),
      ]);
    } finally {
      await subscription.cancel().timeout(const Duration(milliseconds: 500), onTimeout: () {});
    }

    _knownDevices
      ..clear()
      ..addAll(foundDevices);

    final printerDevices = _mapDevices(foundDevices.values);
    onDevicesChanged?.call(printerDevices);
    return printerDevices;
  }

  static List<BlePrinterDevice> _mapDevices(Iterable<bluetooth_image.BluetoothDevice> devices) {
    return devices.map((device) {
      final name = device.name?.trim();
      return BlePrinterDevice(name: name == null || name.isEmpty ? device.address : name, deviceId: device.address);
    }).toList();
  }

  static Future<void> connect(BlePrinterDevice device) async {
    final connected = await bluetooth_image.FlutterBluetoothPrinter.connect(device.deviceId);
    if (!connected) {
      throw Exception('Printer did not accept the iOS image Bluetooth connection');
    }
    _connectedAddress = device.deviceId;
  }

  static Future<void> disconnect(BlePrinterDevice device) async {
    await bluetooth_image.FlutterBluetoothPrinter.disconnect(device.deviceId);
    if (_connectedAddress == device.deviceId) {
      _connectedAddress = null;
    }
  }

  static Future<void> printImageBytes(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Unable to decode iOS label image');
    }

    await printImage(imageBytes: imageBytes, imageWidth: decoded.width, imageHeight: decoded.height);
  }

  static Future<void> printImage({
    required Uint8List imageBytes,
    required int imageWidth,
    required int imageHeight,
  }) async {
    final device = _connectedDevice;
    if (device == null) {
      throw Exception('iOS image printer is disconnected');
    }

    final printed = await bluetooth_image.FlutterBluetoothPrinter.printImageSingle(
      address: device.address,
      imageBytes: imageBytes,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      keepConnected: true,
      maxBufferSize: 128,
      delayTime: 160,
      useImageRaster: false,
      addFeeds: 3,
    );

    if (!printed) {
      throw Exception('iOS image printer rejected the label image');
    }
  }

  static bluetooth_image.BluetoothDevice? get _connectedDevice {
    final address = _connectedAddress;
    return address == null ? null : _knownDevices[address];
  }
}
