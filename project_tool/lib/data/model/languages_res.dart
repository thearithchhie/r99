import 'package:yaml/yaml.dart';

class LanguagesRes {
  final String name;
  final String key;
  final String title;

  const LanguagesRes({
    required this.name,
    required this.key,
    required this.title,
  });

  factory LanguagesRes.fromJson(YamlMap json) => LanguagesRes(
        name: json["name"],
        key: json["key"],
        title: json["title"],
      );

  static List<LanguagesRes> fromList(YamlList json) {
    return List.from(json.map((e) => LanguagesRes.fromJson(e)));
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "key": key,
        "title": title,
      };
}
