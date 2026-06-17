import 'package:easy_localization/easy_localization.dart';
import 'package:r99/app.dart';
import 'package:r99/export.dart';

void main() async {
  FlavorConfig(environment: FlavorType.production, name: 'Pro');
  bootstrap(
    () => EasyLocalization(
      supportedLocales: app.supportedLanguages,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      child: const App(),
    ),
  );
}
