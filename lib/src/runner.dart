import 'package:args/command_runner.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:riverflow_cli/src/commands/create_command.dart';
import 'package:riverflow_cli/src/commands/delete_command.dart';
import 'package:riverflow_cli/src/commands/generate_command.dart';
import 'package:riverflow_cli/src/commands/init_command.dart';
import 'package:riverflow_cli/src/commands/install_command.dart';
import 'package:riverflow_cli/src/commands/remove_command.dart';
import 'package:riverflow_cli/src/commands/sort_command.dart';
import 'package:riverflow_cli/src/commands/update_command.dart';
import 'package:riverflow_cli/src/commands/watch_command.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/version.dart';

/// Standard exit codes for CLI operations.
class ExitCode {
  /// The command completed successfully.
  static const success = 0;

  /// The command was used incorrectly (e.g. wrong arguments).
  static const usage = 64;

  /// An internal software error occurred.
  static const software = 70;
}

/// The Riverflow CLI command runner.
///
/// Registers all available commands and handles top-level flags
/// like `--version` and `--verbose`.
class RiverflowCommandRunner extends CommandRunner<int> {
  /// Creates a new [RiverflowCommandRunner].
  ///
  /// Optionally accepts a [logger] and [pubUpdater] for testing.
  RiverflowCommandRunner({
    CliLogger? logger,
    PubUpdater? pubUpdater,
  })  : _logger = logger ?? CliLogger(),
        _pubUpdater = pubUpdater ?? PubUpdater(),
        super('riv', 'Riverflow CLI — Modern Flutter scaffolding tool.') {
    argParser
      ..addFlag(
        'version',
        abbr: 'v',
        negatable: false,
        help: 'Print the current version.',
      )
      ..addFlag(
        'verbose',
        negatable: false,
        help: 'Enable verbose logging.',
      );

    addCommand(CreateCommand(logger: _logger));
    addCommand(DeleteCommand(logger: _logger));
    addCommand(GenerateCommand(logger: _logger));
    addCommand(InitCommand(logger: _logger));
    addCommand(SortCommand(logger: _logger));
    addCommand(InstallCommand(logger: _logger));
    addCommand(RemoveCommand(logger: _logger));
    addCommand(UpdateCommand(logger: _logger, pubUpdater: _pubUpdater));
    addCommand(WatchCommand(logger: _logger));
  }

  final CliLogger _logger;
  final PubUpdater _pubUpdater;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);

      if (topLevelResults['version'] == true) {
        _logger.info('riv version: $packageVersion');
        return ExitCode.success;
      }

      return await runCommand(topLevelResults) ?? ExitCode.success;
    } on FormatException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage;
    } on Exception catch (e) {
      _logger.err('$e');
      return ExitCode.software;
    }
  }
}
