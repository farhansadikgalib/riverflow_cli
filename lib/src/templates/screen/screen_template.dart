import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Returns the responsive screen file content.
String screenTemplate({
  required String name,
}) {
  final className = name.pascalCase;
  return '''
import 'package:flutter/material.dart';

class ${className}Screen extends StatelessWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$className')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1200) {
            return const ${className}DesktopLayout();
          } else if (constraints.maxWidth >= 600) {
            return const ${className}TabletLayout();
          } else {
            return const ${className}MobileLayout();
          }
        },
      ),
    );
  }
}

class ${className}DesktopLayout extends StatelessWidget {
  const ${className}DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('$className — Desktop Layout'));
  }
}

class ${className}TabletLayout extends StatelessWidget {
  const ${className}TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('$className — Tablet Layout'));
  }
}

class ${className}MobileLayout extends StatelessWidget {
  const ${className}MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('$className — Mobile Layout'));
  }
}
''';
}
