/// Returns the app_router.dart content for a new Flutter project.
String appRouterTemplate(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:$projectName/features/home/presentation/views/home_view.dart';

part 'app_router.g.dart';

// ═══ Route Definitions ═══
// New routes are auto-registered below this line by the Riverflow CLI.
// Do not remove the marker comments.

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomeView();
  }
}

// ══════ RIVERFLOW_ROUTE_IMPORTS ══════
// ══════ RIVERFLOW_ROUTE_DEFINITIONS ══════

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    routes: \$appRoutes,
    initialLocation: '/',
    debugLogDiagnostics: true,
  );
}
''';
