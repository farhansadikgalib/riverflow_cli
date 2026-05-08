import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/generators/route_registrar.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Deletes a generated feature module and unregisters its route.
///
/// Usage: `riv delete page:products`
class DeleteCommand extends Command<int> {
  DeleteCommand({required CliLogger logger}) : _logger = logger {
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: 'Skip confirmation prompt.',
    );
  }

  final CliLogger _logger;

  @override
  String get name => 'delete';

  @override
  String get description => 'Delete a feature module and unregister its route.';

  @override
  String get invocation => 'riv delete page:products';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      _logger.err('Missing argument. Usage: riv delete page:<name>');
      return ExitCode.usage;
    }

    final input = rest.first;

    if (!input.contains(':')) {
      _logger.err('Invalid format. Use: riv delete page:<name>');
      return ExitCode.usage;
    }

    final parts = input.split(':');
    final type = parts[0].toLowerCase();
    final rawName = parts[1];

    if (rawName.isEmpty) {
      _logger.err('Name cannot be empty.');
      return ExitCode.usage;
    }

    if (type != 'page') {
      _logger
          .err('Only page deletion is supported. Use: riv delete page:<name>');
      return ExitCode.usage;
    }

    final moduleName = rawName.snakeCase;

    final projectName = FileUtils.getProjectName();
    if (projectName == null) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }

    final moduleDir = p.join('lib', 'features', moduleName);
    final dir = Directory(moduleDir);

    if (!dir.existsSync()) {
      _logger.err('Module "$moduleName" not found at $moduleDir');
      return ExitCode.software;
    }

    // Confirmation
    final force = argResults!['force'] as bool;
    if (!force) {
      final confirmed = _logger.confirm(
        'Delete module "$moduleName" and all its files? This cannot be undone',
      );
      if (!confirmed) {
        _logger.info('Aborted.');
        return ExitCode.success;
      }
    }

    final progress = _logger.progress('Deleting module $moduleName');

    // Unregister route first
    RouteRegistrar(logger: _logger).unregisterRoute(
      moduleName: moduleName,
      projectName: projectName,
    );

    // Delete the module directory
    try {
      dir.deleteSync(recursive: true);
      progress.complete('Module $moduleName deleted!');
    } on FileSystemException catch (e) {
      progress.fail('Failed to delete module');
      _logger.err(e.message);
      return ExitCode.software;
    }

    return ExitCode.success;
  }
}
