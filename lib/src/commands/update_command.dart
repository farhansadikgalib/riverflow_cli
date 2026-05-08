import 'package:args/command_runner.dart';
import 'package:pub_updater/pub_updater.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/version.dart';

/// Updates the Riverflow CLI to the latest version.
///
/// Usage: riv update
class UpdateCommand extends Command<int> {
  UpdateCommand({required CliLogger logger, PubUpdater? pubUpdater})
      : _logger = logger,
        _pubUpdater = pubUpdater ?? PubUpdater();

  final CliLogger _logger;
  final PubUpdater _pubUpdater;

  @override
  String get name => 'update';

  @override
  String get description => 'Update Riverflow CLI to the latest version.';

  @override
  Future<int> run() async {
    final progress = _logger.progress('Checking for updates');

    try {
      final isUpToDate = await _pubUpdater.isUpToDate(
        packageName: 'riverflow_cli',
        currentVersion: packageVersion,
      );

      if (isUpToDate) {
        progress.complete(
          'Riverflow CLI is already up to date ($packageVersion).',
        );
        return ExitCode.success;
      }

      final latestVersion = await _pubUpdater.getLatestVersion(
        'riverflow_cli',
      );
      progress.update('Updating to $latestVersion');

      await _pubUpdater.update(packageName: 'riverflow_cli');
      progress.complete('Updated to $latestVersion!');
    } on Exception catch (e) {
      progress.fail('Failed to update');
      _logger.err('$e');
      return ExitCode.software;
    }

    return ExitCode.success;
  }
}
