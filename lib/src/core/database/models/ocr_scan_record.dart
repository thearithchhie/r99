import 'package:isar_community/isar.dart';

part 'ocr_scan_record.g.dart';

@collection
class OcrScanRecord {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime createdAt;

  String? imagePath;

  String extractedText = '';
}
