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
import 'package:riverflow_cli/src/templates/project/riverflow_yaml_template.dart';
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
      'assets/images',
      'assets/icons',
      'assets/fonts',
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
      'riverflow.yaml': riverflowYamlTemplate(name),
      '.env': '# Environment variables\n'
          'APP_VERSION=1.0.0\n'
          '# BASE_URL=https://api.example.com\n',

      // App
      'lib/main.dart': mainTemplate(name),
      'lib/app/app_router.dart': appRouterTemplate(name),

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

      // Core — di
      'lib/core/di/app_providers.dart': diTemplate(name),

      // Core — theme
      'lib/core/theme/app_theme.dart': appThemeTemplate(),

      // Features — home
      'lib/features/home/presentation/views/home_view.dart':
          homeViewTemplate(name),
      'lib/features/home/presentation/viewmodels/home_viewmodel.dart':
          homeViewmodelTemplate(),
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

    // Add .gitkeep to empty directories
    final emptyDirs = [
      'assets/images',
      'assets/icons',
      'assets/fonts',
      'lib/shared/widgets',
      'lib/shared/models',
    ];

    for (final dir in emptyDirs) {
      await FileUtils.createFile(
        filePath: p.join(projectDir, dir, '.gitkeep'),
        content: '',
        logger: logger,
        overwrite: true,
        dryRun: dryRun,
      );
    }

    progress.complete('Project $name created successfully!');

    logger
      ..info('')
      ..info('Next steps:')
      ..info('  cd $name')
      ..info('  flutter pub get')
      ..info(
        '  dart run build_runner build --delete-conflicting-outputs',
      )
      ..info('');
  }
}
