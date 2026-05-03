import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:r99/src/core/database/models/app_preference.dart';
import 'package:r99/src/core/database/models/ocr_scan_record.dart';
import 'package:r99/src/core/database/models/print_invoice.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Isar? _isar;

  Isar get isar {
    final db = _isar;
    if (db == null) {
      throw StateError('Isar has not been opened yet.');
    }
    return db;
  }

  Future<Isar> open() async {
    if (_isar != null) {
      return _isar!;
    }

    final directory = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [AppPreferenceSchema, OcrScanRecordSchema, PrintInvoiceSchema],
      directory: directory.path,
      name: 'r99',
    );
    return _isar!;
  }

  Future<void> close() async {
    final db = _isar;
    if (db == null || !db.isOpen) {
      return;
    }

    await db.close();
    _isar = null;
  }
}
