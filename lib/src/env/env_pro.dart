import 'package:r99/export.dart';

class EnvPro extends AppEnv {
  const EnvPro();

  @override
  String get baseUrl => 'https://htp-mobile-api-uat.vai247.pro';

  @override
  String get shareDeepLink => '';

  @override
  String get socketUrl => 'wss://htp-mobile-api-uat.vai247.pro/api/v1/ws';
}
