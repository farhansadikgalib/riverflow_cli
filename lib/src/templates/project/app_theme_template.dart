/// Returns the app_theme.dart content for a new Flutter project.
String appThemeTemplate() => '''
import 'package:flutter/material.dart';

/// Application theme configuration.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
}
''';
