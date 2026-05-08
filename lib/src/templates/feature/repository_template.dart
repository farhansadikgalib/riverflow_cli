import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the domain repository interface content for a feature module.
String repositoryTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final entityFile = moduleName.singular.snakeCase;
  return '''
import 'package:dartz/dartz.dart';
import 'package:$projectName/features/$moduleName/domain/entities/$entityFile.dart';
import 'package:$projectName/core/errors/failure.dart';

abstract class ${className}Repository {
  Future<Either<Failure, List<$className>>> getAll();
  Future<Either<Failure, $className>> getById(String id);
  Future<Either<Failure, $className>> create($className entity);
  Future<Either<Failure, $className>> update($className entity);
  Future<Either<Failure, void>> delete(String id);
}
''';
}
