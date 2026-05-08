import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the Riverpod providers file that wires the full dependency chain:
/// ApiClient → Datasource → Repository → UseCase
String providersTemplate({
  required String projectName,
  required String moduleName,
}) {
  final className = moduleName.singular.pascalCase;
  final snakeName = moduleName.singular.snakeCase;
  return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:$projectName/features/$moduleName/data/datasources/${snakeName}_remote_datasource.dart';
import 'package:$projectName/features/$moduleName/data/repositories/${snakeName}_repository_impl.dart';
import 'package:$projectName/features/$moduleName/domain/repositories/${snakeName}_repository.dart';
import 'package:$projectName/features/$moduleName/domain/usecases/get_${moduleName}_usecase.dart';
import 'package:$projectName/core/network/api_client.dart';

part '${snakeName}_providers.g.dart';

// ═══ Datasource ═══

@riverpod
${className}RemoteDatasource ${moduleName.singular.camelCase}RemoteDatasource(
  ${className}RemoteDatasourceRef ref,
) {
  final client = ref.watch(apiClientProvider);
  return ${className}RemoteDatasource(client);
}

// ═══ Repository ═══

@riverpod
${className}Repository ${moduleName.singular.camelCase}Repository(
  ${className}RepositoryRef ref,
) {
  final datasource = ref.watch(${moduleName.singular.camelCase}RemoteDatasourceProvider);
  return ${className}RepositoryImpl(datasource);
}

// ═══ Use Cases ═══

@riverpod
Get${className}sUseCase get${className}sUseCase(
  Get${className}sUseCaseRef ref,
) {
  final repository = ref.watch(${moduleName.singular.camelCase}RepositoryProvider);
  return Get${className}sUseCase(repository);
}

@riverpod
Get${className}ByIdUseCase get${className}ByIdUseCase(
  Get${className}ByIdUseCaseRef ref,
) {
  final repository = ref.watch(${moduleName.singular.camelCase}RepositoryProvider);
  return Get${className}ByIdUseCase(repository);
}
''';
}
