/// Returns the widget_test.dart content for a new Flutter project.
String widgetTestTemplate(String name) {
  return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:$name/app/app_router.dart';
import 'package:$name/core/theme/app_theme.dart';

void main() {
  testWidgets('App should build without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Center(child: Text('Test')),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
''';
}

