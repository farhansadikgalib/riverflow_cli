import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the entity file content for a feature module.
String entityTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final fileName = moduleName.singular.snakeCase;
  return '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '$fileName.freezed.dart';

@freezed
class $className with _\$$className {
  const factory $className({
    required String id,
    required String name,
    String? description,
    DateTime? createdAt,
  }) = _$className;
}
''';
}
