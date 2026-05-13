import 'package:flutter/services.dart';

class AppEnv {
  AppEnv._();

  static final Map<String, String> _values = <String, String>{};

  static Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('.env');
      _values
        ..clear()
        ..addAll(_parse(raw));
    } catch (_) {
      _values.clear();
    }
  }

  static String get googleSheetLink {
    return _values['GOOGLE_SHEET_LINK']?.trim() ?? '';
  }

  static Map<String, String> _parse(String raw) {
    final values = <String, String>{};

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      final value = trimmed.substring(separatorIndex + 1).trim();

      if (key.isEmpty) {
        continue;
      }

      values[key] = value;
    }

    return values;
  }
}
