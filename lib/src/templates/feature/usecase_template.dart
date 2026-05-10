import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the use case file content for a feature module.
String usecaseTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final repoFile = moduleName.singular.snakeCase;
  final entityFile = moduleName.singular.snakeCase;
  return '''
import 'package:$projectName/features/$moduleName/domain/entities/$entityFile.dart';
import 'package:$projectName/features/$moduleName/domain/repositories/${repoFile}_repository.dart';
import 'package:$projectName/core/errors/failure.dart';

class Get${className}sUseCase {
  const Get${className}sUseCase(this._repository);

  final ${className}Repository _repository;

  Future<(List<$className>?, Failure?)> call() {
    return _repository.getAll();
  }
}

class Get${className}ByIdUseCase {
  const Get${className}ByIdUseCase(this._repository);

  final ${className}Repository _repository;

  Future<($className?, Failure?)> call(String id) {
    return _repository.getById(id);
  }
}
''';
}
