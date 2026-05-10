import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:riverflow_cli/src/generators/json_to_freezed.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/build_runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';

/// Handles `riv generate` sub-commands.
///
/// Usage:
///   riv generate model on products with data/product.json
///   riv generate locales lib/l10n
class GenerateCommand extends Command<int> {
  GenerateCommand({required CliLogger logger}) : _logger = logger {
    argParser.addFlag(
      'dry-run',
      negatable: false,
      help: 'Preview changes without writing files.',
    );
  }

  final CliLogger _logger;

  @override
  String get name => 'generate';

  @override
  String get description => 'Generate models from JSON or locales from ARB.';

  @override
  String get invocation => 'riv generate model on <module> with <json>\n'
      '  riv generate locales <path>';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    final dryRun = argResults!['dry-run'] as bool;

    if (rest.isEmpty) {
      _logger.err('Missing argument. Usage: riv generate model on <module> '
          'with <json>');
      return ExitCode.usage;
    }

    final subCommand = rest.first.toLowerCase();

    switch (subCommand) {
      case 'model':
        return _generateModel(rest, dryRun);
      case 'locales':
        return _generateLocales(rest, dryRun);
      default:
        _logger.err('Unknown generate type "$subCommand". '
            'Available: model, locales');
        return ExitCode.usage;
    }
  }

  Future<int> _generateModel(List<String> rest, bool dryRun) async {
    // Parse: model on <module> with <json_path>
    String? moduleName;
    String? jsonPath;

    for (var i = 1; i < rest.length; i++) {
      if (rest[i] == 'on' && i + 1 < rest.length) {
        moduleName = rest[i + 1];
      }
      if (rest[i] == 'with' && i + 1 < rest.length) {
        jsonPath = rest[i + 1];
      }
    }

    if (moduleName == null || jsonPath == null) {
      _logger.err(
        'Usage: riv generate model on <module> with <json_path>',
      );
      return ExitCode.usage;
    }

    final projectName = FileUtils.getProjectName();
    if (projectName == null) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }

    await JsonToFreezed(logger: _logger, dryRun: dryRun).generate(
      moduleName: moduleName,
      jsonPath: jsonPath,
      projectName: projectName,
    );

    if (!dryRun) await BuildRunnerHelper(logger: _logger).runBuild();

    return ExitCode.success;
  }

  Future<int> _generateLocales(List<String> rest, bool dryRun) async {
    final arbPath = rest.length > 1 ? rest[1] : 'lib/l10n';

    if (!FileUtils.isFlutterProject()) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }

    if (dryRun) {
      _logger.info(
        '${AnsiColor.wrap('[dry-run]', AnsiColor.lightCyan)} Would run: '
        'flutter gen-l10n --arb-dir=$arbPath',
      );
      return ExitCode.success;
    }

    // Ensure flutter_localizations is in pubspec
    final pubspecFile = File('pubspec.yaml');
    final pubspecContent = pubspecFile.readAsStringSync();

    if (!pubspecContent.contains('flutter_localizations:')) {
      final depsProgress =
          _logger.progress('Adding flutter_localizations');
      final depsResult = await Process.run(
        'flutter',
        ['pub', 'add', 'flutter_localizations', '--sdk=flutter'],
        runInShell: true,
      );
      if (depsResult.exitCode != 0) {
        depsProgress.fail('Failed to add flutter_localizations');
        _logger.err(depsResult.stderr.toString());
        return ExitCode.software;
      }
      depsProgress.complete('flutter_localizations added!');
    }

    // Ensure generate: true is in pubspec
    final currentContent = pubspecFile.readAsStringSync();
    if (!currentContent.contains('generate: true')) {
      final updated =
          currentContent.replaceFirst('flutter:', 'flutter:\n  generate: true');
      pubspecFile.writeAsStringSync(updated);
    }

    final progress = _logger.progress('Generating locales');

    final result = await Process.run(
      'flutter',
      ['gen-l10n', '--arb-dir=$arbPath'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      progress.fail('Failed to generate locales');
      _logger.err(result.stderr.toString());
      return ExitCode.software;
    }

    progress.complete('Locales generated!');
    return ExitCode.success;
  }
}
