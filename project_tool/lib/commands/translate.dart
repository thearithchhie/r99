import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/command_runner.dart';
import 'package:chalk/chalk.dart';
import 'package:ff/helpers.dart';
import 'package:translator/translator.dart';

class TranslateCommand extends Command {
  @override
  String get description => 'For working on translation';

  @override
  String get name => 'tr';

  TranslateCommand();

  @override
  void run() async {
    var clipboardValue = await getFromClipboard();

    // Read input
    var englishWord = clipboardValue;
    if (englishWord.isEmpty) {
      englishWord = await getFromClipboard();
    }

    if (englishWord.isEmpty) {
      printWarning('English word was empty, so no adding.');
      return;
    }

    printInfo("Words: ${englishWord.substring(0, min(30, englishWord.length))}${englishWord.length > 30 ? '...' : ''}");

    var key = getExelKey(englishWord);

    final localePath = 'assets/translations/en-US.json';
    final file = File(localePath);

    if (!await file.exists()) {
      print('❌ File not found!');
      return;
    }

    // Read JSON
    final contents = await file.readAsString();
    final Map<String, dynamic> data = jsonDecode(contents);

    // Check and add key
    if (!data.containsKey(key)) {
      data[key] = englishWord;
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      print('✅ Added key "$key" with value "$englishWord".');
    } else {
      print('ℹ️ Key "$key" already exists.');
    }
    await copyToClipboard("'$key'.localize()");
  }
}
