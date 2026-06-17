import 'package:r99/export.dart';

class FlavorConfig {
  final FlavorType environment;
  final Color color;
  final BannerLocation location;
  final String? name;
  static FlavorConfig? _instance;

  static FlavorConfig? get instance => _instance;

  FlavorConfig._internal(this.environment, this.color, this.location, this.name);

  factory FlavorConfig({
    FlavorType environment = FlavorType.development,
    Color color = Colors.red,
    BannerLocation location = BannerLocation.topEnd,
    String? name,
  }) {
    _instance ??= FlavorConfig._internal(environment, color, location, name);
    return _instance!;
  }
}
