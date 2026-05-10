import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Sorts and organizes imports across the project.
///
/// Usage: riv sort
class SortCommand extends Command<int> {
  SortCommand({required CliLogger logger}) : _logger = logger;

  final CliLogger _logger;

  @override
  String get name => 'sort';

  @override
  String get description => 'Sort and organize imports across the project.';

  @override
  Future<int> run() async {
    final progress = _logger.progress('Sorting imports');

    // Use dart fix to organize imports
    final result = await Process.run(
      'dart',
      ['fix', '--apply', '--code=directives_ordering'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      // Fallback to dart format
      final formatResult = await Process.run(
        'dart',
        ['format', '.'],
        runInShell: true,
      );
      if (formatResult.exitCode != 0) {
        progress.fail('Failed to sort imports');
        _logger.err(formatResult.stderr.toString());
        return ExitCode.software;
      }
    }

    progress.complete('Imports sorted!');
    return ExitCode.success;
  }
}
