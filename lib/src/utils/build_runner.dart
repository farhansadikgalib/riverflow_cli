import 'dart:io';

import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/yaml_utils.dart';

/// Runs `dart run build_runner build` if configured in riverflow.yaml.
class BuildRunnerHelper {
  const BuildRunnerHelper({required this.logger});

  final CliLogger logger;

  /// Returns true if build_runner should run based on riverflow.yaml config.
  bool get shouldRun {
    final config = YamlUtils.readConfig();
    final generation = config['generation'] as Map<String, dynamic>?;
    if (generation == null) return false;
    return generation['run_build_runner'] == true;
  }

  /// Runs build_runner build with --delete-conflicting-outputs.
  Future<bool> runBuild() async {
    if (!shouldRun) return true;

    final progress = logger.progress('Running build_runner');

    final result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    );

    if (result.exitCode != 0) {
      progress.fail('build_runner failed');
      logger.err(result.stderr.toString());
      return false;
    }

    progress.complete('build_runner completed!');
    return true;
  }

  /// Runs build_runner watch with --delete-conflicting-outputs.
  Future<Process> runWatch() async {
    logger.info(
      '${AnsiColor.wrap('⠋', AnsiColor.cyan)} '
      'Starting build_runner watch...',
    );

    final process = await Process.start(
      'dart',
      ['run', 'build_runner', 'watch', '--delete-conflicting-outputs'],
    );

    return process;
  }
}
