import 'dart:io';

import 'package:logger/logger.dart';

/// ANSI color codes for terminal output.
class AnsiColor {
  static const reset = '\x1B[0m';
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const cyan = '\x1B[36m';
  static const lightGreen = '\x1B[92m';
  static const lightCyan = '\x1B[96m';

  static String wrap(String text, String color) => '$color$text$reset';
}

/// A progress indicator that shows a spinner in the terminal.
class CliProgress {
  CliProgress(this._message) {
    stdout.write('  ⠋ $_message...');
  }

  final String _message;

  void update(String message) {
    stdout.write('\r  ⠋ $message...');
  }

  void complete([String? message]) {
    stdout.write('\r  ${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
        '${message ?? _message}\n');
  }

  void fail([String? message]) {
    stdout.write('\r  ${AnsiColor.wrap('✗', AnsiColor.red)} '
        '${message ?? _message}\n');
  }
}

/// CLI-friendly logger wrapping the `logger` package.
///
/// Uses direct stdout/stderr for user-facing messages and the `logger`
/// package for verbose/debug output.
class CliLogger {
  CliLogger({Level? level})
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 0,
            lineLength: 80,
            noBoxingByDefault: true,
          ),
          level: level ?? Level.debug,
        );

  final Logger _logger;

  /// Prints an info message to stdout.
  void info(String message) {
    stdout.writeln(message);
  }

  /// Prints an error message to stderr in red.
  void err(String message) {
    stderr.writeln(AnsiColor.wrap(message, AnsiColor.red));
  }

  /// Prints a warning message to stderr in yellow.
  void warn(String message) {
    stderr.writeln(AnsiColor.wrap(message, AnsiColor.yellow));
  }

  /// Prints a success message with a green checkmark.
  void success(String message) {
    stdout.writeln('  ${AnsiColor.wrap('✓', AnsiColor.lightGreen)} $message');
  }

  /// Prints a verbose/debug message via the logger package.
  void detail(String message) {
    _logger.d(message);
  }

  /// Creates a progress indicator.
  CliProgress progress(String message) {
    return CliProgress(message);
  }

  /// Prompts the user for text input.
  String prompt(String message, {String? defaultValue}) {
    final hint = defaultValue != null ? ' ($defaultValue)' : '';
    stdout.write('  $message$hint: ');
    final input = stdin.readLineSync()?.trim() ?? '';
    if (input.isEmpty && defaultValue != null) return defaultValue;
    return input;
  }

  /// Prompts the user for a yes/no confirmation.
  bool confirm(String message, {bool defaultValue = false}) {
    final defaultHint = defaultValue ? 'Y/n' : 'y/N';
    stdout.write('  $message ($defaultHint): ');
    final input = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    if (input.isEmpty) return defaultValue;
    return input == 'y' || input == 'yes';
  }
}

/// Logs a Riverflow banner to the console.
void logBanner(CliLogger logger) {
  logger
    ..info('')
    ..info(
      AnsiColor.wrap(
        '''
  ╦═╗╦╦  ╦╔═╗╦═╗╔═╗╦  ╔═╗╦ ╦
  ╠╦╝║╚╗╔╝║╣ ╠╦╝╠╣ ║  ║ ║║║║
  ╩╚═╩ ╚╝ ╚═╝╩╚═╚  ╩═╝╚═╝╚╩╝''',
        AnsiColor.lightCyan,
      ),
    )
    ..info('');
}
