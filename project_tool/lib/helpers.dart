import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chalk/chalk.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;

final _scopes = [drive.DriveApi.driveFileScope];
Map<String, String>? _toolEnvCache;

Future<AutoRefreshingAuthClient> getAuthenticatedClient() async {
  final credentials = await _loadServiceAccountCredentials();

  return await clientViaServiceAccount(credentials, _scopes);
}

Future<ServiceAccountCredentials> _loadServiceAccountCredentials() async {
  final env = await _getToolEnv();
  final encodedJson = env['GOOGLE_SERVICE_ACCOUNT_JSON_BASE64']?.trim() ?? '';
  final rawJson = env['GOOGLE_SERVICE_ACCOUNT_JSON']?.trim() ?? '';

  if (encodedJson.isEmpty && rawJson.isEmpty) {
    throw StateError(
      'Missing Google service account credentials. '
      'Set GOOGLE_SERVICE_ACCOUNT_JSON_BASE64 or GOOGLE_SERVICE_ACCOUNT_JSON '
      'in project_tool/.env or your shell environment.',
    );
  }

  final jsonText = encodedJson.isNotEmpty ? utf8.decode(base64Decode(encodedJson)) : rawJson;
  final decoded = jsonDecode(jsonText);

  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'GOOGLE_SERVICE_ACCOUNT_JSON must decode to a JSON object.',
    );
  }

  final normalized = Map<String, dynamic>.from(decoded);
  final privateKey = normalized['private_key'];
  if (privateKey is String) {
    normalized['private_key'] = privateKey.replaceAll(r'\n', '\n');
  }

  return ServiceAccountCredentials.fromJson(normalized);
}

Future<Map<String, String>> _getToolEnv() async {
  final cached = _toolEnvCache;
  if (cached != null) {
    return cached;
  }

  final env = <String, String>{};
  final envFiles = [
    File('project_tool/.env'),
    File('.env'),
  ];

  for (final file in envFiles) {
    if (!file.existsSync()) {
      continue;
    }

    final content = await file.readAsString();
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final separatorIndex = trimmed.indexOf('=');
      if (separatorIndex <= 0) {
        continue;
      }

      final key = trimmed.substring(0, separatorIndex).trim();
      var value = trimmed.substring(separatorIndex + 1).trim();

      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }

      env[key] = value;
    }
  }

  env.addAll(Platform.environment);
  _toolEnvCache = env;
  return env;
}

Future<void> shareFileWithUser(drive.DriveApi driveApi, String fileId, String yourEmail) async {
  final permission = drive.Permission()
    ..type = 'user'
    ..role = 'reader'
    ..emailAddress = yourEmail;

  await driveApi.permissions.create(permission, fileId);
}

Future<void> deleteAllFiles(drive.DriveApi driveApi, String fileName) async {
  final fileList = await driveApi.files.list();
  final config = await getConfig();

  if (fileList.files == null || fileList.files!.isEmpty) {
    print("No files found.");
    return;
  }

  for (var file in fileList.files!) {
    try {
      if (fileName == file.name) {
        await driveApi.files.delete(file.id!);
        print('🗑️ Deleted file: ${file.name}');
      }
    } catch (e) {
      print('❌ Failed to delete ${file.name}: $e');
    }
  }
}

String addScript(String val, String script) {
  return val.isNotEmpty ? '$val\n$script' : script;
}

Future<String> uploadToDrive(String filePath, [bool isExcel = false]) async {
  final client = await getAuthenticatedClient();
  final driveApi = drive.DriveApi(client);

  final file = File(filePath);
  final fileToUpload = drive.File();
  fileToUpload.name = file.uri.pathSegments.last;
  printInfo(fileToUpload.name);
  fileToUpload.parents = ['1q5jRaDYNNT-SNEYPiWaEweKKHMNMsnjT'];
  await deleteAllFiles(driveApi, file.uri.pathSegments.last);
  final response = await driveApi.files.create(
    fileToUpload,
    uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
  );
  if (response.id != null) {
    if (isExcel) {
      printSuccess('Uploaded Exel file ID: ${response.id}');
      printSuccess('Uploaded Exel path: https://docs.google.com/spreadsheets/d/${response.id}/edit');
    } else {
      printSuccess('Uploaded to drive. file ID: ${response.id}');
    }
    await shareFileWithUser(driveApi, response.id!, 'dvpaytest1@gmail.com');
  }
  client.close();
  return response.id ?? '';
}

Future<void> downloadExcel(String fileId, String savePath) async {
  final client = await getAuthenticatedClient();
  final driveApi = drive.DriveApi(client);

  final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as commons.Media;

  final saveFile = File(savePath);
  final sink = saveFile.openWrite();

  await media.stream.pipe(sink);
  await sink.close();

  printSuccess('Download Exel complete: $savePath');
  client.close();
}

Future copyToClipboard(String value) async {
  await runScript('echo "${value.replaceAll('"', '\\"')}" | tr -d "\n"  | pbcopy', "Added $value to clipboard");
}

Future<String> getFromClipboard() async {
  final process = await Process.start('pbpaste', []);
  final stdoutStream = process.stdout.transform(utf8.decoder);
  var output = [];
  await for (final line in stdoutStream) {
    output.add(line);
  }
  final exitCode = await process.exitCode;
  if (exitCode == 0) {
    return output.join('\n');
  } else {
    throw "Failed to paste";
  }
}

Future replaceFile(Pattern pattern, String Function(Match) replace, String filePath) async {
  final file = File(filePath);
  var fileContent = await file.readAsString();
  fileContent = fileContent.replaceAllMapped(pattern, replace);
  await file.writeAsString(fileContent);
}

Future<String> get getBuildFolder async {
  final config = await getConfig();
  return config['build_settings']['output_path'];
}

String getRandomString(int length) {
  final rnd = Random();
  const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(
        rnd.nextInt(chars.length),
      ),
    ),
  );
}

Future<dynamic> runScript(
  String script,
  String description, {
  bool printExitCode = true,
}) async {
  // printWarning("Running:\n   ${script.split('\n').map((e) => '  $e').join('\n')}");

  // printInfo("Running: $script");

  String? result;
  String scriptContent = '''
#!/bin/bash
${Platform.isLinux ? 'LC_ALL=C;' : ''}
$script
''';

  // Get the system's temporary directory
  Directory tempDir = Directory.systemTemp;

  // Create a new temporary file in the temporary directory
  File tempFile = await File('${tempDir.path}/temp_dart_tool_script_${getRandomString(10)}.sh').create();

  // Write the script to the temporary file
  await tempFile.writeAsString(scriptContent);

  // Make the temporary file executable
  await Process.run('chmod', ['+x', tempFile.path]);

  // Run the script
  Process process = await Process.start(tempFile.path, [], runInShell: true);

  // Stream stdout to console

  process.stdout.transform(utf8.decoder).listen((data) {
    print(data);
    result = data;
  });

  // Stream stderr to console
  process.stderr.transform(utf8.decoder).listen((data) {
    printError(data);
  });

  // Wait for the process to exit
  int exitCode = await process.exitCode;
  if (exitCode == 0) {
    if (description.isNotEmpty) {
      printSuccess("Done $description! ✔");
    }
  } else {
    if (printExitCode) {
      printError('$description returns exit code $exitCode ✘');
    }
  }

  // Delete the temporary file
  if (tempFile.existsSync()) {
    tempFile.deleteSync(recursive: true);
  }

  return exitCode;
}

Future<Map<String, dynamic>> readJsonFile(String path) async {
  final file = File(path);

  if (!await file.exists()) {
    printError('File not found!');
    return {};
  }
  // Read JSON
  final contents = await file.readAsString();
  final Map<String, dynamic> data = jsonDecode(contents);
  return data;
}

String getExcelCell(int columnIndex, int rowIndex) {
  // Convert 1-based columnIndex to Excel letters
  String columnLetters = '';
  int col = columnIndex + 1;

  while (col > 0) {
    int rem = (col - 1) % 26;
    columnLetters = String.fromCharCode(65 + rem) + columnLetters;
    col = (col - 1) ~/ 26;
  }

  return '$columnLetters${rowIndex + 1}';
}

Future<void> exportTR() async {
  final fileJson = File('assets/translations/en-US.json');
  final fileEnum = File('lib/tr.dart');
  if (await fileEnum.exists() && await fileJson.exists()) {
    final content = await fileJson.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);
    List<String> items = [];

    for (var key in data.keys) {
      final enumName = getENumKey(key);
      items.add('  $enumName("${key.replaceAll('\n', r'\n')}")');
    }

    final buffer = StringBuffer();
    buffer.writeln("import 'package:dv_pay_mobile/export.dart';\n");
    buffer.writeln('enum TR {');
    buffer.writeln('${items.join(', \n ')};');
    buffer.writeln('\n  const TR(this.slug);');
    buffer.writeln('  final String slug;\n');
    buffer.writeln('  String r([List<String>? v]) {');
    buffer.writeln('   return slug.localize(v);');
    buffer.writeln('  }');
    buffer.writeln('}');
    await fileEnum.writeAsString(
      buffer.toString(),
      mode: FileMode.write,
    );
  }
}

String getSuggestKey(String englishWord, [bool isSnakeCase = true]) {
  var suggestKey = ReCase(englishWord).camelCase;
  if (suggestKey.length > 30) {
    suggestKey = suggestKey.substring(0, 30);
  }

  suggestKey = suggestKey.replaceAll(RegExp('[^a-zA-Z0-9_]'), '').replaceAll(RegExp('_+'), '-');

  final replaceMap = {
    'please': 'pls',
    'button': 'btn',
  };

  var words = ReCase(suggestKey).sentenceCase.toLowerCase();

  for (var replace in replaceMap.keys) {
    words = words.replaceAll(replace, replaceMap[replace] ?? '');
  }
  if (isSnakeCase) {
    return ReCase(words).snakeCase;
  }
  return ReCase(words).camelCase;
}

String getExelKey(String key) {
  return key.toLowerCase().replaceAll(' ', '_').replaceAll('\n', '');
}

String getENumKey(String key) {
  if (reservedWords.contains(key)) {
    key = '$key{}'; // append underscore if reserved
  }
  var suggestKey = ReCase(key).camelCase;
  suggestKey = suggestKey.replaceAll('__', 'zz').replaceAll('{}', 'zz').replaceAll(RegExp(r'[-:]'), 'zz');
  suggestKey = suggestKey.replaceAll(RegExp('[^a-zA-Z0-9_]'), '').replaceAll(RegExp('_+'), '-');
  suggestKey = ReCase(suggestKey).sentenceCase.toLowerCase();
  suggestKey = ReCase(suggestKey).camelCase;
  suggestKey = suggestKey
      .replaceAll('zz', '_')
      .replaceAll(RegExp(r'[^\w]+'), '') // remove all non-word characters (a-z, A-Z, 0-9, _)
      .replaceAll(RegExp(r'^_+'), '') // remove leading underscores
      .replaceAll(RegExp(r'_+$'), '_'); // ensure only one underscore at the end if any;
  return suggestKey[0].toLowerCase() + suggestKey.substring(1);
}

void printInfo(dynamic message) {
  print('💡 ${chalk.blue(message.toString())}');
}

void printSuccess(dynamic message) {
  print('✅ ${chalk.green(message.toString())}');
}

void printError(dynamic message) {
  print('❌ ${chalk.red(message.toString())}');
}

void printWarning(dynamic message) {
  print('❔${chalk.yellow(message.toString())}');
}

bool isDebug() {
  var debug = false;
  assert(() {
    debug = true;
    return true;
  }());
  return debug;
}

String testablePath(String path) {
  return join(isDebug() ? '../' : '', path);
}

Future<dynamic> getConfig() async {
  final configFile = File(testablePath('ff.yaml'));
  if (!configFile.existsSync()) {
    printError('ff.yaml is not found in the root Flutter project');
    exit(1);
  }
  var doc = loadYaml(configFile.readAsStringSync());
  return doc;
}

Future<dynamic> getPubspec() async {
  final configFile = File(testablePath('pubspec.yaml'));
  if (!configFile.existsSync()) {
    printError('pubspec.yaml is not found in the root Flutter project');
    exit(1);
  }
  var doc = loadYaml(configFile.readAsStringSync());
  return doc;
}

void showTextInFile(Pattern pattern, File file) {
  try {
    var text = findTextInFile(pattern, file);
    print(chalk.green('\n 📁 ') + chalk.blue(file.path));
    print(wrapTextInBox(text));
  } catch (e) {
    if (e is PathNotFoundException) {
      print(chalk.red(' ✗ ') + chalk.yellow('File ${file.path} does not exist!!'));
    } else {
      print(e);
    }
  }
}

String findTextInFile(Pattern pattern, File file) {
  var content = file.readAsStringSync();
  var matches = pattern.allMatches(content);
  if (matches.isEmpty) {
    throw chalk.red('Unable to find pattern /') +
        chalk.yellow(pattern.toString() + chalk.red('/ in ') + chalk.yellow(file.path));
  }
  var match = matches.first;
  return match.group(0)!;
}

String _makeStrings(String char, int count) {
  if (count == 0) {
    return '';
  }
  return List.generate(count, (index) => char).join('');
}

String wrapTextInBox(String text) {
  if (text.isEmpty) {
    text = '(Empty)';
  }

  // Replace tab by 2 spaces
  text = text.replaceAll('\t', '  ');

  // Remove empty line
  var lines = text.split('\n').map((e) => e.trimRight()).toList()..removeWhere((line) => line.isEmpty);

  // Remove margin left
  while (lines.every((line) => line.startsWith(' '))) {
    lines = lines.map((e) => e.substring(1)).toList();
  }

  var maxLength = lines.map((e) => e.length).reduce(max);
  var totalLines = lines.length;

  lines.insert(0, chalk.cyan('╔═${_makeStrings('═', maxLength)}═╗'));
  for (var i = 1; i <= totalLines; i++) {
    lines[i] = chalk.cyan('║ ') +
        chalk.cyan(lines[i], ftFace: ChalkFtFace.bold) +
        _makeStrings(' ', maxLength - lines[i].length) +
        chalk.cyan(' ║');
  }
  lines.add(chalk.cyan('╚═${_makeStrings('═', maxLength)}═╝'));
  return lines.join('\n');
}

// Dart reserved keywords (partial list, add more as needed)
const reservedWords = {
  'abstract',
  'const',
  'continue',
  'default',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'rethrow',
  'return',
  'set',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'while',
  'yield'
};
