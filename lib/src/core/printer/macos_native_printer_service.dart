import 'package:flutter/services.dart';
import 'package:r99/src/print_template_data.dart';

class MacOSNativePrinterService {
  const MacOSNativePrinterService._();

  static const String nativeIdentifierPrefix = 'macos-native:';
  static const MethodChannel _channel = MethodChannel(
    'r99/macos_native_printer',
  );

  static Future<List<String>> listPrinters() async {
    final result = await _channel.invokeMethod<List<Object?>>('listPrinters');
    if (result == null) {
      return const [];
    }

    return result.whereType<String>().toList();
  }

  static Future<void> printImage({
    required String printerName,
    required Uint8List imageBytes,
  }) {
    return _channel.invokeMethod<void>('printImage', {
      'printerName': printerName,
      'imageBytes': imageBytes,
    });
  }

  static Future<void> printTemplate({
    required String printerName,
    required PrintTemplateData data,
  }) {
    return _channel.invokeMethod<void>('printTemplate', {
      'printerName': printerName,
      'template': data.toMacOSPrintMap(),
    });
  }

  static bool isNativeIdentifier(String identifier) {
    return identifier.startsWith(nativeIdentifierPrefix);
  }

  static String buildIdentifier(String printerName) {
    return '$nativeIdentifierPrefix$printerName';
  }
}
