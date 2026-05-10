import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the repository implementation file content for a feature module.
String repositoryImplTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final snakeName = moduleName.singular.snakeCase;
  return '''
import 'package:dio/dio.dart';
import 'package:$projectName/features/$moduleName/data/datasources/${snakeName}_remote_datasource.dart';
import 'package:$projectName/features/$moduleName/domain/entities/$snakeName.dart';
import 'package:$projectName/features/$moduleName/domain/repositories/${snakeName}_repository.dart';
import 'package:$projectName/core/errors/failure.dart';

class ${className}RepositoryImpl implements ${className}Repository {
  const ${className}RepositoryImpl(this._remoteDatasource);

  final ${className}RemoteDatasource _remoteDatasource;

  @override
  Future<(List<$className>?, Failure?)> getAll() async {
    try {
      final models = await _remoteDatasource.getAll();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on DioException catch (e) {
      return (null, Failure.server(
        message: e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<($className?, Failure?)> getById(String id) async {
    try {
      final model = await _remoteDatasource.getById(id);
      return (model.toEntity(), null);
    } on DioException catch (e) {
      return (null, Failure.server(
        message: e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<($className?, Failure?)> create($className entity) async {
    try {
      final model = await _remoteDatasource.create({
        'name': entity.name,
        'description': entity.description,
      });
      return (model.toEntity(), null);
    } on DioException catch (e) {
      return (null, Failure.server(
        message: e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<($className?, Failure?)> update($className entity) async {
    try {
      final model = await _remoteDatasource.update(entity.id, {
        'name': entity.name,
        'description': entity.description,
      });
      return (model.toEntity(), null);
    } on DioException catch (e) {
      return (null, Failure.server(
        message: e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    }
  }

  @override
  Future<(bool, Failure?)> delete(String id) async {
    try {
      await _remoteDatasource.delete(id);
      return (true, null);
    } on DioException catch (e) {
      return (false, Failure.server(
        message: e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    }
  }
}
''';
}
