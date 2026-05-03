import 'package:isar_community/isar.dart';

part 'app_preference.g.dart';

@collection
class AppPreference {
  AppPreference({this.id = previewVisibilityId, this.showPreview = true});

  static const int previewVisibilityId = 1;

  Id id;
  bool showPreview;
}
