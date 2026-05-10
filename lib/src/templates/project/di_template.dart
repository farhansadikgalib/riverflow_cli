/// Returns the app_providers.dart content for core/di/.
String diTemplate(String projectName) => '''
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:$projectName/core/storage/local_storage.dart';

part 'app_providers.g.dart';

/// Global app-level providers for dependency injection.
///
/// Feature-specific providers live inside each feature's
/// `presentation/providers/` folder.

@riverpod
LocalStorage localStorage(Ref ref) {
  final secure = ref.watch(secureStorageProvider);
  return LocalStorage(secure);
}
''';
