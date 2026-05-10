import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/templates/model/json_model_template.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Generates a Freezed model from a JSON file.
class JsonToFreezed {
  const JsonToFreezed({required this.logger, this.dryRun = false});

  final CliLogger logger;
  final bool dryRun;

  Future<void> generate({
    required String moduleName,
    required String jsonPath,
    required String projectName,
  }) async {
    final file = File(jsonPath);
    if (!file.existsSync()) {
      logger.err('JSON file not found: $jsonPath');
      return;
    }

    final progress = logger.progress('Generating model from JSON');

    final jsonString = file.readAsStringSync();
    final dynamic jsonData;
    try {
      jsonData = jsonDecode(jsonString);
    } on FormatException catch (e) {
      progress.fail('Invalid JSON: ${e.message}');
      return;
    }

    if (jsonData is! Map<String, dynamic>) {
      progress.fail('JSON root must be an object');
      return;
    }

    final className = moduleName.singular.pascalCase;
    final snakeName = moduleName.singular.snakeCase;

    // Recursively collect all class definitions (root + nested).
    final classes = <ClassDefinition>[];
    _collectClasses(jsonData, className, classes, isRoot: true);

    final content = jsonModelTemplate(
      projectName: projectName,
      moduleName: moduleName,
      className: className,
      classes: classes,
    );

    final filePath = p.join(
      'lib',
      'features',
      moduleName,
      'data',
      'models',
      '${snakeName}_model.dart',
    );

    await FileUtils.createFile(
      filePath: filePath,
      content: content,
      logger: logger,
      dryRun: dryRun,
    );

    progress.complete('Model generated from JSON!');
  }

  /// Recursively walks [json] and appends [ClassDefinition]s to [classes].
  ///
  /// The root class is always appended first so it ends up at index 0.
  void _collectClasses(
    Map<String, dynamic> json,
    String className,
    List<ClassDefinition> classes, {
    bool isRoot = false,
  }) {
    final fields = <String, String>{};
    final jsonKeys = <String, String>{};

    for (final entry in json.entries) {
      final originalKey = entry.key;
      final dartFieldName = _toDartFieldName(originalKey);

      // Track the original key when it differs from the Dart field name.
      if (dartFieldName != originalKey) {
        jsonKeys[dartFieldName] = originalKey;
      }

      final value = entry.value;
      fields[dartFieldName] = inferDartType(value, dartFieldName);

      // Recurse into nested objects.
      if (value is Map<String, dynamic>) {
        _collectClasses(
          value,
          dartFieldName.pascalCase,
          classes,
        );
      }

      // Recurse into lists of objects.
      if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
        _collectClasses(
          value.first as Map<String, dynamic>,
          dartFieldName.singular.pascalCase,
          classes,
        );
      }
    }

    if (isRoot) {
      classes.insert(0, ClassDefinition(
        className: className,
        fields: fields,
        jsonKeys: jsonKeys,
      ));
    } else {
      classes.add(ClassDefinition(
        className: className,
        fields: fields,
        jsonKeys: jsonKeys,
      ));
    }
  }

  /// Converts a JSON key to a valid camelCase Dart field name.
  ///
  /// `"created_at"` → `"createdAt"`, `"name"` → `"name"`.
  String _toDartFieldName(String key) {
    if (!key.contains('_') && !key.contains('-')) return key;
    return key.camelCase;
  }
}
