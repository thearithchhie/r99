import 'package:isar_community/isar.dart';

part 'delivery_record.g.dart';

@collection
class DeliveryRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime importedAt;

  String sourceUrl = '';
  String customerName = '';
  String phone = '';
  String location = '';
  String price = '';
  String deliverService = '';
  String shop = 'shop';
  int printCount = 0;
  DateTime? lastPrintedAt;
}
