
import 'package:args/command_runner.dart';
import 'package:ff/commands/auto_export.dart';
import 'package:ff/commands/build.dart';
import 'package:ff/commands/compile_tool.dart';
import 'package:ff/commands/translate.dart';
import 'package:ff/commands/translate_file.dart';

void main(List<String> arguments) async {
  // GenerateAssetConstCommand.generateAssetConstants();
  // return;
  try {
    final runner = CommandRunner('ff', 'Command line for this project')
      // ..addCommand(SetAppVersionCommand())
      // ..addCommand(SetAppIdCommand())
      // ..addCommand(SignApkCommand())
      // ..addCommand(SetAppNameCommand())
      // ..addCommand(SetDeeplinkSchemeCommand())
      ..addCommand(BuildProjectCommand())
      ..addCommand(AutoExportCommand())
      //..addCommand(GenerateAssetConstCommand())
      //..addCommand(AddTranslationCommand())
      ..addCommand(CompileToolCommand())
      ..addCommand(TranslateCommand())
      ..addCommand(TranslateFileCommand())
      //..addCommand(MakeAssetCommand())
      //..addCommand(SubmitReleaseCommand())
      //..addCommand(SetEnvironmentCommand());
;
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
  }
}
