import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:r99/export.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

mixin PrinterPageControllerMixin on State<PrinterPage> {
  PrinterManager get manager => sharedPrinterManager;
  final PermissionWrapper permissionWrapper = PermissionWrapper.instance;
  final GlobalKey cardPreviewKey = GlobalKey();

  Set<PrinterConnectionType> get scanTypes {
    if (Platform.isWindows) {
      return {PrinterConnectionType.bluetooth, PrinterConnectionType.usb};
    }

    if (Platform.isMacOS || Platform.isLinux) {
      return {PrinterConnectionType.usb};
    }

    return {PrinterConnectionType.bluetooth, PrinterConnectionType.ble};
  }

  final TextEditingController customerNameController = TextEditingController(text: 'shop');
  final TextEditingController pageNameController = TextEditingController(text: '');
  final TextEditingController totalPriceController = TextEditingController();
  late final Signal<List<TextEditingController>> phoneControllers;
  late final Signal<List<TextEditingController>> locationControllers;

  final devices = signal<List<PrinterDevice>>([]);
  final state = signal<PrinterConnectionState>(PrinterConnectionState.disconnected);
  final connectedDevice = signal<PrinterDevice?>(null);
  final isScanning = signal<bool>(false);
  final guestServiceChecked = signal<bool>(false);
  final virakChecked = signal<bool>(false);
  final jtChecked = signal<bool>(false);
  final otherChecked = signal<bool>(false);
  final selectedOption = signal<String>('0');
  final currency = signal<String>(CurrencyType.fallback.symbol);
  final showPreview = signal<bool>(true);
  final templateTick = signal<int>(0);

  StreamSubscription<List<PrinterDevice>>? scanSub;
  StreamSubscription<PrinterConnectionState>? stateSub;
  StreamSubscription<AppPreference?>? previewPreferenceSub;

  bool get connectedViaBle => connectedDevice.value is BlePrinterDevice;
  bool get isDesktopUsbMode => Platform.isMacOS || Platform.isLinux;
  bool get isMacOSNativePrintingMode => Platform.isMacOS;

  String get desktopUsbHelpText {
    if (Platform.isMacOS) {
      return 'On macOS, this app can show installed printer queues and serial USB printers. Some raw USB ports may still fail if the printer is not a serial ESC/POS device.';
    }

    return 'On desktop USB, this app works only with serial USB printers.';
  }

  String get desktopUsbEmptyStateText {
    if (Platform.isMacOS) {
      return 'No macOS or USB serial printers found.\nMake sure the printer is powered on, installed in macOS if needed, and plugged in, then scan again.';
    }

    return 'No USB serial printers found.\nMake sure the printer is powered on and plugged in, then scan again.';
  }

  List<PrinterDevice> get printerDevices {
    final Map<String, PrinterDevice> byName = {};
    for (final device in devices.value) {
      final key = deviceUniqueKey(device);
      final existing = byName[key];

      if (existing == null) {
        byName[key] = device;
        continue;
      }

      if (existing is BlePrinterDevice && device is BluetoothPrinterDevice) {
        byName[key] = device;
      }
    }

    final result = byName.values.toList();
    result.sort((a, b) {
      final rankA = transportRank(a);
      final rankB = transportRank(b);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return deviceDisplayName(a).compareTo(deviceDisplayName(b));
    });
    return result;
  }

  PrintTemplateData get templateData {
    templateTick.value;
    return PrintTemplateData(
      customerName: normalizedCustomerName(customerNameController.text),
      pageName: pageNameController.text.trim(),
      phoneLines: collectLines(phoneControllers.value),
      locationLines: collectLines(locationControllers.value),
      selectedOption: selectedOption.value,
      totalPrice: totalPriceController.text.trim(),
      currency: currency.value,
      guestServiceChecked: guestServiceChecked.value,
      virakChecked: virakChecked.value,
      jtChecked: jtChecked.value,
      otherChecked: otherChecked.value,
    );
  }

  bool get canPrintDesign {
    templateTick.value;

    final hasCustomerName = customerNameController.text.trim().isNotEmpty;
    final hasPageName = pageNameController.text.trim().isNotEmpty;
    final hasAllPhones = phoneControllers.value.every((controller) => controller.text.trim().isNotEmpty);
    final hasAllLocations = locationControllers.value.every((controller) => controller.text.trim().isNotEmpty);
    final hasPrice = totalPriceController.text.trim().isNotEmpty || selectedOption.value != '0';

    return hasCustomerName && hasPageName && hasAllPhones && hasAllLocations && hasPrice;
  }

  @override
  void initState() {
    super.initState();

    phoneControllers = signal<List<TextEditingController>>([_createTemplateController('')]);
    locationControllers = signal<List<TextEditingController>>([_createTemplateController('')]);

    if (isMacOSNativePrinterDevice(sharedMacOSNativePrinterDevice.value)) {
      state.value = PrinterConnectionState.connected;
      connectedDevice.value = sharedMacOSNativePrinterDevice.value;
    } else {
      state.value = manager.state;
      connectedDevice.value = manager.connectedDevice;
    }

    stateSub = manager.stateStream.listen((nextState) {
      if (!mounted) return;

      if (isMacOSNativePrinterDevice(sharedMacOSNativePrinterDevice.value)) {
        state.value = PrinterConnectionState.connected;
        connectedDevice.value = sharedMacOSNativePrinterDevice.value;
        return;
      }

      state.value = nextState;
      connectedDevice.value = manager.connectedDevice;
    });

    previewPreferenceSub = AppDatabase.instance.isar.appPreferences
        .watchObject(AppPreference.previewVisibilityId, fireImmediately: true)
        .listen((record) {
          if (!mounted) return;
          showPreview.value = record?.showPreview ?? true;
        });

    loadPreviewPreference();
    customerNameController.addListener(refreshTemplate);
    pageNameController.addListener(refreshTemplate);
    totalPriceController.addListener(refreshTemplate);

    final initialInvoice = widget.initialInvoice;
    if (initialInvoice != null) {
      applyInvoiceToForm(initialInvoice);
    }
  }

  Future<void> loadPreviewPreference() async {
    final savedValue = await AppPreferencesStore.loadShowPreview();
    if (!mounted) return;
    showPreview.value = savedValue;
  }

  Future<BluetoothPermissionResult> requestBluetoothPermissions() async {
    return permissionWrapper.requestBluetoothScanPermissions();
  }

  Future<void> startScan() async {
    final permissionResult = await requestBluetoothPermissions();

    if (permissionResult != BluetoothPermissionResult.granted) {
      if (permissionResult == BluetoothPermissionResult.permanentlyDenied) {
        await permissionWrapper.openSettings();
      }

      if (!mounted) return;
      showMessage(
        permissionResult == BluetoothPermissionResult.permanentlyDenied
            ? 'Bluetooth permission is permanently denied. App settings opened for you.'
            : 'Please allow Bluetooth permissions first',
      );
      return;
    }

    await scanSub?.cancel();

    devices.value = [];
    isScanning.value = true;

    if (Platform.isMacOS) {
      await startMacOSScan();
      return;
    }

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

  Future<void> startMacOSScan() async {
    List<PrinterDevice> nativeDevices = [];

    try {
      final printerNames = await MacOSNativePrinterService.listPrinters();
      nativeDevices = printerNames
          .map(
            (name) => UsbPrinterDevice(
              name: name,
              identifier: MacOSNativePrinterService.buildIdentifier(name),
              usbPlatform: UsbPlatform.desktop,
            ),
          )
          .toList();
      devices.value = nativeDevices;
    } catch (error) {
      if (mounted) {
        showMessage('Unable to load macOS printers: $error');
      }
    }

    scanSub = manager
        .scanAll(timeout: const Duration(seconds: 12), types: scanTypes)
        .listen(
          (foundDevices) {
            if (!mounted) return;
            devices.value = [...nativeDevices, ...foundDevices];
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
    if (isMacOSNativePrinterDevice(device)) {
      await connectMacOSNativePrinter(device);
      return;
    }

    try {
      sharedMacOSNativePrinterDevice.value = null;
      await manager.connect(device);

      if (!mounted) return;
      connectedDevice.value = device;

      showMessage('Connected: ${device.name}');
    } catch (e) {
      if (!mounted) return;
      if (isDesktopUsbMode && device is UsbPrinterDevice) {
        showMessage(
          'Connect failed: desktop USB here supports serial USB printers only. '
          'If this printer is a normal USB printer-class device, it may appear in the scan list but still cannot connect.\n$e',
          duration: const Duration(seconds: 6),
        );
        return;
      }
      showMessage('Connect failed: $e');
    }
  }

  Future<void> connectMacOSNativePrinter(PrinterDevice device) async {
    try {
      final printers = await MacOSNativePrinterService.listPrinters();
      if (!printers.contains(device.name)) {
        throw Exception('Printer queue not found in macOS');
      }

      sharedMacOSNativePrinterDevice.value = device;
      state.value = PrinterConnectionState.connected;
      connectedDevice.value = device;
      showMessage('Ready: ${device.name}');
    } catch (e) {
      if (!mounted) return;
      showMessage('Connect failed: $e');
    }
  }

  Future<void> disconnectPrinter() async {
    if (isMacOSNativePrinterDevice(connectedDevice.value)) {
      sharedMacOSNativePrinterDevice.value = null;
      connectedDevice.value = null;
      state.value = PrinterConnectionState.disconnected;
      showMessage('Disconnected');
      return;
    }

    try {
      await manager.disconnect();
      if (!mounted) return;

      sharedMacOSNativePrinterDevice.value = null;
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
        'Connected with BLE. Disconnect and connect to the Classic Bluetooth printer entry before printing.',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (isMacOSNativePrinterDevice(connectedDevice.value)) {
      await printWithMacOSNativePrinter(connectedDevice.value!);
      return;
    }

    try {
      final ticket = await Ticket.create(PaperSize.mm58);
      final image = await captureCardPreview();
      ticket.imageRaster(image, align: PrintAlign.center, maxWidth: 384);
      ticket.feed(3);

      await manager.printTicket(ticket);
      await savePrintedInvoice();
      resetTemplateForm();

      if (!mounted) return;
      showMessage('Printed successfully');
    } catch (e) {
      if (!mounted) return;
      showMessage('Print failed: $e');
    }
  }

  Future<void> printWithMacOSNativePrinter(PrinterDevice device) async {
    try {
      await MacOSNativePrinterService.printTemplate(printerName: device.name, data: templateData);
      await savePrintedInvoice();
      resetTemplateForm();

      if (!mounted) return;
      showMessage('Printed successfully');
    } catch (e) {
      if (!mounted) return;
      showMessage('Print failed: $e');
    }
  }

  Future<Uint8List> captureCardPreviewPngBytes() async {
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

    return byteData.buffer.asUint8List();
  }

  Future<img.Image> captureCardPreview() async {
    final captured = img.decodePng(await captureCardPreviewPngBytes());
    if (captured == null) {
      throw Exception('Unable to decode card image');
    }

    return captured;
  }

  String deviceSubtitle(PrinterDevice device) {
    if (isMacOSNativePrinterDevice(device)) {
      return 'macOS Printer • Installed queue';
    }

    final typeLabel = deviceTransport(device);

    if (device is BluetoothPrinterDevice) {
      return '$typeLabel • ${device.address}';
    }
    if (device is BlePrinterDevice) {
      return '$typeLabel • ${device.deviceId}';
    }
    return typeLabel;
  }

  String deviceDisplayName(PrinterDevice device) {
    final name = device.name.trim();
    if (name.isNotEmpty) {
      return name;
    }

    return switch (device) {
      BluetoothPrinterDevice(address: final address) => 'Bluetooth $address',
      BlePrinterDevice(deviceId: final deviceId) => 'BLE $deviceId',
      UsbPrinterDevice() => 'USB printer',
      NetworkPrinterDevice() => 'Network printer',
      _ => 'Unknown printer',
    };
  }

  String deviceUniqueKey(PrinterDevice device) {
    return switch (device) {
      UsbPrinterDevice(identifier: final identifier) when MacOSNativePrinterService.isNativeIdentifier(identifier) =>
        'macos-native:${device.name.toLowerCase()}',
      BluetoothPrinterDevice(address: final address) => 'bt:${address.toLowerCase()}',
      BlePrinterDevice(deviceId: final deviceId) => 'ble:${deviceId.toLowerCase()}',
      UsbPrinterDevice() => 'usb:${normalizedDeviceName(device.name)}',
      NetworkPrinterDevice() => 'net:${normalizedDeviceName(device.name)}',
      _ => '${device.connectionType.name}:${normalizedDeviceName(device.name)}',
    };
  }

  String deviceTransport(PrinterDevice device) {
    if (isMacOSNativePrinterDevice(device)) {
      return 'macOS Printer';
    }

    return switch (device.connectionType) {
      PrinterConnectionType.bluetooth => 'Classic Bluetooth',
      PrinterConnectionType.ble => 'BLE',
      PrinterConnectionType.usb => 'USB',
      PrinterConnectionType.network => 'Network',
    };
  }

  int transportRank(PrinterDevice device) {
    if (isMacOSNativePrinterDevice(device)) {
      return 0;
    }

    return switch (device.connectionType) {
      PrinterConnectionType.bluetooth => 1,
      PrinterConnectionType.usb => 2,
      PrinterConnectionType.network => 3,
      PrinterConnectionType.ble => 4,
    };
  }

  bool isMacOSNativePrinterDevice(PrinterDevice? device) {
    return Platform.isMacOS &&
        device is UsbPrinterDevice &&
        MacOSNativePrinterService.isNativeIdentifier(device.identifier);
  }

  String normalizedDeviceName(String value) {
    return value.trim().toLowerCase();
  }

  String prettyState(PrinterConnectionState currentState) {
    final text = currentState.toString();
    return text.contains('.') ? text.split('.').last : text;
  }

  Future<void> savePrintedInvoice() async {
    await PrintInvoiceStore.saveTemplateAsInvoice(
      templateData,
      connectedDevice: connectedDevice.value,
      deviceTransport: deviceTransport,
    );
  }

  void applyInvoiceToForm(PrintInvoice invoice) {
    customerNameController.text = normalizedCustomerName(invoice.customerName);
    pageNameController.text = invoice.pageName;
    totalPriceController.text = invoice.totalPrice;
    selectedOption.value = invoice.selectedOption.isEmpty ? '0' : invoice.selectedOption;
    currency.value = invoice.currency.isEmpty ? CurrencyType.fallback.symbol : invoice.currency;
    guestServiceChecked.value = invoice.guestServiceChecked;
    virakChecked.value = invoice.virakChecked;
    jtChecked.value = invoice.jtChecked;
    otherChecked.value = invoice.otherChecked;
    replacePhoneFields(invoice.phoneLines.isEmpty ? const [''] : invoice.phoneLines);
    replaceLocationFields(invoice.locationLines.isEmpty ? const [''] : invoice.locationLines);
    refreshTemplate();
  }

  void replacePhoneFields(List<String> values) {
    for (final controller in phoneControllers.value) {
      controller.dispose();
    }
    phoneControllers.value = values.map((value) => _createTemplateController(value)).toList();
  }

  void replaceLocationFields(List<String> values) {
    for (final controller in locationControllers.value) {
      controller.dispose();
    }
    locationControllers.value = values.map((value) => _createTemplateController(value)).toList();
  }

  void resetTemplateForm() {
    customerNameController.text = 'shop';
    pageNameController.clear();
    totalPriceController.clear();
    selectedOption.value = '0';
    currency.value = CurrencyType.fallback.symbol;
    guestServiceChecked.value = false;
    virakChecked.value = false;
    jtChecked.value = false;
    otherChecked.value = false;
    replacePhoneFields(const ['']);
    replaceLocationFields(const ['']);

    refreshTemplate();
  }

  void toggleGuestService() => guestServiceChecked.value = !guestServiceChecked.value;
  void toggleVirak() => virakChecked.value = !virakChecked.value;
  void toggleJt() => jtChecked.value = !jtChecked.value;
  void toggleOther() => otherChecked.value = !otherChecked.value;
  void setSelectedOption(String value) {
    selectedOption.value = value;
    refreshTemplate();
  }

  void setCustomerName(String value) {
    customerNameController.text = normalizedCustomerName(value);
    refreshTemplate();
  }

  String normalizedCustomerName(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'shop' || normalized == 'r99') {
      return 'shop';
    }
    return 'none';
  }

  void setCurrency(String value) {
    currency.value = value;
    refreshTemplate();
  }

  void addPhoneField() {
    phoneControllers.value = [...phoneControllers.value, _createTemplateController('')];
    refreshTemplate();
  }

  void addLocationField() {
    locationControllers.value = [...locationControllers.value, _createTemplateController('')];
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
      totalPriceController,
      ...phoneControllers.value,
      ...locationControllers.value,
    ]) {
      controller.dispose();
    }

    scanSub?.cancel();
    stateSub?.cancel();
    previewPreferenceSub?.cancel();
    devices.dispose();
    state.dispose();
    connectedDevice.dispose();
    isScanning.dispose();
    guestServiceChecked.dispose();
    virakChecked.dispose();
    jtChecked.dispose();
    otherChecked.dispose();
    selectedOption.dispose();
    currency.dispose();
    showPreview.dispose();
    templateTick.dispose();
    phoneControllers.dispose();
    locationControllers.dispose();
    super.dispose();
  }
}
