import 'package:r99/src/utilities/extensions/string_extension.dart';

extension DynamicExtension on dynamic {
  String? toAppString({String? defaultVal = ''}) {
    String text = '$this';
    return text == 'null' || text.isEmpty ? defaultVal : text.trim();
  }

  double toAppDouble({double defaultVal = 0.0}) {
    double coNum = defaultVal;
    if (this == null || this == 'null' || this == '' || this == '.') {
      coNum = defaultVal;
    } else {
      final regExp = toString().toAppString()!.replaceAll(',', '').removeDotsExceptFirst(); // r
      coNum = double.tryParse(regExp) ?? defaultVal;
    }
    return coNum;
  }
}
