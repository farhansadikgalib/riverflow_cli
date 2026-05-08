import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the remote datasource file content for a feature module.
String datasourceTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final modelFile = moduleName.singular.snakeCase;
  return '''
import 'dart:convert';

import 'package:$projectName/features/$moduleName/data/models/${modelFile}_model.dart';
import 'package:$projectName/core/network/api_client.dart';
import 'package:$projectName/core/network/api_end_points.dart';

class ${className}RemoteDatasource {
  const ${className}RemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<${className}Model>> getAll() async {
    final response = await _apiClient.get(
      '/$moduleName',
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '[]');
    return (body as List<dynamic>)
        .map((e) => ${className}Model.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<${className}Model> getById(String id) async {
    final response = await _apiClient.get(
      '/$moduleName/\$id',
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ${className}Model.fromJson(body as Map<String, dynamic>);
  }

  Future<${className}Model> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/$moduleName',
      data: data,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ${className}Model.fromJson(body as Map<String, dynamic>);
  }

  Future<${className}Model> update(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '/$moduleName/\$id',
      data: data,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ${className}Model.fromJson(body as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/$moduleName/\$id', requiresAuth: true);
  }
}
''';
}
