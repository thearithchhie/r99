import 'package:r99/export.dart';

class EnvLocal extends AppEnv {
  const EnvLocal();

  @override
  String get baseUrl => 'http://192.168.114.183:5053';

  @override
  String get shareDeepLink => '';

  @override
  String get socketUrl => 'ws://localhost:3000';
}
