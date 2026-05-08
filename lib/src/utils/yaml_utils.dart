import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Utility functions for YAML file operations.
class YamlUtils {
  /// Reads and parses a YAML file, returning null if not found.
  static YamlMap? readYamlFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return null;
    final content = file.readAsStringSync();
    final yaml = loadYaml(content);
    return yaml is YamlMap ? yaml : null;
  }

  /// Adds a dependency to pubspec.yaml.
  static void addDependency({
    required String pubspecPath,
    required String packageName,
    String? version,
    bool isDev = false,
  }) {
    final file = File(pubspecPath);
    final content = file.readAsStringSync();
    final editor = YamlEditor(content);

    final section = isDev ? 'dev_dependencies' : 'dependencies';
    final value = version ?? 'any';

    editor.update([section, packageName], value);
    file.writeAsStringSync(editor.toString());
  }

  /// Removes a dependency from pubspec.yaml.
  static void removeDependency({
    required String pubspecPath,
    required String packageName,
    bool isDev = false,
  }) {
    final file = File(pubspecPath);
    final content = file.readAsStringSync();
    final editor = YamlEditor(content);

    final section = isDev ? 'dev_dependencies' : 'dependencies';

    try {
      editor.remove([section, packageName]);
      file.writeAsStringSync(editor.toString());
    } on Exception {
      // Package not found in the specified section — ignore.
    }
  }

}
