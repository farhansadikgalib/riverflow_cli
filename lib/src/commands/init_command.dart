import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/templates/project/api_client_template.dart';
import 'package:riverflow_cli/src/templates/project/api_end_points_template.dart';
import 'package:riverflow_cli/src/templates/project/app_constants_template.dart';
import 'package:riverflow_cli/src/templates/project/app_router_template.dart';
import 'package:riverflow_cli/src/templates/project/app_theme_template.dart';
import 'package:riverflow_cli/src/templates/project/di_template.dart';
import 'package:riverflow_cli/src/templates/project/failure_template.dart';
import 'package:riverflow_cli/src/templates/project/local_storage_template.dart';
import 'package:riverflow_cli/src/templates/project/print_log_template.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Converts an existing Flutter project to Riverflow structure.
///
/// Usage: riv init
class InitCommand extends Command<int> {
  InitCommand({required CliLogger logger}) : _logger = logger {
    argParser.addFlag(
      'dry-run',
      negatable: false,
      help: 'Preview changes without writing files.',
    );
  }

  final CliLogger _logger;

  @override
  String get name => 'init';

  @override
  String get description =>
      'Convert an existing Flutter project to Riverflow structure.';

  @override
  Future<int> run() async {
    final dryRun = argResults!['dry-run'] as bool;

    if (!FileUtils.isFlutterProject()) {
      _logger.err(
        'No pubspec.yaml found. Run this from a Flutter project root.',
      );
      return ExitCode.software;
    }

    final projectName = FileUtils.getProjectName()!;
    final progress = _logger.progress('Initializing Riverflow structure');

    // Create directory structure
    final dirs = [
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/network',
      'lib/core/storage',
      'lib/core/utils',
      'lib/core/di',
      'lib/core/theme',
      'lib/features',
      'lib/shared/widgets',
      'lib/shared/models',
      'lib/app',
      'assets/images',
      'assets/icons',
      'assets/fonts',
    ];

    for (final dir in dirs) {
      await FileUtils.createDirectory(
        dirPath: dir,
        logger: _logger,
        dryRun: dryRun,
      );
    }

    // Create core files if they don't exist
    final files = <String, String>{
      p.join('lib', 'app', 'app_router.dart'): appRouterTemplate(projectName),
      p.join('lib', 'core', 'constants', 'app_constants.dart'):
          appConstantsTemplate(),
      p.join('lib', 'core', 'errors', 'failure.dart'): failureTemplate(),
      p.join('lib', 'core', 'network', 'api_client.dart'):
          apiClientTemplate(projectName),
      p.join('lib', 'core', 'network', 'api_end_points.dart'):
          apiEndPointsTemplate(),
      p.join('lib', 'core', 'storage', 'local_storage.dart'):
          localStorageTemplate(),
      p.join('lib', 'core', 'utils', 'print_log.dart'): printLogTemplate(),
      p.join('lib', 'core', 'di', 'app_providers.dart'): diTemplate(
        projectName,
      ),
      p.join('lib', 'core', 'theme', 'app_theme.dart'): appThemeTemplate(),
    };

    for (final entry in files.entries) {
      if (!File(entry.key).existsSync()) {
        await FileUtils.createFile(
          filePath: entry.key,
          content: entry.value,
          logger: _logger,
          dryRun: dryRun,
        );
      }
    }

    progress.complete('Riverflow structure initialized!');

    _logger
      ..info('')
      ..info('Your project has been restructured. Next steps:')
      ..info('  1. Move existing features into lib/features/')
      ..info('  2. Run: flutter pub get')
      ..info(
        '  3. Run: dart run build_runner build '
        '--delete-conflicting-outputs',
      );

    return ExitCode.success;
  }
}
