import 'package:isar_community/isar.dart';

part 'health_check_log.g.dart';

@collection
class HealthCheckLog {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  @Index()
  String status = '';

  String message = '';
  String userId = '';
  String userEmail = '';
}
