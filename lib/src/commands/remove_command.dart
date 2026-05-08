import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Removes Flutter packages.
///
/// Usage: `riv remove dio`
class RemoveCommand extends Command<int> {
  RemoveCommand({required CliLogger logger}) : _logger = logger;

  final CliLogger _logger;

  @override
  String get name => 'remove';

  @override
  String get description => 'Remove a Flutter package.';

  @override
  String get invocation => 'riv remove <package>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      _logger.err('Missing package name. Usage: riv remove <package>');
      return ExitCode.usage;
    }

    final packages = rest;
    final progress = _logger.progress(
      'Removing ${packages.join(", ")}',
    );

    final result = await Process.run(
      'flutter',
      ['pub', 'remove', ...packages],
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to remove packages');
      _logger.err(result.stderr.toString());
      return ExitCode.software;
    }

    progress.complete('Removed ${packages.join(", ")}!');
    return ExitCode.success;
  }
}
