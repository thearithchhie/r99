import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';
import 'package:r99/src/core/view/delivery_import/delivery_import_page.dart';
import 'package:r99/src/core/view/health_log/health_log_page.dart';
import 'package:r99/src/core/view/invoice/invoice_list_page.dart';
import 'package:r99/src/core/view/ocr/text_scanner_page.dart';
import 'package:r99/src/printer_page.dart';
import 'package:r99/src/widgets/app_menu_drawer.dart';
import 'package:signals_flutter/signals_flutter.dart';

mixin InvoiceListPageControllerMixin on State<InvoiceListPage> {
  static const int pageSize = 20;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final invoices = signal<List<PrintInvoice>>([]);
  final allInvoices = signal<List<PrintInvoice>>([]);
  final isInitialLoading = signal<bool>(false);
  final isLoadingMore = signal<bool>(false);
  final isSearching = signal<bool>(false);
  final isDeletingAll = signal<bool>(false);
  final hasMore = signal<bool>(true);
  final errorMessage = signal<String?>(null);
  final searchQuery = signal<String>('');

  Isar get isar => AppDatabase.instance.isar;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(onScroll);
    searchController.addListener(onSearchChanged);
    loadInvoices(reset: true);
  }

  Future<void> loadInvoices({bool reset = false}) async {
    if (searchQuery.value.isNotEmpty) {
      isInitialLoading.value = false;
      isLoadingMore.value = false;
      return;
    }
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
      allInvoices.value = invoices.value;
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

  Future<void> onSearchChanged() async {
    final query = normalizePhone(searchController.text);
    searchQuery.value = query;
    errorMessage.value = null;

    if (query.isEmpty) {
      isSearching.value = false;
      if (allInvoices.value.isNotEmpty) {
        invoices.value = allInvoices.value;
        return;
      }
      await loadInvoices(reset: true);
      return;
    }

    isSearching.value = true;
    hasMore.value = false;

    try {
      final source = allInvoices.value.isEmpty
          ? await isar.printInvoices
                .where()
                .anyCreatedAt()
                .sortByCreatedAtDesc()
                .findAll()
          : allInvoices.value;

      if (!mounted) return;

      allInvoices.value = source;
      invoices.value = source.where((invoice) {
        return invoice.phoneLines.any((phone) {
          return normalizePhone(phone).contains(query);
        });
      }).toList();
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to search invoices.\n$error';
    } finally {
      if (mounted) {
        isSearching.value = false;
        isInitialLoading.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void onScroll() {
    if (searchQuery.value.isNotEmpty) return;
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
      case AppMenuDestination.deliveries:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DeliveryImportPage()),
        );
      case AppMenuDestination.logs:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HealthLogPage()),
        );
    }
  }

  String invoiceAmount(PrintInvoice invoice) {
    final value = invoice.totalPrice.isEmpty
        ? invoice.selectedOption
        : invoice.totalPrice;
    return '${invoice.currency}$value';
  }

  void openInvoiceForReprint(PrintInvoice invoice) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PrinterPage(initialInvoice: invoice)),
    );
  }

  Future<void> confirmDeleteAllInvoices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete all invoices?'),
        content: const Text(
          'This will remove every saved invoice from local history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await deleteAllInvoices();
    }
  }

  Future<void> deleteAllInvoices() async {
    if (isDeletingAll.value) return;

    isDeletingAll.value = true;
    errorMessage.value = null;

    try {
      await isar.writeTxn(() async {
        await isar.printInvoices.clear();
      });

      if (!mounted) return;

      invoices.value = [];
      allInvoices.value = [];
      hasMore.value = false;
      searchController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All invoices removed.')));
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to delete invoices.\n$error';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete All failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        isDeletingAll.value = false;
      }
    }
  }

  String normalizePhone(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    invoices.dispose();
    allInvoices.dispose();
    isInitialLoading.dispose();
    isLoadingMore.dispose();
    isSearching.dispose();
    isDeletingAll.dispose();
    hasMore.dispose();
    errorMessage.dispose();
    searchQuery.dispose();
    super.dispose();
  }
}
