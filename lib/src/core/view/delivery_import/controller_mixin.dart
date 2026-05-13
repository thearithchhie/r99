import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:isar_community/isar.dart';
import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/models/delivery_record.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/database/services/print_invoice_store.dart';
import 'package:r99/src/core/printer/shared_printer_manager.dart';
import 'package:r99/src/core/services/google_sheet_delivery_import_service.dart';
import 'package:r99/src/core/view/delivery_import/delivery_import_page.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/print_template_data.dart';
import 'package:r99/src/printer_page.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

mixin DeliveryImportPageControllerMixin on State<DeliveryImportPage> {
  static const int printBatchSize = 5;

  final TextEditingController sheetUrlController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey printPreviewKey = GlobalKey();

  final deliveryRecords = signal<List<DeliveryRecord>>([]);
  final allDeliveryRecords = signal<List<DeliveryRecord>>([]);
  final importMessages = signal<List<String>>([]);
  final activePreviewRecord = signal<DeliveryRecord?>(null);
  final isImporting = signal<bool>(false);
  final isLoading = signal<bool>(false);
  final isSearching = signal<bool>(false);
  final isPrintingAll = signal<bool>(false);
  final summaryMessage = signal<String?>(null);
  final searchQuery = signal<String>('');
  final errorMessage = signal<String?>(null);

  Isar get isar => AppDatabase.instance.isar;
  PrinterManager get manager => sharedPrinterManager;

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
    loadDeliveryRecords();
  }

  void applyDeliveryRecords(List<DeliveryRecord> records) {
    allDeliveryRecords.value = records;

    final query = searchQuery.value;
    if (query.isEmpty) {
      deliveryRecords.value = records;
      return;
    }

    deliveryRecords.value = records.where((record) {
      return normalizePhone(record.phone).contains(query);
    }).toList();
  }

  Future<void> loadDeliveryRecords() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final records = await isar.deliveryRecords
          .where()
          .sortByImportedAtDesc()
          .findAll();
      if (!mounted) return;
      applyDeliveryRecords(records);
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to load imported deliveries.\n$error';
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> onSearchChanged() async {
    final query = normalizePhone(searchController.text);
    searchQuery.value = query;
    errorMessage.value = null;

    if (query.isEmpty) {
      isSearching.value = false;
      if (allDeliveryRecords.value.isNotEmpty) {
        deliveryRecords.value = allDeliveryRecords.value;
        return;
      }
      await loadDeliveryRecords();
      return;
    }

    isSearching.value = true;

    try {
      final source = allDeliveryRecords.value.isEmpty
          ? await isar.deliveryRecords.where().sortByImportedAtDesc().findAll()
          : allDeliveryRecords.value;

      if (!mounted) return;

      applyDeliveryRecords(source);
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to search deliveries.\n$error';
    } finally {
      if (mounted) {
        isSearching.value = false;
        isLoading.value = false;
      }
    }
  }

  Future<void> importFromGoogleSheet() async {
    final typedUrl = sheetUrlController.text.trim();

    isImporting.value = true;
    summaryMessage.value = null;
    errorMessage.value = null;
    importMessages.value = [];

    try {
      final resolvedShareUrl = GoogleSheetDeliveryImportService.resolveShareUrl(
        typedUrl,
      );
      final result = await GoogleSheetDeliveryImportService.importFromShareUrl(
        resolvedShareUrl,
      );

      await isar.writeTxn(() async {
        await isar.deliveryRecords.clear();
        if (result.records.isNotEmpty) {
          await isar.deliveryRecords.putAll(result.records);
        }
      });

      if (!mounted) return;

      importMessages.value = result.messages;
      if (typedUrl != resolvedShareUrl) {
        sheetUrlController.text = resolvedShareUrl;
      }
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

    if (manager.state != PrinterConnectionState.connected) {
      showMessage('Connect printer first from the Printer page.');
      return;
    }

    final connectedDevice = manager.connectedDevice;
    if (connectedDevice is BlePrinterDevice) {
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
      for (
        var start = 0;
        start < recordsToPrint.length;
        start += printBatchSize
      ) {
        final end = (start + printBatchSize < recordsToPrint.length)
            ? start + printBatchSize
            : recordsToPrint.length;
        final batch = recordsToPrint.sublist(start, end);
        final batchInvoices = <PrintInvoice>[];

        for (final record in batch) {
          activePreviewRecord.value = record;
          await WidgetsBinding.instance.endOfFrame;
          await Future<void>.delayed(const Duration(milliseconds: 80));

          final ticket = await Ticket.create(PaperSize.mm58);
          final templateData = templateDataFromRecord(record);
          final image = await capturePreview();

          ticket.imageRaster(image, align: PrintAlign.center, maxWidth: 384);
          ticket.feed(3);

          await manager.printTicket(ticket);
          batchInvoices.add(
            PrintInvoiceStore.buildInvoice(
              templateData,
              connectedDevice: connectedDevice,
              deviceTransport: deviceTransport,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 180));
        }

        await isar.writeTxn(() async {
          await isar.printInvoices.putAll(batchInvoices);
          await isar.deliveryRecords.deleteAll(
            batch.map((record) => record.id).toList(),
          );
        });

        committedCount += batch.length;
      }

      if (!mounted) return;
      summaryMessage.value =
          'Printed $committedCount deliveries successfully in batches of $printBatchSize.';
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

      final updatedRecords = allDeliveryRecords.value
          .where((item) => item.id != record.id)
          .toList();
      applyDeliveryRecords(updatedRecords);

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

      applyDeliveryRecords(const []);
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

  Future<img.Image> capturePreview() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 60));

    final boundary =
        printPreviewKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Delivery preview is not ready.');
    }

    final image = await boundary.toImage(pixelRatio: 3.5);
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
    final isJt =
        serviceLabel.toUpperCase() == 'J&T' ||
        serviceLabel.toUpperCase() == 'J & T';
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

  ParsedPrice parsePrice(String rawPrice) {
    final trimmed = rawPrice.trim();
    if (trimmed.startsWith('៛')) {
      return ParsedPrice(currency: '៛', amount: trimmed.substring(1).trim());
    }
    if (trimmed.startsWith('\$')) {
      return ParsedPrice(currency: '\$', amount: trimmed.substring(1).trim());
    }
    return ParsedPrice(currency: '\$', amount: trimmed);
  }

  String normalizeShopValue(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'none') {
      return 'none';
    }
    return 'shop';
  }

  String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  String deviceTransport(PrinterDevice device) {
    return switch (device.connectionType) {
      PrinterConnectionType.bluetooth => 'Classic Bluetooth',
      PrinterConnectionType.ble => 'BLE',
      PrinterConnectionType.usb => 'USB',
      PrinterConnectionType.network => 'Network',
    };
  }

  void onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.deliveries:
        return;
      case AppMenuDestination.printer:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PrinterPage()),
        );
      case AppMenuDestination.textScanner:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TextScannerPage()),
        );
      case AppMenuDestination.invoices:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InvoiceListPage()),
        );
    }
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PrinterPage(initialInvoice: draftInvoice),
      ),
    );
  }

  void showMessage(
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  @override
  void dispose() {
    sheetUrlController.dispose();
    searchController.dispose();
    deliveryRecords.dispose();
    allDeliveryRecords.dispose();
    importMessages.dispose();
    activePreviewRecord.dispose();
    isImporting.dispose();
    isLoading.dispose();
    isSearching.dispose();
    isPrintingAll.dispose();
    summaryMessage.dispose();
    searchQuery.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}

class ParsedPrice {
  const ParsedPrice({required this.currency, required this.amount});

  final String currency;
  final String amount;
}
