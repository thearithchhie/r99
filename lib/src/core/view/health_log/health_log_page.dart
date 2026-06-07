import 'package:r99/export.dart';

class HealthLogPage extends StatefulWidget {
  const HealthLogPage({super.key});

  @override
  State<HealthLogPage> createState() => _HealthLogPageState();
}

class _HealthLogPageState extends State<HealthLogPage>
    with HealthLogPageControllerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppMenuDrawer(
        currentDestination: AppMenuDestination.logs,
        onSelectDestination: onSelectDestination,
      ),
      appBar: HealthLogAppBar(
        isClearing: isClearing,
        isRemoteSource: isRemoteSource,
        logs: logs,
        onRefresh: loadLogs,
        onClear: clearLogs,
      ),
      body: HealthLogWidget(
        isLoading: isLoading,
        errorMessage: errorMessage,
        isRemoteSource: isRemoteSource,
        logs: logs,
        onRefresh: loadLogs,
      ),
    );
  }
}
