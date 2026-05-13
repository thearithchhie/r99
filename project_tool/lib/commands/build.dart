import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ff/helpers.dart';

class BuildProjectCommand extends Command {
  @override
  String get description => 'Using for building apk and ipa files.';

  @override
  String get name => 'build';

  BuildProjectCommand() {
    argParser.addFlag('firebase', abbr: 'f', defaultsTo: false, help: 'upload app to firebase distribute');
    argParser.addFlag('patch', abbr: 'p', defaultsTo: false, help: 'upload app to firebase distribute');
    argParser.addFlag('no', abbr: 'n', defaultsTo: false, help: 'upload app to firebase distribute');
  }

  @override
  void run() async {
    final config = await getConfig();
    final pubspec = await getPubspec();
    bool firebase = argResults?['firebase'];
    bool patch = argResults?['patch'];
    bool no = argResults?['no'];
    final bool android = config['build_settings']['platforms']?.contains('android') ?? false;
    final bool ios = config['build_settings']['platforms']?.contains('ios') ?? false;
    final buildDirectoryPath = config['build_settings']['output_path'];
    final distributeIdAndroid = config['build_settings']['distribute']['id']['android'];
    final distributeIdIod = config['build_settings']['distribute']['id']['ios'];
    final distributeGroup = config['build_settings']['distribute']['group'];
    final flavor = config['build_settings']['flavor'];
    String env = 'SIT';
    final flutterVersion = config['build_settings']['flutter_version'];
    final artifact = config['build_settings']['artifact'];
    final exportMethod = config['build_settings']['export_method'];
    final appName = config['build_settings']['name'];

    switch (flavor) {
      case 'production':
        env = 'PRO';
        break;
      case 'staging':
        env = 'UAT';
        break;
    }

    if (!ios && !android) {
      print('Please specify a platform');
      return;
    }

    String script = '';

    final buildDirectory = Directory(buildDirectoryPath);

    String name = appName + '_' + env + '_' + pubspec['version'];

    String flavorC = '--target lib/main_$flavor.dart --flavor $flavor';
    String artifactC = '--artifact=$artifact';
    String flutterSdkC = '--flutter-version=$flutterVersion';

    script = addScript(script, '''
# --- Define functions first ---

echo_red() {
  local text="\$1"
  echo "\\033[31m❌ \${text}\\033[0m"
}

echo_green() {
  local text="\$1"
  echo "\\033[32m✅ \${text}\\033[0m"
}

echo_blue() {
  local text="\$1"
  echo "\\033[34m💡 \${text}\\033[0m"
}

# --- Then use them ---
''');

    script = addScript(script, '''
echo_blue "$flavor ($env) | ${pubspec['version']}"
read -p "Press Enter to continue..."
echo_blue "Start Building...."
''');

    // Clean output folder
    if (buildDirectory.existsSync()) {
      if (!patch) {
        if (android) {
          await runScript('rm $buildDirectoryPath/*.$artifact', 'Clear old build');
        }
        if (ios) {
          await runScript('rm $buildDirectoryPath/*.ipa', 'Clear old build');
        }
      }
    } else {
      await buildDirectory.create(recursive: true);
    }

    if (android) {
      if (!patch) {
        /// flutter build apk --release
        if (!no) {
          script = addScript(script, '''
shorebird release android $artifactC $flutterSdkC $flavorC -- --no-tree-shake-icons
cp build/app/outputs/flutter-apk/app-$flavor-release.$artifact ${buildDirectory.path}/$name.$artifact
''');
        } else {
          script = addScript(script, '''
flutter build apk --release $flavorC --split-per-abi
cp build/app/outputs/flutter-apk/app-arm64-v8a-$flavor-release.$artifact ${buildDirectory.path}/$name.$artifact
''');
        }
        if (firebase && (distributeIdAndroid?.isNotEmpty ?? false)) {
          script = addScript(script, '''
firebase appdistribution:distribute ${buildDirectory.path}/$name.apk --app "$distributeIdAndroid" --groups "${distributeGroup ?? ''}" --release-notes ""
''');
        }
      } else {
        script = addScript(script, '''
 shorebird patch --platforms=android $flavorC --release-version=latest -- --no-tree-shake-icons
''');
      }
    }

    if (ios) {
      if (!patch) {
        /// flutter build ipa  --release --export-method=ad-hoc  --obfuscate --split-debug-info=any/path
        if (!no) {
          script = addScript(script, '''
shorebird release ios --export-method=$exportMethod $flutterSdkC $flavorC -- --no-tree-shake-icons
cp build/ios/ipa/*.ipa ${buildDirectory.path}/$name.ipa
''');
        } else {
          script = addScript(script, '''
flutter build ipa --release $flavorC --export-method=$exportMethod --obfuscate --split-debug-info=any/path
cp build/ios/ipa/*.ipa ${buildDirectory.path}/$name.ipa
''');
        }
        if (firebase && (distributeIdIod?.isNotEmpty ?? false)) {
          script = addScript(script, '''
firebase appdistribution:distribute ${buildDirectory.path}/$name.ipa --app "$distributeIdIod" --groups "${distributeGroup ?? ''}" --release-notes ""
''');
        }
      } else {
        script = addScript(script, '''
 shorebird patch --platforms=ios $flavorC --release-version=latest -- --no-tree-shake-icons
''');
      }
    }
    // Set file name
        script = addScript(script, '''
echo_blue "Build and copy complete!"
''');
    final scriptFile = File(buildDirectoryPath + '/script.sh');

    // Write the content to the file
    await scriptFile.writeAsString(script);
    printSuccess('${scriptFile.path} is created');
    printInfo('sh ${scriptFile.path}');
    copyToClipboard('sh ${scriptFile.path}');
  }
}
