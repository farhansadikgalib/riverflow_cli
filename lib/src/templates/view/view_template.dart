import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the view file content.
String viewTemplate({
  required String projectName,
  required String name,
  required String moduleName,
}) {
  final className = name.pascalCase;
  final vmSnake = name.snakeCase;
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/features/$moduleName/presentation/viewmodels/${vmSnake}_viewmodel.dart';

class ${className}View extends ConsumerWidget {
  const ${className}View({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${name.camelCase}ViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('$className')),
      body: state.when(
        initial: () => const Center(child: Text('Press the button to load')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (data) => Center(child: Text('Loaded: \$data')),
        error: (message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: \$message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(${name.camelCase}ViewModelProvider.notifier).loadData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(${name.camelCase}ViewModelProvider.notifier).loadData(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';
}
