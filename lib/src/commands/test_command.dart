import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Sets up testing dependencies and runs Flutter tests.
///
/// Usage: `riv test`
class TestCommand extends Command<int> {
  TestCommand({required CliLogger logger}) : _logger = logger;

  final CliLogger _logger;

  @override
  String get name => 'test';

  @override
  String get description => 'Install mocktail and run Flutter tests.';

  @override
  String get invocation => 'riv test';

  @override
  Future<int> run() async {
    if (!FileUtils.isFlutterProject()) {
      _logger.err('Not in a Flutter project. Run this from your project root.');
      return ExitCode.software;
    }

    // Install mocktail if not already present
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();

    if (!pubspecContent.contains('mocktail:')) {
      final installProgress = _logger.progress('Installing mocktail');
      final installResult = await Process.run(
        'flutter',
        ['pub', 'add', '--dev', 'mocktail'],
        runInShell: true,
      );
      if (installResult.exitCode != 0) {
        installProgress.fail('Failed to install mocktail');
        _logger.err(installResult.stderr.toString());
        return ExitCode.software;
      }
      installProgress.complete('mocktail installed!');
    }

    // Run tests
    _logger.info('Running tests...\n');
    final testResult = await Process.run(
      'flutter',
      ['test', ...argResults!.rest],
      runInShell: true,
    );

    stdout.write(testResult.stdout);
    if (testResult.stderr.toString().isNotEmpty) {
      stderr.write(testResult.stderr);
    }

    return testResult.exitCode;
  }
}
