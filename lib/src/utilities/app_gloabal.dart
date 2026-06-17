import 'dart:io';

import 'package:r99/export.dart';

class AppGlobal {
  static final AppGlobal _instance = AppGlobal._internal();

  factory AppGlobal() {
    return _instance;
  }

  AppGlobal._internal();

  // IDE Detection
  bool get isAndroidStudio => ide == 'android-studio';
  String get ide {
    if (Platform.environment.containsKey('ANDROID_STUDIO')) {
      return 'android-studio';
    } else if (Platform.environment.containsKey('VSCODE_CWD')) {
      return 'vscode';
    } else {
      return 'unknown';
    }
  }

  // Localization
  final List<Locale> supportedLanguages = [const Locale('en', 'US'), const Locale('zh', 'CN')];
}
