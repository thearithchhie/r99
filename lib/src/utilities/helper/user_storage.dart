import 'package:r99/export.dart';

class UserStorage {
  static const String _customBaseUrl = "customBaseUrl";
  static const String _customSocketUrl = "customSocketUrl";

  static Future<void> init() async {}

  static StorageService get customBaseUrlBox {
    return const StorageService(boxName: StorageBox.appBox, key: _customBaseUrl);
  }

  static StorageService get customSocketUrlBox {
    return const StorageService(boxName: StorageBox.appBox, key: _customSocketUrl);
  }
}
