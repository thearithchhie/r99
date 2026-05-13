import 'package:r99/export.dart';

class EnvDev extends AppEnv {
  const EnvDev();

  @override
  String get baseUrl => 'https://htp-mobile-api.vai247.pro';

  @override
  String get shareDeepLink => '';

  @override
  String get socketUrl => 'wss://htp-mobile-api.vai247.pro$apiPath/ws';
}
