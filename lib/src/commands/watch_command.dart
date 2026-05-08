import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Runs build_runner in watch mode for continuous code generation.
///
/// Usage: `riv watch`
class WatchCommand extends Command<int> {
  WatchCommand({required CliLogger logger}) : _logger = logger;

  final CliLogger _logger;

  @override
  String get name => 'watch';

  @override
  String get description =>
      'Run build_runner in watch mode for continuous code generation.';

  @override
  Future<int> run() async {
    if (!FileUtils.isFlutterProject()) {
      _logger.err('Not in a Flutter project. Run this from your project root.');
      return ExitCode.software;
    }

    _logger.info(
      '${AnsiColor.wrap('►', AnsiColor.cyan)} '
      'Starting build_runner watch...',
    );
    _logger.info('  Press Ctrl+C to stop.\n');

    final process = await Process.start(
      'dart',
      ['run', 'build_runner', 'watch', '--delete-conflicting-outputs'],
    );

    // Forward stdout and stderr to the terminal
    final stdoutSub = process.stdout
        .transform(const SystemEncoding().decoder)
        .listen(stdout.write);
    final stderrSub = process.stderr
        .transform(const SystemEncoding().decoder)
        .listen(stderr.write);

    // Handle Ctrl+C gracefully
    final sigintSub = ProcessSignal.sigint.watch().listen((_) {
      _logger.info(
        '\n${AnsiColor.wrap('■', AnsiColor.yellow)} Stopping watch...',
      );
      process.kill();
    });

    final exitCode = await process.exitCode;

    await stdoutSub.cancel();
    await stderrSub.cancel();
    await sigintSub.cancel();

    if (exitCode == 0) {
      _logger.info(
        '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} Watch stopped.',
      );
    }

    return exitCode;
  }
}
