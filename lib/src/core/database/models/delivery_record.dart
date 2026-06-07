import 'package:r99/export.dart';

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
  String shop = ShopType.r99.key;
  int printCount = 0;
  DateTime? lastPrintedAt;
}
