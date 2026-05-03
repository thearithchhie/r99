import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/printer_page.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin InvoiceListPageControllerMixin on State<InvoiceListPage> {
  static const int pageSize = 20;

  final ScrollController scrollController = ScrollController();
  final invoices = signal<List<PrintInvoice>>([]);
  final isInitialLoading = signal<bool>(false);
  final isLoadingMore = signal<bool>(false);
  final hasMore = signal<bool>(true);
  final errorMessage = signal<String?>(null);

  Isar get isar => AppDatabase.instance.isar;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
    loadInvoices(reset: true);
  }

  Future<void> loadInvoices({bool reset = false}) async {
    if (isInitialLoading.value || isLoadingMore.value) return;
    if (!reset && !hasMore.value) return;

    if (reset) {
      isInitialLoading.value = true;
      errorMessage.value = null;
      hasMore.value = true;
    } else {
      isLoadingMore.value = true;
    }

    try {
      final offset = reset ? 0 : invoices.value.length;
      final nextItems = await isar.printInvoices
          .where()
          .anyCreatedAt()
          .sortByCreatedAtDesc()
          .offset(offset)
          .limit(pageSize)
          .findAll();

      if (!mounted) return;

      invoices.value = reset ? nextItems : [...invoices.value, ...nextItems];
      hasMore.value = nextItems.length == pageSize;
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to load invoices.\n$error';
    } finally {
      if (mounted) {
        isInitialLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void onScroll() {
    if (!scrollController.hasClients ||
        isInitialLoading.value ||
        isLoadingMore.value) {
      return;
    }

    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      loadInvoices();
    }
  }

  void onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.invoices:
        return;
      case AppMenuDestination.printer:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PrinterPage()),
        );
      case AppMenuDestination.textScanner:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TextScannerPage()),
        );
    }
  }

  String invoiceAmount(PrintInvoice invoice) {
    final value = invoice.totalPrice.isEmpty
        ? invoice.selectedOption
        : invoice.totalPrice;
    return '${invoice.currency}$value';
  }

  @override
  void dispose() {
    scrollController.dispose();
    invoices.dispose();
    isInitialLoading.dispose();
    isLoadingMore.dispose();
    hasMore.dispose();
    errorMessage.dispose();
    super.dispose();
  }
}
