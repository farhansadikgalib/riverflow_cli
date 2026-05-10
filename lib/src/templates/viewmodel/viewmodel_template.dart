import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the viewmodel file content with use case injection.
String viewmodelTemplate({
  required String projectName,
  required String name,
  required String moduleName,
}) {
  final className = name.pascalCase;
  final snakeName = name.snakeCase;
  return '''
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '${snakeName}_viewmodel.g.dart';

@riverpod
class ${className}ViewModel extends _\$${className}ViewModel {
  @override
  dynamic build() => null;
}
''';
}
