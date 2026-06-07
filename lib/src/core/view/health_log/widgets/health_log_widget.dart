import 'package:r99/export.dart';

class HealthLogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HealthLogAppBar({
    super.key,
    required this.isClearing,
    required this.isRemoteSource,
    required this.logs,
    required this.onRefresh,
    required this.onClear,
  });

  final Signal<bool> isClearing;
  final Signal<bool> isRemoteSource;
  final Signal<List<HealthCheckLog>> logs;
  final VoidCallback onRefresh;
  final VoidCallback onClear;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Health Logs'),
      actions: [
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_outlined),
        ),
        Watch(
          (context) => IconButton(
            onPressed:
                isRemoteSource.value || isClearing.value || logs.value.isEmpty
                ? null
                : onClear,
            icon: const Icon(Icons.delete_outline),
          ),
        ),
      ],
    );
  }
}

class HealthLogWidget extends StatelessWidget {
  const HealthLogWidget({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.isRemoteSource,
    required this.logs,
    required this.onRefresh,
  });

  final Signal<bool> isLoading;
  final Signal<String?> errorMessage;
  final Signal<bool> isRemoteSource;
  final Signal<List<HealthCheckLog>> logs;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColor.errorText),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onRefresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (logs.value.isEmpty) {
        return const Center(child: Text('No health-check logs yet.'));
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            HealthLogSourceCard(isRemoteSource: isRemoteSource.value),
            const SizedBox(height: 8),
            for (final log in logs.value) HealthLogCard(log: log),
          ],
        ),
      );
    });
  }
}

class HealthLogSourceCard extends StatelessWidget {
  const HealthLogSourceCard({super.key, required this.isRemoteSource});

  final bool isRemoteSource;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.surfaceMuted,
      child: ListTile(
        leading: Icon(
          isRemoteSource
              ? Icons.cloud_done_outlined
              : Icons.phone_iphone_outlined,
        ),
        title: Text(
          isRemoteSource
              ? 'Showing Supabase cron logs'
              : 'Showing local app logs',
        ),
        subtitle: Text(
          isRemoteSource
              ? 'These logs are written by the server cron job.'
              : 'Run the Supabase SQL cron setup to view server cron logs here.',
        ),
      ),
    );
  }
}

class HealthLogCard extends StatelessWidget {
  const HealthLogCard({super.key, required this.log});

  final HealthCheckLog log;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (log.status) {
      'success' => Colors.green,
      'failed' => AppColor.errorText,
      _ => AppColor.neutral500,
    };

    return Card(
      child: ListTile(
        leading: Icon(
          log.status == 'success'
              ? Icons.check_circle_outline
              : log.status == 'failed'
              ? Icons.error_outline
              : Icons.pause_circle_outline,
          color: statusColor,
        ),
        title: Text(
          log.status.toUpperCase(),
          style: TextStyle(color: statusColor, fontWeight: FontWeight.w800),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.createdAt.toLocal().toString().substring(0, 19)),
            if (log.userEmail.isNotEmpty) Text(log.userEmail),
            Text(log.message),
          ],
        ),
      ),
    );
  }
}
