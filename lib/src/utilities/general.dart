import 'dart:developer';

import 'package:r99/export.dart';
import 'package:chalkdart/chalkstrings.dart';

AppGlobal get app => AppGlobal();

void printInfo(dynamic message, {String? name}) {
  if (kDebugMode) {
    if (app.isAndroidStudio) {
      print('💡 ${((name != null ? '[$name]: ' : '') + message.toString()).blue}');
    } else {
      logSuccess(message.toString(), name: name);
    }
  }
}

void printSuccess(dynamic message, {String? name}) {
  if (kDebugMode) {
    if (app.isAndroidStudio) {
      print('✅ ${chalk.green((name != null ? '[$name]: ' : '') + message.toString())}');
    } else {
      logSuccess(message.toString(), name: name);
    }
  }
}

void printError(dynamic message, {String? name}) {
  if (kDebugMode) {
    if (app.isAndroidStudio) {
      print('❌ ${chalk.red((name != null ? '[$name]: ' : '') + message.toString())}');
    } else {
      logError(message.toString(), name: name);
    }
  }
}

void printWarning(dynamic message, {String? name}) {
  if (kDebugMode) {
    if (app.isAndroidStudio) {
      print('❔ ${chalk.yellow((name != null ? '[$name]: ' : '') + message.toString())}');
    } else {
      logSuccess(message.toString(), name: name);
    }
  }
}

void logInfo(dynamic message, {String? name}) {
  if (kDebugMode) {
    log('💡 $message', name: name ?? '');
  }
}

void logSuccess(dynamic message, {String? name}) {
  if (kDebugMode) {
    log('✅ $message', name: name ?? '');
  }
}

void logError(dynamic message, {String? name}) {
  if (kDebugMode) {
    log('❌ $message', name: name ?? '');
  }
}

void logWarning(dynamic message, {String? name}) {
  if (kDebugMode) {
    log('❔ $message', name: name ?? '');
  }
}
