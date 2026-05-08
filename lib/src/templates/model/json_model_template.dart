import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns a Freezed model file content generated from JSON fields.
String jsonModelTemplate({
  required String projectName,
  required String moduleName,
  required String className,
  required Map<String, String> fields,
}) {
  final snakeName = className.snakeCase;
  final pascal = className.pascalCase;
  final entityFile = moduleName.singular.snakeCase;

  final fieldDeclarations = fields.entries
      .map((e) =>
          '    ${_isRequired(e.value) ? 'required ' : ''}${e.value}${_isRequired(e.value) ? '' : '?'} ${e.key},')
      .join('\n');

  final entityMappings =
      fields.entries.map((e) => '      ${e.key}: ${e.key},').join('\n');

  return '''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:$projectName/features/$moduleName/domain/entities/$entityFile.dart';

part '${snakeName}_model.freezed.dart';
part '${snakeName}_model.g.dart';

@freezed
class ${pascal}Model with _\$${pascal}Model {
  const ${pascal}Model._();

  const factory ${pascal}Model({
$fieldDeclarations
  }) = _${pascal}Model;

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) =>
      _\$${pascal}ModelFromJson(json);

  ${moduleName.singular.pascalCase} toEntity() {
    return ${moduleName.singular.pascalCase}(
$entityMappings
    );
  }
}
''';
}

bool _isRequired(String type) {
  return type == 'String' ||
      type == 'int' ||
      type == 'double' ||
      type == 'bool';
}

/// Infers a Dart type from a JSON value.
String inferDartType(dynamic value) {
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is String) return 'String';
  if (value is List) return 'List<dynamic>';
  if (value is Map) return 'Map<String, dynamic>';
  return 'dynamic';
}
