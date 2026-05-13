import 'package:r99/export.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class UserStorage {
  /// box
  static late final Box _appHivBox;
  static late final Box _authHivBox;

  ///============================ auth Box Start====================================
  /// Using to storing only data for authentication.
  ///
  /// auth storage key
  ///
  static const String _customBaseUrl = "customBaseUrl";
  static const String _customSocketUrl = "customSocketUrl";

  static Future<void> init() async {
    _appHivBox = Hive.box(StorageBox.appBox.name);
    _authHivBox = Hive.box(StorageBox.authBox.name);
  }

  static StorageService get customBaseUrlBox {
    return const StorageService(boxName: StorageBox.appBox, key: _customBaseUrl);
  }

  static StorageService get customSocketUrlBox {
    return const StorageService(boxName: StorageBox.appBox, key: _customSocketUrl);
  }
}
