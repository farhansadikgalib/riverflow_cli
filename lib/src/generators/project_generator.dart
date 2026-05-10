import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/templates/project/analysis_options_template.dart';
import 'package:riverflow_cli/src/templates/project/api_client_template.dart';
import 'package:riverflow_cli/src/templates/project/api_end_points_template.dart';
import 'package:riverflow_cli/src/templates/project/app_constants_template.dart';
import 'package:riverflow_cli/src/templates/project/app_router_template.dart';
import 'package:riverflow_cli/src/templates/project/app_theme_template.dart';
import 'package:riverflow_cli/src/templates/project/di_template.dart';
import 'package:riverflow_cli/src/templates/project/failure_template.dart';
import 'package:riverflow_cli/src/templates/project/home_view_template.dart';
import 'package:riverflow_cli/src/templates/project/home_viewmodel_template.dart';
import 'package:riverflow_cli/src/templates/project/local_storage_template.dart';
import 'package:riverflow_cli/src/templates/project/main_template.dart';
import 'package:riverflow_cli/src/templates/project/print_log_template.dart';
import 'package:riverflow_cli/src/templates/project/pubspec_template.dart';
import 'package:riverflow_cli/src/templates/project/snackbar_template.dart';
import 'package:riverflow_cli/src/templates/project/routes_template.dart';
import 'package:riverflow_cli/src/templates/project/widget_test_template.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Generates a complete Flutter project with Clean Architecture structure.
class ProjectGenerator {
  const ProjectGenerator({required this.logger, this.dryRun = false});

  final CliLogger logger;
  final bool dryRun;

  Future<void> generate(String? initialName) async {
    // Interactive prompts
    final name =
        initialName ?? logger.prompt('What is the name of the project?');

    if (name.isEmpty) {
      logger.err('Project name cannot be empty.');
      return;
    }

    final org = logger.prompt(
      "What is your company's domain?  Example: com.yourcompany",
      defaultValue: 'com.example',
    );

    final projectDir = p.join(Directory.current.path, name);

    if (Directory(projectDir).existsSync()) {
      final overwrite = logger.confirm(
        'Directory "$name" already exists. Overwrite?',
      );
      if (!overwrite) {
        logger.err('Aborted.');
        return;
      }
    }

    final progress = logger.progress('Creating project $name');

    // Create Flutter project with Swift (iOS) and Kotlin (Android)
    if (!dryRun) {
      final result = await Process.run(
        'flutter',
        [
          'create',
          '--org',
          org,
          '--project-name',
          name,
          '-i',
          'swift',
          '-a',
          'kotlin',
          name,
        ],
        workingDirectory: Directory.current.path,
        runInShell: true,
      );
      if (result.exitCode != 0) {
        progress.fail('Failed to create Flutter project');
        logger.err(result.stderr.toString());
        return;
      }
    }

    // Create directory structure matching the reference architecture
    final dirs = [
      // core/
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/network',
      'lib/core/storage',
      'lib/core/utils',
      'lib/core/di',
      'lib/core/theme',

      // features/
      'lib/features/home/data/datasources',
      'lib/features/home/data/models',
      'lib/features/home/data/repositories',
      'lib/features/home/domain/entities',
      'lib/features/home/domain/repositories',
      'lib/features/home/domain/usecases',
      'lib/features/home/presentation/providers',
      'lib/features/home/presentation/viewmodels',
      'lib/features/home/presentation/views',
      'lib/features/home/presentation/widgets',

      // shared/
      'lib/shared/widgets',
      'lib/shared/models',

      // app/
      'lib/app',

      // assets
      'assets',
    ];

    for (final dir in dirs) {
      await FileUtils.createDirectory(
        dirPath: p.join(projectDir, dir),
        logger: logger,
        dryRun: dryRun,
      );
    }

    // Create files
    final files = <String, String>{
      // Root config
      'pubspec.yaml': pubspecTemplate(name),
      'analysis_options.yaml': analysisOptionsTemplate(),
      '.env': '# Environment variables\n'
          'APP_VERSION=1.0.0\n'
          '# BASE_URL=https://api.example.com\n',

      // App
      'lib/main.dart': mainTemplate(name),
      'lib/app/app_router.dart': appRouterTemplate(name),
      'lib/app/routes.dart': routesTemplate(),

      // Core — constants
      'lib/core/constants/app_constants.dart': appConstantsTemplate(),

      // Core — errors
      'lib/core/errors/failure.dart': failureTemplate(),

      // Core — network
      'lib/core/network/api_client.dart': apiClientTemplate(name),
      'lib/core/network/api_end_points.dart': apiEndPointsTemplate(),

      // Core — storage
      'lib/core/storage/local_storage.dart': localStorageTemplate(),

      // Core — utils
      'lib/core/utils/print_log.dart': printLogTemplate(),
      'lib/core/utils/riv_snackbar.dart': snackbarTemplate(),

      // Core — di
      'lib/core/di/app_providers.dart': diTemplate(name),

      // Core — theme
      'lib/core/theme/app_theme.dart': appThemeTemplate(),

      // Features — home
      'lib/features/home/presentation/views/home_view.dart':
          homeViewTemplate(name),
      'lib/features/home/presentation/viewmodels/home_viewmodel.dart':
          homeViewmodelTemplate(),

      // Test
      'test/widget_test.dart': widgetTestTemplate(name),
    };

    for (final entry in files.entries) {
      await FileUtils.createFile(
        filePath: p.join(projectDir, entry.key),
        content: entry.value,
        logger: logger,
        overwrite: true,
        dryRun: dryRun,
      );
    }

    progress.complete('Project $name created successfully!');

    // Run flutter pub get
    if (!dryRun) {
      final pubGetProgress = logger.progress('Running flutter pub get');
      final pubGetResult = await Process.run(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectDir,
        runInShell: true,
      );
      if (pubGetResult.exitCode != 0) {
        pubGetProgress.fail('flutter pub get failed');
        logger.err(pubGetResult.stderr.toString());
      } else {
        pubGetProgress.complete('Dependencies installed!');
      }
    }

    // Run build_runner
    if (!dryRun) {
      final buildProgress = logger.progress('Running build_runner');
      final buildResult = await Process.run(
        'dart',
        ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        workingDirectory: projectDir,
        runInShell: true,
      );
      if (buildResult.exitCode != 0) {
        buildProgress.fail('build_runner failed');
        logger.err(buildResult.stderr.toString());
      } else {
        buildProgress.complete('Code generation complete!');
      }
    }

    logger
      ..info('')
      ..info('Your project is ready! Run:')
      ..info('  cd $name')
      ..info('  flutter run')
      ..info('');
  }
}
