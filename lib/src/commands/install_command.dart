import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Installs Flutter packages.
///
/// Usage: `riv install dio` or `riv install mocktail --dev`
class InstallCommand extends Command<int> {
  InstallCommand({required CliLogger logger}) : _logger = logger {
    argParser.addFlag(
      'dev',
      abbr: 'd',
      negatable: false,
      help: 'Install as a dev dependency.',
    );
  }

  final CliLogger _logger;

  @override
  String get name => 'install';

  @override
  String get description => 'Install a Flutter package.';

  @override
  String get invocation => 'riv install <package> [--dev]';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      _logger.err('Missing package name. Usage: riv install <package>');
      return ExitCode.usage;
    }

    final isDev = argResults!['dev'] as bool;
    final packages = rest;

    final progress = _logger.progress(
      'Installing ${packages.join(", ")}',
    );

    final args = ['pub', 'add', if (isDev) '--dev', ...packages];
    final result = await Process.run('flutter', args, runInShell: true);

    if (result.exitCode != 0) {
      progress.fail('Failed to install packages');
      _logger.err(result.stderr.toString());
      return ExitCode.software;
    }

    progress.complete('Installed ${packages.join(", ")}!');
    return ExitCode.success;
  }
}
