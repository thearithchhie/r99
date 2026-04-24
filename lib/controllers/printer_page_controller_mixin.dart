import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:r99/core/helper/permissions/permission_wrapper.dart';
import 'package:r99/print_template_data.dart';
import 'package:r99/printer_page.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

mixin PrinterPageControllerMixin on State<PrinterPage> {
  final PrinterManager manager = PrinterManager();
  final PermissionWrapper permissionWrapper = PermissionWrapper.instance;
  final GlobalKey cardPreviewKey = GlobalKey();

  static const Set<PrinterConnectionType> scanTypes = {PrinterConnectionType.bluetooth, PrinterConnectionType.ble};

  final TextEditingController customerNameController = TextEditingController(text: 'Ka Ren');
  final TextEditingController pageNameController = TextEditingController(text: 'លក់អនឡាញ');
  late final Signal<List<TextEditingController>> phoneControllers;
  late final Signal<List<TextEditingController>> locationControllers;

  final devices = signal<List<PrinterDevice>>([]);
  final state = signal<PrinterConnectionState>(PrinterConnectionState.disconnected);
  final connectedDevice = signal<PrinterDevice?>(null);
  final isScanning = signal<bool>(false);
  final virakChecked = signal<bool>(false);
  final jtChecked = signal<bool>(true);
  final otherChecked = signal<bool>(false);
  final templateTick = signal<int>(0);

  StreamSubscription<List<PrinterDevice>>? scanSub;
  StreamSubscription<PrinterConnectionState>? stateSub;

  bool get connectedViaBle => connectedDevice.value is BlePrinterDevice;

  List<PrinterDevice> get printerDevices {
    return devices.value.where((device) {
      final name = device.name.toLowerCase();
      return name.contains('mp') ||
          name.contains('printer') ||
          name.contains('pos') ||
          name.contains('58') ||
          device == connectedDevice.value;
    }).toList();
  }

  PrintTemplateData get templateData {
    templateTick.value;
    return PrintTemplateData(
      customerName: customerNameController.text.trim(),
      pageName: pageNameController.text.trim(),
      phoneLines: collectLines(phoneControllers.value),
      locationLines: collectLines(locationControllers.value),
      virakChecked: virakChecked.value,
      jtChecked: jtChecked.value,
      otherChecked: otherChecked.value,
    );
  }

  @override
  void initState() {
    super.initState();

    phoneControllers = signal<List<TextEditingController>>([
      _createTemplateController('097 71 56 486'),
    ]);
    locationControllers = signal<List<TextEditingController>>([
      _createTemplateController('ភ្នំពេញ'),
    ]);

    stateSub = manager.stateStream.listen((nextState) {
      if (!mounted) return;
      state.value = nextState;
    });

    customerNameController.addListener(refreshTemplate);
    pageNameController.addListener(refreshTemplate);
  }

  Future<bool> requestBluetoothPermissions() async {
    return permissionWrapper.requestBluetoothScanPermissions();
  }

  Future<void> startScan() async {
    final granted = await requestBluetoothPermissions();

    if (!granted) {
      if (!mounted) return;
      showMessage('Please allow Bluetooth permissions first');
      return;
    }

    await scanSub?.cancel();

    devices.value = [];
    isScanning.value = true;

    scanSub = manager
        .scanAll(timeout: const Duration(seconds: 12), types: scanTypes)
        .listen(
          (foundDevices) {
            if (!mounted) return;
            devices.value = List<PrinterDevice>.from(foundDevices);
          },
          onDone: () {
            if (!mounted) return;
            isScanning.value = false;
          },
          onError: (error) {
            if (!mounted) return;
            isScanning.value = false;
            showMessage('Scan failed: $error');
          },
        );
  }

  Future<void> connectPrinter(PrinterDevice device) async {
    try {
      await manager.connect(device);

      if (!mounted) return;
      connectedDevice.value = device;

      showMessage('Connected: ${device.name}');
    } catch (e) {
      if (!mounted) return;
      showMessage('Connect failed: $e');
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await manager.disconnect();
      if (!mounted) return;

      connectedDevice.value = null;

      showMessage('Disconnected');
    } catch (e) {
      if (!mounted) return;
      showMessage('Disconnect failed: $e');
    }
  }

  Future<void> printDesign() async {
    if (state.value != PrinterConnectionState.connected) {
      showMessage('Connect printer first');
      return;
    }

    if (connectedViaBle) {
      showMessage(
        'Connected with BLE. MP583 printers often print only with Classic Bluetooth.',
        duration: const Duration(seconds: 4),
      );
    }

    try {
      final ticket = await Ticket.create(PaperSize.mm58);
      final image = await captureCardPreview();
      ticket.imageRaster(image, align: PrintAlign.center, maxWidth: 384);
      ticket.feed(3);

      await manager.printTicket(ticket);

      if (!mounted) return;
      showMessage('Printed successfully');
    } catch (e) {
      if (!mounted) return;
      showMessage('Print failed: $e');
    }
  }

  Future<img.Image> captureCardPreview() async {
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final boundary = cardPreviewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Card preview is not ready');
    }

    final ui.Image image = await boundary.toImage(pixelRatio: 3.5);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Unable to capture card preview');
    }

    final captured = img.decodePng(byteData.buffer.asUint8List());
    if (captured == null) {
      throw Exception('Unable to decode card image');
    }

    return captured;
  }

  String deviceSubtitle(PrinterDevice device) {
    final typeLabel = deviceTransport(device);

    if (device is BluetoothPrinterDevice) {
      return '$typeLabel • ${device.address}';
    }
    if (device is BlePrinterDevice) {
      return '$typeLabel • ${device.deviceId}';
    }
    return typeLabel;
  }

  String deviceTransport(PrinterDevice device) {
    return switch (device.connectionType) {
      PrinterConnectionType.bluetooth => 'Classic Bluetooth',
      PrinterConnectionType.ble => 'BLE',
      PrinterConnectionType.usb => 'USB',
      PrinterConnectionType.network => 'Network',
    };
  }

  String prettyState(PrinterConnectionState currentState) {
    final text = currentState.toString();
    return text.contains('.') ? text.split('.').last : text;
  }

  void toggleVirak() => virakChecked.value = !virakChecked.value;
  void toggleJt() => jtChecked.value = !jtChecked.value;
  void toggleOther() => otherChecked.value = !otherChecked.value;

  void addPhoneField() {
    phoneControllers.value = [
      ...phoneControllers.value,
      _createTemplateController(''),
    ];
    refreshTemplate();
  }

  void addLocationField() {
    locationControllers.value = [
      ...locationControllers.value,
      _createTemplateController(''),
    ];
    refreshTemplate();
  }

  void removePhoneField(int index) {
    if (phoneControllers.value.length <= 1) return;

    final next = [...phoneControllers.value];
    final controller = next.removeAt(index);
    controller.dispose();
    phoneControllers.value = next;
    refreshTemplate();
  }

  void removeLocationField(int index) {
    if (locationControllers.value.length <= 1) return;

    final next = [...locationControllers.value];
    final controller = next.removeAt(index);
    controller.dispose();
    locationControllers.value = next;
    refreshTemplate();
  }

  List<String> collectLines(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text.trim()).where((value) => value.isNotEmpty).toList();
  }

  TextEditingController _createTemplateController(String text) {
    final controller = TextEditingController(text: text);
    controller.addListener(refreshTemplate);
    return controller;
  }

  void refreshTemplate() {
    if (!mounted) return;
    templateTick.value++;
  }

  void showMessage(String message, {Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  @override
  void dispose() {
    for (final controller in [
      customerNameController,
      pageNameController,
      ...phoneControllers.value,
      ...locationControllers.value,
    ]) {
      controller.dispose();
    }

    scanSub?.cancel();
    stateSub?.cancel();
    devices.dispose();
    state.dispose();
    connectedDevice.dispose();
    isScanning.dispose();
    virakChecked.dispose();
    jtChecked.dispose();
    otherChecked.dispose();
    templateTick.dispose();
    phoneControllers.dispose();
    locationControllers.dispose();
    manager.disconnect();
    manager.dispose();
    super.dispose();
  }
}
