import 'dart:io';

import 'package:riverflow_cli/src/utils/logger.dart';

/// Runs build_runner commands.
class BuildRunnerHelper {
  const BuildRunnerHelper({required this.logger});

  final CliLogger logger;

  /// Runs build_runner build with --delete-conflicting-outputs.
  Future<bool> runBuild() async {
    final progress = logger.progress('Running build_runner');

    final result = await Process.run(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      progress.fail('build_runner failed');
      logger.err(result.stderr.toString());
      return false;
    }

    progress.complete('build_runner completed!');
    return true;
  }
}
