/// Riverflow CLI — Usage Examples
///
/// Install:
/// ```bash
/// dart pub global activate riverflow_cli
/// ```
///
/// Create a new project:
/// ```bash
/// riv create project:my_app
/// ```
///
/// Create a feature module:
/// ```bash
/// riv create page:products
/// ```
///
/// Create individual components:
/// ```bash
/// riv create viewmodel:cart on products
/// riv create view:cart on products
/// riv create provider:auth on users
/// riv create screen:settings
/// ```
///
/// Delete a feature module:
/// ```bash
/// riv delete page:products
/// ```
///
/// Generate model from JSON:
/// ```bash
/// riv generate model on products with data/product.json
/// ```
///
/// Watch mode (continuous code generation):
/// ```bash
/// riv watch
/// ```
///
/// Package management:
/// ```bash
/// riv install dio
/// riv install mocktail --dev
/// riv remove unused_pkg
/// ```
///
/// Other:
/// ```bash
/// riv sort          # sort imports
/// riv update        # update CLI
/// riv init          # convert existing project
/// riv --version     # show version
/// ```
library;

import 'package:riverflow_cli/riverflow_cli.dart';

Future<void> main() async {
  // Run the CLI programmatically
  final exitCode = await RiverflowCommandRunner().run(['--version']);
  // ignore: avoid_print
  print('Exit code: $exitCode');
}
