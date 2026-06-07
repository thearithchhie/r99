import 'package:isar_community/isar.dart';
import 'package:r99/src/core/database/app_database.dart';
import 'package:r99/src/core/database/models/health_check_log.dart';

class HealthCheckLogStore {
  const HealthCheckLogStore._();

  static Future<void> save({
    required String status,
    required String message,
    String userId = '',
    String userEmail = '',
  }) async {
    final log = HealthCheckLog()
      ..createdAt = DateTime.now()
      ..status = status
      ..message = message
      ..userId = userId
      ..userEmail = userEmail;

    await AppDatabase.instance.isar.writeTxn(() async {
      await AppDatabase.instance.isar.healthCheckLogs.put(log);
    });
  }

  static Future<DateTime?> latestSuccessfulCheckAt() async {
    final log = await AppDatabase.instance.isar.healthCheckLogs
        .where()
        .statusEqualTo('success')
        .sortByCreatedAtDesc()
        .findFirst();

    return log?.createdAt;
  }

  static Future<List<HealthCheckLog>> latest({int limit = 100}) {
    return AppDatabase.instance.isar.healthCheckLogs
        .where()
        .anyCreatedAt()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  static Future<void> clear() async {
    await AppDatabase.instance.isar.writeTxn(() async {
      await AppDatabase.instance.isar.healthCheckLogs.clear();
    });
  }
}
