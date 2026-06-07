import 'package:r99/src/core/database/models/health_check_log.dart';
import 'package:r99/src/core/services/supabase_auth_service.dart';

class SupabaseHealthCheckLogService {
  SupabaseHealthCheckLogService._();

  static bool get canRead {
    return SupabaseAuthService.isInitialized &&
        SupabaseAuthService.client.auth.currentSession != null;
  }

  static Future<List<HealthCheckLog>> latest({int limit = 100}) async {
    if (!canRead) {
      return const [];
    }

    final rows = await SupabaseAuthService.client
        .from('health_check_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map<HealthCheckLog>((row) {
      return HealthCheckLog()
        ..createdAt = DateTime.parse(row['created_at'].toString())
        ..status = row['status']?.toString() ?? ''
        ..message = row['message']?.toString() ?? ''
        ..userId = row['source']?.toString() ?? ''
        ..userEmail = row['source']?.toString() ?? '';
    }).toList();
  }
}
