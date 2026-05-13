import 'package:r99/export.dart';

abstract class AppEnv {
  const AppEnv();

  String get baseUrl;

  String get socketUrl;

  String get apiPath => '/api/v1';

  String get dinkTalkBotToken => 'b1fd25f9d4cebd89e8b6cf3a529b74088a08639231c5cb8c7f83a494134f04ed';

  String get shareDeepLink;

  String get getBaseUrl {
    final String v = UserStorage.customBaseUrlBox.get(defaultValue: '');
    if (v.isNotEmpty) {
      return v;
    }
    return baseUrl;
  }

  String get getSocketUrl {
    final String v = UserStorage.customSocketUrlBox.get(defaultValue: '');
    if (v.isNotEmpty) {
      return v;
    }
    return socketUrl;
  }
}
