import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/generators/feature_generator.dart';
import 'package:riverflow_cli/src/generators/project_generator.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/templates/provider/provider_template.dart';
import 'package:riverflow_cli/src/templates/screen/screen_template.dart';
import 'package:riverflow_cli/src/templates/view/view_template.dart';
import 'package:riverflow_cli/src/templates/viewmodel/viewmodel_template.dart';
import 'package:riverflow_cli/src/utils/build_runner.dart';
import 'package:riverflow_cli/src/utils/file_utils.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Handles all `riv create` sub-commands.
///
/// Usage:
///   riv create project:my_app
///   riv create page:products
///   riv create viewmodel:product on products
///   riv create view:product on products
///   riv create provider:product on products
///   riv create screen:dashboard
class CreateCommand extends Command<int> {
  CreateCommand({required CliLogger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Preview changes without writing files.',
      )
      ..addOption(
        'on',
        help: 'Target module name (for viewmodel, view, provider).',
      );
  }

  final CliLogger _logger;

  @override
  String get name => 'create';

  @override
  String get description => 'Create a project, page, viewmodel, view, '
      'provider, or screen.';

  @override
  String get invocation => 'riv create <type>:<name> [--on <module>]';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      _logger.err('Missing argument. Usage: riv create <type>:<name>');
      return ExitCode.usage;
    }

    final dryRun = argResults!['dry-run'] as bool;
    final input = rest.first;

    // Parse "on" from positional args: riv create viewmodel:name on module
    var onModule = argResults!['on'] as String?;
    if (onModule == null && rest.length >= 3 && rest[1] == 'on') {
      onModule = rest[2];
    }

    final String type;
    String? rawName;

    if (input.contains(':')) {
      final parts = input.split(':');
      type = parts[0].toLowerCase();
      rawName = parts[1].isEmpty ? null : parts[1];
    } else {
      type = input.toLowerCase();
    }

    // For project, name is optional (interactive prompt will ask)
    if (type != 'project') {
      if (rawName == null) {
        _logger.err('Missing name. Use: riv create $type:<name>');
        return ExitCode.usage;
      }
      if (!rawName.snakeCase.isValidDartIdentifier) {
        _logger.err('"$rawName" is not a valid Dart identifier.');
        return ExitCode.usage;
      }
    }

    final snakeName = rawName?.snakeCase;

    switch (type) {
      case 'project':
        await ProjectGenerator(logger: _logger, dryRun: dryRun)
            .generate(snakeName);
      case 'page':
        final projectName = FileUtils.getProjectName();
        if (projectName == null) {
          _logger.err(
            'Not in a Flutter project. Run this from your project root.',
          );
          return ExitCode.software;
        }
        await FeatureGenerator(logger: _logger, dryRun: dryRun).generate(
          moduleName: snakeName!,
          projectName: projectName,
        );
      case 'viewmodel':
        return _generateViewmodel(snakeName!, onModule, dryRun);
      case 'view':
        return _generateView(snakeName!, onModule, dryRun);
      case 'provider':
        return _generateProvider(snakeName!, onModule, dryRun);
      case 'screen':
        return _generateScreen(snakeName!, dryRun);
      default:
        _logger.err(
          'Unknown type "$type". '
          'Available: project, page, viewmodel, view, provider, screen',
        );
        return ExitCode.usage;
    }

    return ExitCode.success;
  }

  Future<int> _generateViewmodel(
    String name,
    String? module,
    bool dryRun,
  ) async {
    if (module == null) {
      _logger.err(
        'Missing module. Usage: riv create viewmodel:$name on <module>',
      );
      return ExitCode.usage;
    }
    final projectName = FileUtils.getProjectName();
    if (projectName == null) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }
    final filePath = p.join(
      'lib',
      'features',
      module,
      'presentation',
      'viewmodels',
      '${name}_viewmodel.dart',
    );
    await FileUtils.createFile(
      filePath: filePath,
      content: viewmodelTemplate(
        projectName: projectName,
        name: name,
        moduleName: module,
      ),
      logger: _logger,
      dryRun: dryRun,
    );
    if (!dryRun) await BuildRunnerHelper(logger: _logger).runBuild();
    return ExitCode.success;
  }

  Future<int> _generateView(String name, String? module, bool dryRun) async {
    if (module == null) {
      _logger.err('Missing module. Usage: riv create view:$name on <module>');
      return ExitCode.usage;
    }
    final projectName = FileUtils.getProjectName();
    if (projectName == null) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }
    final filePath = p.join(
      'lib',
      'features',
      module,
      'presentation',
      'views',
      '${name}_view.dart',
    );
    await FileUtils.createFile(
      filePath: filePath,
      content: viewTemplate(
        projectName: projectName,
        name: name,
        moduleName: module,
      ),
      logger: _logger,
      dryRun: dryRun,
    );
    return ExitCode.success;
  }

  Future<int> _generateProvider(
    String name,
    String? module,
    bool dryRun,
  ) async {
    if (module == null) {
      _logger.err(
        'Missing module. Usage: riv create provider:$name on <module>',
      );
      return ExitCode.usage;
    }
    final projectName = FileUtils.getProjectName();
    if (projectName == null) {
      _logger.err('Not in a Flutter project.');
      return ExitCode.software;
    }
    final filePath = p.join(
      'lib',
      'features',
      module,
      'data',
      'datasources',
      '${name}_provider.dart',
    );
    await FileUtils.createFile(
      filePath: filePath,
      content: providerTemplate(
        projectName: projectName,
        name: name,
        moduleName: module,
      ),
      logger: _logger,
      dryRun: dryRun,
    );
    if (!dryRun) await BuildRunnerHelper(logger: _logger).runBuild();
    return ExitCode.success;
  }

  Future<int> _generateScreen(String name, bool dryRun) async {
    final filePath = p.join('lib', 'shared', 'widgets', '${name}_screen.dart');
    await FileUtils.createFile(
      filePath: filePath,
      content: screenTemplate(name: name),
      logger: _logger,
      dryRun: dryRun,
    );
    return ExitCode.success;
  }
}
