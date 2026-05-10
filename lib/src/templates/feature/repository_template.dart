import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the domain repository interface content for a feature module.
String repositoryTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final entityFile = moduleName.singular.snakeCase;
  return '''
import 'package:$projectName/features/$moduleName/domain/entities/$entityFile.dart';
import 'package:$projectName/core/errors/failure.dart';

abstract class ${className}Repository {
  Future<(List<$className>?, Failure?)> getAll();
  Future<($className?, Failure?)> getById(String id);
  Future<($className?, Failure?)> create($className entity);
  Future<($className?, Failure?)> update($className entity);
  Future<(bool, Failure?)> delete(String id);
}
''';
}
