import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/utils/logger.dart';

/// Utility functions for file and directory operations.
class FileUtils {
  /// Creates a file at [filePath] with the given [content].
  ///
  /// Creates parent directories if they don't exist.
  /// If [overwrite] is false and the file exists, prompts the user.
  static Future<void> createFile({
    required String filePath,
    required String content,
    required CliLogger logger,
    bool overwrite = false,
    bool dryRun = false,
  }) async {
    final file = File(filePath);

    if (file.existsSync() && !overwrite) {
      final shouldOverwrite = logger.confirm(
        'File ${p.basename(filePath)} already exists. Overwrite?',
      );
      if (!shouldOverwrite) {
        logger.info('Skipped ${p.basename(filePath)}');
        return;
      }
    }

    if (dryRun) {
      logger.info(
        '${AnsiColor.wrap('[dry-run]', AnsiColor.lightCyan)} '
        'Would create: $filePath',
      );
      return;
    }

    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    logger.info(
      '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
      'Created ${p.relative(filePath)}',
    );
  }

  /// Creates a directory at [dirPath] if it doesn't exist.
  static Future<void> createDirectory({
    required String dirPath,
    required CliLogger logger,
    bool dryRun = false,
  }) async {
    if (dryRun) {
      logger.info(
        '${AnsiColor.wrap('[dry-run]', AnsiColor.lightCyan)} '
        'Would create dir: $dirPath',
      );
      return;
    }

    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
  }

  /// Checks if the current directory is a Flutter project.
  static bool isFlutterProject([String? path]) {
    final pubspecFile = File(p.join(path ?? '.', 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return false;
    final content = pubspecFile.readAsStringSync();
    return content.contains('flutter:');
  }

  /// Returns the project name from pubspec.yaml.
  static String? getProjectName([String? path]) {
    final pubspecFile = File(p.join(path ?? '.', 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return null;
    final content = pubspecFile.readAsStringSync();
    final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(
      content,
    );
    return match?.group(1);
  }
}
