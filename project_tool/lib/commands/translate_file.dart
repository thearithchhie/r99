import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:excel/excel.dart';
import 'package:ff/helpers.dart';
import 'package:ff/data/model/languages_res.dart';

class TranslateFileCommand extends Command {
  @override
  String get description => 'Translate File Command';

  @override
  String get name => 'tr-file';

  TranslateFileCommand() {
    argParser.addOption('type', abbr: 't', defaultsTo: null, help: 'Type: export, import');
  }

  @override
  void run() async {
    final config = await getConfig();
    final type = argResults?['type'] ?? '';
    final lang = LanguagesRes.fromList(config['locale']['languages']);
    if (type == 'export') {
      Map<LanguagesRes, Map<String, dynamic>> data = {};
      for (var l in lang) {
        data[l] = await readJsonFile('assets/translations/${l.name}.json');
      }
      jsonToExcel(data, config['build_settings']['output_path'] + '/' + config['locale']['file_exel']);
    } else if (type == 'import') {
      exelToJson(lang);
    }
  }

  Future<void> exelToJson(List<LanguagesRes> lang) async {
    final config = await getConfig();
    final file = File(config['build_settings']['output_path'] + '/' + config['locale']['file_exel_import']);
    if (!await file.exists()) {
      return;
    }
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    final Map<String, Map<String, dynamic>> jsonMap = {};

    // Read first sheet
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet != null) {
      int i = 0;
      for (var row in sheet.rows) {
        if (row.length >= 2 && row[0] != null && row[0]!.value != null) {
          if (i > 1) {
            final key = row[0]!.value.toString().trim();
            // Skip empty rows (trailing empty rows in Excel)
            if (key.isEmpty) {
              i += 1;
              continue;
            }
            if (row[0]!.value is! FormulaCellValue) {
              for (var l in lang) {
                try {
                  final index = lang.indexWhere((i) => i == l);
                  final columnIndex = index + 1;

                  // Check if the cell exists and is not null
                  if (columnIndex >= row.length) {
                    throw Exception(
                      'Column ${columnIndex + 1} (${l.name}) is missing in Excel row ${i + 1}. Expected ${lang.length + 1} columns but row has ${row.length} columns.',
                    );
                  }

                  final cell = row[columnIndex];
                  if (cell == null || cell.value == null) {
                    throw Exception(
                      'Cell at row ${i + 1}, column ${columnIndex + 1} (${l.name}) is null or empty in Excel file.',
                    );
                  }

                  final v = cell.value.toString();
                  if (jsonMap[l.name]?.isEmpty ?? true) {
                    jsonMap[l.name] = {key: v};
                  } else {
                    jsonMap[l.name]![key] = v;
                  }
                } catch (e) {
                  printError('Error processing Excel row ${i + 1}, key "$key", language "${l.name}": $e');
                  rethrow;
                }
              }
            }
          }
        }
        i += 1;
      }
      for (var l in lang) {
        await writeJsonFile(l.name, jsonMap);
      }
    }
  }

  Future<void> writeJsonFile(String type, Map<String, Map<String, dynamic>> data) async {
    final localePath = 'assets/translations/$type.json';
    final file = File(localePath);

    if (!await file.exists()) {
      printError('File not found!');
      return;
    }
    if (data[type]?.entries.isEmpty ?? true) {
      return;
    }

    Map<String, dynamic> jsonMap = {};
    data.entries.first.value.forEach((key, value) {
      jsonMap[key] = data[type]![key];
    });

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonMap));
    printSuccess('JSON imported to $localePath');
  }

  Future<void> jsonToExcel(Map<LanguagesRes, Map<String, dynamic>> jsonMap, String filePath) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Header row
    sheet.appendRow([
      TextCellValue('Key'),
      ...List.from(jsonMap.entries.map((e) => TextCellValue((e.key.title) ?? ''))),
    ]);
    sheet.appendRow([
      FormulaCellValue('SUBSTITUTE(LOWER(B2), " ", "_")'),
      ...List.from(
        jsonMap.entries.map((e) {
          final index = jsonMap.entries.toList().indexWhere((i) => i.key == e.key);
          if (index == 0) {
            return TextCellValue('sample');
          }
          return FormulaCellValue('GOOGLETRANSLATE(B2, "en", "${e.key.key}")');
        }),
      ),
    ]);

    // Add rows from the map
    jsonMap.entries.first.value.forEach((key, value) {
      sheet.appendRow([
        TextCellValue(key),
        ...List.from(
          jsonMap.entries.map((e) {
            String val = (e.value[key]) ?? '';
            if (val.isEmpty) {
              //final column = jsonMap.entries.toList().indexWhere((c) => c.key == e.key);
              final row = jsonMap.entries.first.value.entries.toList().indexWhere((c) {
                return c.key == key;
              });
              return FormulaCellValue('GOOGLETRANSLATE(${getExcelCell(1, row + 2)}, "en", "${e.key.key}")');
            }
            return TextCellValue(val);
          }),
        ),
      ]);
    });

    // Save to file
    final fileBytes = excel.encode();
    if (fileBytes != null) {
      final file = File(filePath);
      file.createSync(recursive: true);
      file.writeAsBytesSync(fileBytes);
      printSuccess('Excel exported saved at: $filePath');
      //await uploadToDrive(filePath, true);
      //await downloadExcel('1aykpn4zyHmaKbBrjM9KEy3oeNMb1V84x', 'output/localization-import.xlsx');
    }
  }
}
