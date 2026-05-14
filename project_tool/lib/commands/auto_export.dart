import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:args/command_runner.dart';
import 'package:ff/helpers.dart';
import 'package:path/path.dart';

class SerializableCapture {
  List<String> serializableClasses = [];
  List<String> hiveClasses = [];

  scan(FileSystemEntity fsEntity) async {
    try {
      if (fsEntity is File) {
        final parsedUnitResult = parseFile(
          path: fsEntity.absolute.path.replaceAll(RegExp("[^/]+/\\.\\./"), ''),
          featureSet: FeatureSet.latestLanguageVersion(),
        );
        final unit = parsedUnitResult.unit;

        for (var declaration in unit.declarations.whereType<ClassDeclaration>()) {
          for (var constructor in declaration.members.whereType<ConstructorDeclaration>()) {
            // Check if it's a factory constructor with 'fromJson'
            if (constructor.factoryKeyword != null && constructor.name.toString() == 'fromJson') {
              serializableClasses.add(declaration.name.toString());
              break;
            }
          }

          var hasHiveTypeAnnotation = declaration.metadata.any((annotation) => annotation.name.name == 'HiveType');

          if (hasHiveTypeAnnotation) {
            hiveClasses.add(declaration.name.toString());
          }
        }
      }
    } catch (e) {
      // Fallback: use regex when AST parsing fails (e.g. experimental Dart syntax like dot-shorthands)
      if (fsEntity is File) {
        final content = (fsEntity as File).readAsStringSync();
        final hiveTypeRegex = RegExp(r'@HiveType\s*\([^)]*\)\s+class\s+(\w+)');
        for (final match in hiveTypeRegex.allMatches(content)) {
          hiveClasses.add(match.group(1)!);
        }
        final fromJsonRegex = RegExp(r'factory\s+(\w+)\.fromJson\s*\(');
        for (final match in fromJsonRegex.allMatches(content)) {
          serializableClasses.add(match.group(1)!);
        }
      }
      printWarning("File ${fsEntity.path} can't be fully parsed, used regex fallback 💡");
    }
  }

  writeSerializeFile() async {
    var controlFlows = serializableClasses
        .map(
          (e) => '''if (T == $e) {
      return $e.fromJson(json) as T;
    }''',
        )
        .join(' else ');

    var serializeCode = '''
part of 'serializer.dart';

T? deserializeType<T>(dynamic json) {
  var types = [${serializableClasses.join(',')}];
  if (types.contains(T)) {
    $controlFlows
  }
  return null;
}
      ''';

    var serializeFile = File(testablePath('lib/src/utilities/helper/serializer.gen.dart'));
    await serializeFile.writeAsString(serializeCode, mode: FileMode.write);
  }

  writeAdapterFile() async {
    var content = '''part of 'bootstrap.dart';

void _registerHiveModelAdapters() {
${hiveClasses.map((e) => '  Hive.registerAdapter(${e}Adapter());').join('\n')}
}
''';

    var bootstrapFile = File(testablePath('lib/src/utilities/helper/bootstrap.gen.dart'));
    await bootstrapFile.writeAsString(content, mode: FileMode.write);
  }
}

class AutoExportCommand extends Command {
  @override
  String get description => 'Auto export dart files';

  @override
  String get name => 'auto-export';

  AutoExportCommand() {
    // argParser.addOption('root-path',
    //     defaultsTo: './', abbr: 'p', help: 'Root directory of flutter project');
  }

  scanFolder(Directory directory, {bool isLib = false, required SerializableCapture capture}) async {
    var files = <String>[];
    for (var fsEntity in (await directory.list().toList())) {
      if (fsEntity.path.endsWith('.dart')) {
        if (!isLib) {
          const excludedFiles = [
            'url_strategy_web.dart',
            'url_strategy_stub.dart',
            'http_overrides_stub.dart',
            'http_overrides_io.dart',
            'http_overrides.dart',
            'web_view_web.dart',
            'web_view_builder.dart',
          ];
          final isPartOf = fsEntity is File &&
              (fsEntity as File).readAsStringSync().contains(RegExp(r'^\s*part\s+of\s', multiLine: true));
          if (![
                '_.dart',
                '.g.dart',
                '.gen.dart',
                '.freezed.dart',
                '.part.dart',
              ].any((suffix) => fsEntity.path.endsWith(suffix)) &&
              !excludedFiles.contains(basename(fsEntity.path)) &&
              !isPartOf) {
            files.add(basename(fsEntity.path));
            await capture.scan(fsEntity);
          }
        }
      } else if (fsEntity is Directory) {
        await scanFolder(fsEntity, capture: capture);
        if (File(join(fsEntity.path, '_.dart')).existsSync()) {
          files.add(join(basename(fsEntity.path), '_.dart'));
        }
      }
    }
    files = files.map((e) => "export '${e.replaceAll('\\', '/')}';").toList();
    late File exportFile;
    if (isLib) {
      final preImports = [
        'export "package:flutter/material.dart";',
        'export "package:flutter/foundation.dart" show kDebugMode;',
        'export "dart:io" show File;',
        // 'export "package:flutter_bloc/flutter_bloc.dart";',
        'export "package:signals_flutter/signals_flutter.dart";',
        'export "package:isar_community/isar.dart";',
        'export "package:awesome_extensions/awesome_extensions.dart";',
        'export "package:r99/gen/assets.gen.dart";',
      ];
      files.insertAll(0, preImports);
      exportFile = File(join(directory.path, 'export.dart'));
    } else {
      exportFile = File(join(directory.path, '_.dart'));
    }
    if (files.isNotEmpty) {
      await exportFile.writeAsString('${files.map((e) => e).join('\n')}\n', mode: FileMode.write);
    }
  }

  @override
  void run() async {
    final libFolder = Directory(testablePath('lib'));
    if (libFolder.existsSync()) {
      var capture = SerializableCapture();
      await scanFolder(libFolder, isLib: true, capture: capture);

      await capture.writeSerializeFile();
      await capture.writeAdapterFile();
    }
    printSuccess('Export completed!');
  }
}
