import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:r99/export.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

mixin DeliveryImportPageControllerMixin on State<DeliveryImportPage> {
  static const int printBatchSize = 5;

  final GlobalKey printPreviewKey = GlobalKey();

  final deliveryRecords = signal<List<DeliveryRecord>>([]);
  final importMessages = signal<List<String>>([]);
  final activePreviewRecord = signal<DeliveryRecord?>(null);
  final isImporting = signal<bool>(false);
  final isLoading = signal<bool>(false);
  final isPrintingAll = signal<bool>(false);
  final summaryMessage = signal<String?>(null);
  final errorMessage = signal<String?>(null);

  Isar get isar => AppDatabase.instance.isar;
  PrinterManager get manager => sharedPrinterManager;

  @override
  void initState() {
    super.initState();
    loadDeliveryRecords();
  }

  Future<void> loadDeliveryRecords() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final records = await isar.deliveryRecords.where().sortByImportedAtDesc().findAll();
      if (!mounted) return;
      deliveryRecords.value = records;
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to load imported deliveries.\n$error';
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> importFromGoogleSheet() async {
    isImporting.value = true;
    summaryMessage.value = null;
    errorMessage.value = null;
    importMessages.value = [];

    try {
      final resolvedShareUrl = GoogleSheetDeliveryImportService.resolveShareUrl('');
      final result = await GoogleSheetDeliveryImportService.importFromShareUrl(resolvedShareUrl);

      await isar.writeTxn(() async {
        await isar.deliveryRecords.clear();
        if (result.records.isNotEmpty) {
          await isar.deliveryRecords.putAll(result.records);
        }
      });

      if (!mounted) return;

      importMessages.value = result.messages;
      summaryMessage.value = result.skippedRows == 0
          ? 'Imported ${result.records.length} deliveries.'
          : 'Imported ${result.records.length} deliveries. '
                'Skipped ${result.skippedRows} empty rows.';
      await loadDeliveryRecords();
      showMessage('Delivery data imported successfully.');
    } catch (error) {
      if (!mounted) return;
      summaryMessage.value = 'Import failed.\n$error';
      showMessage('Import failed. Please check the sheet link.');
    } finally {
      if (mounted) {
        isImporting.value = false;
      }
    }
  }

  Future<void> printAllDeliveries() async {
    if (deliveryRecords.value.isEmpty) {
      showMessage('No imported deliveries to print.');
      return;
    }

    if (isPrintingAll.value) {
      return;
    }

    final iosPrinterDevice = sharedIOSBluetoothImagePrinterDevice.value;
    final macOSNativeDevice = sharedMacOSNativePrinterDevice.value;
    final printWithIOSBluetoothImage = IOSBluetoothImagePrinterService.isDevice(iosPrinterDevice);
    final printWithMacOSNative = macOSNativeDevice != null;

    if (!printWithIOSBluetoothImage && !printWithMacOSNative && manager.state != PrinterConnectionState.connected) {
      showMessage('Connect printer first from the Printer page.');
      return;
    }

    final connectedDevice = printWithIOSBluetoothImage
        ? iosPrinterDevice!
        : printWithMacOSNative
        ? macOSNativeDevice
        : manager.connectedDevice;
    if (!printWithIOSBluetoothImage && !printWithMacOSNative && connectedDevice is BlePrinterDevice) {
      showMessage(
        'Connected with BLE. Disconnect and reconnect with the Classic Bluetooth printer entry before printing.',
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isPrintingAll.value = true;
    summaryMessage.value = null;
    var committedCount = 0;
    final recordsToPrint = List<DeliveryRecord>.from(deliveryRecords.value);

    try {
      for (var start = 0; start < recordsToPrint.length; start += printBatchSize) {
        final end = (start + printBatchSize < recordsToPrint.length) ? start + printBatchSize : recordsToPrint.length;
        final batch = recordsToPrint.sublist(start, end);
        final batchInvoices = <PrintInvoice>[];

        for (final record in batch) {
          activePreviewRecord.value = record;
          await WidgetsBinding.instance.endOfFrame;
          await Future<void>.delayed(const Duration(milliseconds: 80));

          final templateData = templateDataFromRecord(record);

          if (printWithMacOSNative) {
            await MacOSNativePrinterService.printTemplate(printerName: macOSNativeDevice.name, data: templateData);
          } else {
            final ticket = await Ticket.create(PaperSize.mm58);
            final image = await capturePreview(pixelRatio: printWithIOSBluetoothImage ? 1 : 3.5);

            if (!printWithIOSBluetoothImage) {
              ticket.imageRaster(image, align: PrintAlign.center, maxWidth: 384);
              ticket.feed(3);
            }

            if (printWithIOSBluetoothImage) {
              await IOSBluetoothImagePrinterService.printImageBytes(img.encodePng(image));
            } else {
              await manager.printTicket(ticket);
            }
          }
          batchInvoices.add(
            PrintInvoiceStore.buildInvoice(
              templateData,
              connectedDevice: connectedDevice,
              deviceTransport: deliveryDeviceTransport,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 180));
        }

        await isar.writeTxn(() async {
          await isar.printInvoices.putAll(batchInvoices);
          await isar.deliveryRecords.deleteAll(batch.map((record) => record.id).toList());
        });

        committedCount += batch.length;
      }

      if (!mounted) return;
      summaryMessage.value = 'Printed $committedCount deliveries successfully in batches of $printBatchSize.';
      await loadDeliveryRecords();
      showMessage('Printed all imported deliveries.');
    } catch (error) {
      if (!mounted) return;
      summaryMessage.value =
          'Printing stopped after $committedCount committed deliveries. '
          'The current batch was rolled back.\n$error';
      showMessage('Print All stopped. The current batch was rolled back.');
    } finally {
      if (mounted) {
        activePreviewRecord.value = null;
        isPrintingAll.value = false;
      }
    }
  }

  Future<void> deleteDeliveryRecord(DeliveryRecord record) async {
    try {
      await isar.writeTxn(() async {
        await isar.deliveryRecords.delete(record.id);
      });

      if (!mounted) return;

      final updatedRecords = deliveryRecords.value.where((item) => item.id != record.id).toList();
      deliveryRecords.value = updatedRecords;

      if (activePreviewRecord.value?.id == record.id) {
        activePreviewRecord.value = null;
      }

      summaryMessage.value = 'Deleted 1 delivery.';
      errorMessage.value = null;
      showMessage('Delivery removed.');
    } catch (error) {
      if (!mounted) return;
      summaryMessage.value = 'Unable to delete this delivery.\n$error';
      showMessage('Delete failed. Please try again.');
    }
  }

  Future<void> deleteAllDeliveryRecords() async {
    try {
      await isar.writeTxn(() async {
        await isar.deliveryRecords.clear();
      });

      if (!mounted) return;

      deliveryRecords.value = const [];
      activePreviewRecord.value = null;
      summaryMessage.value = 'Deleted all imported deliveries.';
      errorMessage.value = null;
      showMessage('All deliveries removed.');
    } catch (error) {
      if (!mounted) return;
      summaryMessage.value = 'Unable to delete deliveries.\n$error';
      showMessage('Delete All failed. Please try again.');
    }
  }

  Future<img.Image> capturePreview({double pixelRatio = 3.5}) async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final boundary = printPreviewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Delivery preview is not ready.');
    }

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Unable to capture delivery preview.');
    }

    final captured = img.decodePng(byteData.buffer.asUint8List());
    if (captured == null) {
      throw Exception('Unable to decode delivery preview image.');
    }

    return captured;
  }

  PrintTemplateData templateDataFromRecord(DeliveryRecord record) {
    final parsedPrice = parsePrice(record.price);
    final serviceLabel = record.deliverService.trim();
    final isJt = serviceLabel.toUpperCase() == 'J&T' || serviceLabel.toUpperCase() == 'J & T';
    final hasOtherService = serviceLabel.isNotEmpty && !isJt;

    return PrintTemplateData(
      customerName: normalizeShopValue(record.shop),
      pageName: record.customerName,
      phoneLines: [record.phone],
      locationLines: [record.location],
      selectedOption: '0',
      totalPrice: parsedPrice.amount,
      currency: parsedPrice.currency,
      guestServiceChecked: false,
      virakChecked: false,
      jtChecked: isJt,
      otherChecked: hasOtherService,
    );
  }

  void openDeliveryForReprint(DeliveryRecord record) {
    final template = templateDataFromRecord(record);
    final draftInvoice = PrintInvoice()
      ..createdAt = DateTime.now()
      ..customerName = template.customerName
      ..pageName = template.pageName
      ..phoneLines = List<String>.from(template.phoneLines)
      ..locationLines = List<String>.from(template.locationLines)
      ..selectedOption = template.selectedOption
      ..totalPrice = template.totalPrice
      ..currency = template.currency
      ..guestServiceChecked = template.guestServiceChecked
      ..virakChecked = template.virakChecked
      ..jtChecked = template.jtChecked
      ..otherChecked = template.otherChecked;

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PrinterPage(initialInvoice: draftInvoice)));
  }

  void showMessage(String message, {Duration duration = const Duration(seconds: 4)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  String deliveryDeviceTransport(PrinterDevice device) {
    if (IOSBluetoothImagePrinterService.isDevice(device)) {
      return 'iOS Bluetooth Image';
    }
    return deviceTransport(device);
  }

  @override
  void dispose() {
    deliveryRecords.dispose();
    importMessages.dispose();
    activePreviewRecord.dispose();
    isImporting.dispose();
    isLoading.dispose();
    isPrintingAll.dispose();
    summaryMessage.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
