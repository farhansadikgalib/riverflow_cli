import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the viewmodel file content with use case injection.
String viewmodelTemplate({
  required String projectName,
  required String name,
  required String moduleName,
}) {
  final className = name.pascalCase;
  final snakeName = name.snakeCase;
  final moduleClass = moduleName.singular.pascalCase;
  return '''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:$projectName/features/$moduleName/presentation/providers/${moduleName.singular.snakeCase}_providers.dart';

part '${snakeName}_viewmodel.freezed.dart';
part '${snakeName}_viewmodel.g.dart';

@freezed
sealed class ${className}State with _\$${className}State {
  const factory ${className}State.initial() = _Initial;
  const factory ${className}State.loading() = _Loading;
  const factory ${className}State.loaded({required dynamic data}) = _Loaded;
  const factory ${className}State.error({required String message}) = _Error;
}

@riverpod
class ${className}ViewModel extends _\$${className}ViewModel {
  @override
  ${className}State build() {
    return const ${className}State.initial();
  }

  Future<void> loadData() async {
    state = const ${className}State.loading();
    final useCase = ref.read(get${moduleClass}sUseCaseProvider);
    final result = await useCase();
    result.fold(
      (failure) => state = ${className}State.error(
        message: failure.toString(),
      ),
      (data) => state = ${className}State.loaded(data: data),
    );
  }

  Future<void> loadById(String id) async {
    state = const ${className}State.loading();
    final useCase = ref.read(get${moduleClass}ByIdUseCaseProvider);
    final result = await useCase(id);
    result.fold(
      (failure) => state = ${className}State.error(
        message: failure.toString(),
      ),
      (data) => state = ${className}State.loaded(data: data),
    );
  }
}
''';
}
