/// Returns the home view content for the default home module.
String homeViewTemplate(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/features/home/presentation/viewmodels/home_viewmodel.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: state.when(
        initial: () => const Center(
          child: Text('Welcome! Tap the button to get started.'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (data) => Center(
          child: Text(
            'Hello, Riverflow!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        error: (message) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: \$message'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(homeViewModelProvider.notifier).loadData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            ref.read(homeViewModelProvider.notifier).loadData(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
''';
