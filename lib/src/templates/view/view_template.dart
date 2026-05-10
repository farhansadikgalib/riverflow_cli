import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the view file content.
String viewTemplate({
  required String projectName,
  required String name,
  required String moduleName,
}) {
  final className = name.pascalCase;
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ${className}View extends ConsumerWidget {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('$className')),
      body: const Center(
        child: Text('$className'),
      ),
    );
  }
}
''';
}
