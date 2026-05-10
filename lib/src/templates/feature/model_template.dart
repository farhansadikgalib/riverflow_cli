import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the data model file content for a feature module.
String featureModelTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final fileName = moduleName.singular.snakeCase;
  return '''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:$projectName/features/$moduleName/domain/entities/$fileName.dart';

part '${fileName}_model.freezed.dart';
part '${fileName}_model.g.dart';

@freezed
abstract class ${className}Model with _\$${className}Model {
  const ${className}Model._();

  const factory ${className}Model({
    required String id,
    required String name,
    String? description,
    DateTime? createdAt,
  }) = _${className}Model;

  factory ${className}Model.fromJson(Map<String, dynamic> json) =>
      _\$${className}ModelFromJson(json);

  $className toEntity() {
    return $className(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
    );
  }
}
''';
}
