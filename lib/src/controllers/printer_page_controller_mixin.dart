import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/app_preferences_store.dart';
import 'package:r99/src/core/database/models/app_preference.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/helper/permissions/permission_wrapper.dart';
import 'package:r99/src/print_template_data.dart';
import 'package:r99/src/printer_page.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

mixin PrinterPageControllerMixin on State<PrinterPage> {
  static final PrinterManager _sharedManager = PrinterManager();

  PrinterManager get manager => _sharedManager;
  final PermissionWrapper permissionWrapper = PermissionWrapper.instance;
  final GlobalKey cardPreviewKey = GlobalKey();

  static const Set<PrinterConnectionType> scanTypes = {PrinterConnectionType.bluetooth, PrinterConnectionType.ble};

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
  final currency = signal<String>('\$');
  final showPreview = signal<bool>(true);
  final templateTick = signal<int>(0);

  StreamSubscription<List<PrinterDevice>>? scanSub;
  StreamSubscription<PrinterConnectionState>? stateSub;
  StreamSubscription<AppPreference?>? previewPreferenceSub;

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

    state.value = manager.state;
    connectedDevice.value = manager.connectedDevice;

    stateSub = manager.stateStream.listen((nextState) {
      if (!mounted) return;
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
      await savePrintedInvoice();
      resetTemplateForm();

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

  Future<void> savePrintedInvoice() async {
    final invoice = PrintInvoice()
      ..createdAt = DateTime.now()
      ..customerName = templateData.customerName
      ..pageName = templateData.pageName
      ..phoneLines = List<String>.from(templateData.phoneLines)
      ..locationLines = List<String>.from(templateData.locationLines)
      ..selectedOption = templateData.selectedOption
      ..totalPrice = templateData.totalPrice
      ..currency = templateData.currency
      ..guestServiceChecked = templateData.guestServiceChecked
      ..virakChecked = templateData.virakChecked
      ..jtChecked = templateData.jtChecked
      ..otherChecked = templateData.otherChecked
      ..printerName = connectedDevice.value?.name ?? ''
      ..printerTransport = connectedDevice.value == null ? '' : deviceTransport(connectedDevice.value!);

    await AppDatabase.instance.isar.writeTxn(() async {
      await AppDatabase.instance.isar.printInvoices.put(invoice);
    });
  }

  void applyInvoiceToForm(PrintInvoice invoice) {
    customerNameController.text = normalizedCustomerName(invoice.customerName);
    pageNameController.text = invoice.pageName;
    totalPriceController.text = invoice.totalPrice;
    selectedOption.value = invoice.selectedOption.isEmpty ? '0' : invoice.selectedOption;
    currency.value = invoice.currency.isEmpty ? '\$' : invoice.currency;
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
    currency.value = '\$';
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
