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
    final dynamic jsonData = jsonDecode(jsonString);

    if (jsonData is! Map<String, dynamic>) {
      progress.fail('JSON root must be an object');
      return;
    }

    // Infer fields from JSON
    final fields = <String, String>{};
    for (final entry in jsonData.entries) {
      fields[entry.key] = inferDartType(entry.value);
    }

    final className = moduleName.singular.pascalCase;
    final snakeName = moduleName.singular.snakeCase;

    final content = jsonModelTemplate(
      projectName: projectName,
      moduleName: moduleName,
      className: className,
      fields: fields,
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
}
