import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:r99/export.dart';

class StorageService {
  const StorageService({required this.boxName, required this.key});

  final StorageBox boxName;
  final String key;

  T? get<T>({dynamic defaultValue}) {
    final box = Hive.box(boxName.name);
    try {
      return box.get(key, defaultValue: defaultValue) as T?;
    } catch (_) {
      return null;
    }
  }
}
