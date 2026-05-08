import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the provider file content.
String providerTemplate({
  required String projectName,
  required String name,
  required String moduleName,
}) {
  final className = name.pascalCase;
  final snakeName = name.snakeCase;
  return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${snakeName}_provider.g.dart';

@riverpod
class ${className}Provider extends _\$${className}Provider {
  @override
  Future<dynamic> build() async {
    // TODO: Implement data fetching logic
    return null;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
''';
}
