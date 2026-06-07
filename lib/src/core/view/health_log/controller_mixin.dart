import 'package:r99/export.dart';

mixin HealthLogPageControllerMixin on State<HealthLogPage> {
  final isLoading = signal<bool>(true);
  final isClearing = signal<bool>(false);
  final errorMessage = signal<String?>(null);
  final isRemoteSource = signal<bool>(false);
  final logs = signal<List<HealthCheckLog>>([]);

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      var remoteLogs = <HealthCheckLog>[];
      try {
        remoteLogs = await SupabaseHealthCheckLogService.latest();
      } catch (_) {
        remoteLogs = [];
      }
      final nextLogs = remoteLogs.isNotEmpty ? remoteLogs : await HealthCheckLogStore.latest();
      if (!mounted) return;
      isRemoteSource.value = remoteLogs.isNotEmpty;
      logs.value = nextLogs;
    } catch (error) {
      if (!mounted) return;
      errorMessage.value = 'Unable to load health logs.\n$error';
    } finally {
      if (mounted) {
        isLoading.value = false;
      }
    }
  }

  Future<void> clearLogs() async {
    if (isRemoteSource.value || isClearing.value || logs.value.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear logs?'),
        content: const Text('This will remove all local health-check logs.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Clear')),
        ],
      ),
    );

    if (confirmed != true) return;

    isClearing.value = true;

    try {
      await HealthCheckLogStore.clear();
      if (!mounted) return;
      logs.value = [];
    } finally {
      if (mounted) {
        isClearing.value = false;
      }
    }
  }

  void onSelectDestination(AppMenuDestination destination) {
    Navigator.of(context).pop();
    switch (destination) {
      case AppMenuDestination.logs:
        return;
      case AppMenuDestination.printer:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PrinterPage()));
      case AppMenuDestination.textScanner:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TextScannerPage()));
      case AppMenuDestination.invoices:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const InvoiceListPage()));
      case AppMenuDestination.deliveries:
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DeliveryImportPage()));
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    isClearing.dispose();
    errorMessage.dispose();
    isRemoteSource.dispose();
    logs.dispose();
    super.dispose();
  }
}
