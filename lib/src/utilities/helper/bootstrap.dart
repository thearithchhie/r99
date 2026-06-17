import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:r99/export.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  void onError(Object error, StackTrace stack) {
    logError('($error, $stack)', name: 'SDK');
  }

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  runZonedGuarded(() async {
    // 👇 Must be first inside the zone
    BindingBase.debugZoneErrorsAreFatal = true;

    // Override HTTPS certificate warning
    HttpOverrides.global = MyHttpOverrides();
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    EasyLocalization.logger.enableLevels = [];
    // Open local database,
    await AppDatabase.instance.open();
    // Load environment variables
    await AppLoadEnv.load();
    // Initialize Supabase Auth Service
    await SupabaseAuthService.initialize();

    // await StorageSecure.init();

    // await generateEncryptionKey();
    await _setUpHive();
    await UserStorage.init();
    // app.devicePreviewNotifier.value = UserStorage.getDevicePreviewEnabled();

    // Set environment based on flavor
    // setOrientation();
    // await DeviceInfoHelper.init();
    // await AppPackageInfo.init();
    // await AppConnectivity.init();
    // await AppTimezone.init();
    // await BiometricHelper.init();
    //NoScreenshot.instance;
    // Initialize Firebase
    // await UserStorage.forceFilterLogs();
    // await app.initializeEncryption();
    runApp(await builder());
  }, onError);
}

Future<void> _setUpHive() async {
  await Hive.initFlutter();

  for (final box in StorageBox.values) {
    if (!Hive.isBoxOpen(box.name)) {
      await Hive.openBox(box.name);
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
