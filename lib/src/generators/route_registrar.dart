import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Handles automatic route registration in app_router.dart.
class RouteRegistrar {
  const RouteRegistrar({required this.logger});

  final CliLogger logger;

  /// Registers a new route for the given module in app_router.dart.
  void registerRoute({
    required String moduleName,
    required String projectName,
  }) {
    final routerPath = p.join('lib', 'app', 'app_router.dart');
    final routerFile = File(routerPath);

    if (!routerFile.existsSync()) {
      logger.warn('app_router.dart not found. Skipping route registration.');
      return;
    }

    var content = routerFile.readAsStringSync();
    final className = moduleName.singular.pascalCase;
    final snakeName = moduleName.singular.snakeCase;
    const importMarker = '// ══════ RIVERFLOW_ROUTE_IMPORTS ══════';
    const routeMarker = '// ══════ RIVERFLOW_ROUTE_DEFINITIONS ══════';

    // Add import
    final importLine = "import 'package:$projectName/features/$moduleName/"
        "presentation/views/${snakeName}_view.dart';";

    if (!content.contains(importLine)) {
      if (content.contains(importMarker)) {
        content = content.replaceFirst(
          importMarker,
          '$importLine\n$importMarker',
        );
      }
    }

    // Add route class
    final routeClass = '''
@TypedGoRoute<${className}Route>(path: '/$moduleName')
class ${className}Route extends GoRouteData {
  const ${className}Route();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ${className}View();
  }
}
''';

    if (content.contains(routeMarker) &&
        !content.contains('${className}Route')) {
      content = content.replaceFirst(
        routeMarker,
        '$routeClass\n$routeMarker',
      );
    }

    routerFile.writeAsStringSync(content);
    logger.info(
      '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
      'Registered route /$moduleName in app_router.dart',
    );
  }

  /// Removes a route registration for the given module.
  void unregisterRoute({
    required String moduleName,
    required String projectName,
  }) {
    final routerPath = p.join('lib', 'app', 'app_router.dart');
    final routerFile = File(routerPath);

    if (!routerFile.existsSync()) return;

    var content = routerFile.readAsStringSync();
    final className = moduleName.singular.pascalCase;
    final snakeName = moduleName.singular.snakeCase;

    // Remove import
    final importLine = "import 'package:$projectName/features/$moduleName/"
        "presentation/views/${snakeName}_view.dart';\n";
    content = content.replaceAll(importLine, '');

    // Remove route class
    final routePattern = RegExp(
      '@TypedGoRoute<${className}Route>\\(path: \'/$moduleName\'\\)\n'
      'class ${className}Route extends GoRouteData \\{[^}]*\n'
      '  @override\n'
      '  Widget build\\(BuildContext context, GoRouterState state\\)'
      ' \\{[^}]*\\}\n\\}\n*',
    );
    content = content.replaceAll(routePattern, '');

    routerFile.writeAsStringSync(content);
    logger.info(
      '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
      'Unregistered route /$moduleName',
    );
  }
}
