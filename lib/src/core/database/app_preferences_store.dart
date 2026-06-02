import 'package:r99/export.dart';

class AppPreferencesStore {
  const AppPreferencesStore._();

  static Future<bool> loadShowPreview() async {
    final record = await AppDatabase.instance.isar.appPreferences.get(AppPreference.previewVisibilityId);
    return record?.showPreview ?? true;
  }

  static Future<void> saveShowPreview(bool value) async {
    final isar = AppDatabase.instance.isar;
    final record = AppPreference(showPreview: value);
    await isar.writeTxn(() => isar.appPreferences.put(record));
  }
}
