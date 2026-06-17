import 'package:r99/export.dart';

class FlavorBanner extends StatelessWidget {
  const FlavorBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (FlavorConfig.instance!.environment == FlavorType.production) {
      return child;
    } else {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Banner(
          message: FlavorConfig.instance?.name ?? '',
          location: FlavorConfig.instance!.location,
          color: FlavorConfig.instance!.color,
          child: child,
        ),
      );
    }
  }
}
