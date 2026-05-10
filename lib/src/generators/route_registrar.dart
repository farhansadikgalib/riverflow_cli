import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Handles automatic route registration in app_router.dart.
class RouteRegistrar {
  const RouteRegistrar({required this.logger});

  final CliLogger logger;

  /// Registers a new route for the given module in app_router.dart and
  /// routes.dart.
  void registerRoute({
    required String moduleName,
    required String projectName,
  }) {
    _registerRouterEntry(moduleName: moduleName, projectName: projectName);
    _registerRouteName(moduleName: moduleName);
  }

  /// Adds the GoRoute entry and import to app_router.dart.
  void _registerRouterEntry({
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
    const routeMarker = '// ══════ RIVERFLOW_ROUTES ══════';

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

    // Add route entry using Routes constant
    final routeEntry = '''GoRoute(
        path: Routes.$moduleName,
        name: '$moduleName',
        builder: (context, state) => const ${className}View(),
      ),''';

    if (content.contains(routeMarker) &&
        !content.contains("name: '$moduleName'")) {
      content = content.replaceFirst(
        routeMarker,
        '$routeEntry\n      $routeMarker',
      );
    }

    routerFile.writeAsStringSync(content);
    logger.info(
      '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
      'Registered route /$moduleName in app_router.dart',
    );
  }

  /// Adds a named constant to routes.dart.
  void _registerRouteName({required String moduleName}) {
    final routesPath = p.join('lib', 'app', 'routes.dart');
    final routesFile = File(routesPath);

    if (!routesFile.existsSync()) return;

    var content = routesFile.readAsStringSync();
    const marker = '// ══════ RIVERFLOW_ROUTE_NAMES ══════';

    final routeLine =
        "  static const String $moduleName = '/$moduleName';";

    if (content.contains(marker) && !content.contains(routeLine)) {
      content = content.replaceFirst(
        marker,
        '$routeLine\n  $marker',
      );
      routesFile.writeAsStringSync(content);
    }
  }

  /// Removes a route registration for the given module.
  void unregisterRoute({
    required String moduleName,
    required String projectName,
  }) {
    _unregisterRouterEntry(moduleName: moduleName, projectName: projectName);
    _unregisterRouteName(moduleName: moduleName);
  }

  void _unregisterRouterEntry({
    required String moduleName,
    required String projectName,
  }) {
    final routerPath = p.join('lib', 'app', 'app_router.dart');
    final routerFile = File(routerPath);

    if (!routerFile.existsSync()) return;

    var content = routerFile.readAsStringSync();
    final snakeName = moduleName.singular.snakeCase;

    // Remove import
    final importLine = "import 'package:$projectName/features/$moduleName/"
        "presentation/views/${snakeName}_view.dart';\n";
    content = content.replaceAll(importLine, '');

    // Remove route entry
    final routePattern = RegExp(
      r"GoRoute\(\s*path: Routes\." +
          moduleName +
          r".*?\),\s*",
      dotAll: true,
    );
    content = content.replaceAll(routePattern, '');

    routerFile.writeAsStringSync(content);
    logger.info(
      '${AnsiColor.wrap('✓', AnsiColor.lightGreen)} '
      'Unregistered route /$moduleName',
    );
  }

  void _unregisterRouteName({required String moduleName}) {
    final routesPath = p.join('lib', 'app', 'routes.dart');
    final routesFile = File(routesPath);

    if (!routesFile.existsSync()) return;

    var content = routesFile.readAsStringSync();

    final routeLinePattern = RegExp(
      r"  static const String " + moduleName + r" = '.*?';\n",
    );
    content = content.replaceAll(routeLinePattern, '');

    routesFile.writeAsStringSync(content);
  }
}
