import 'dart:io';

import 'package:riverflow_cli/src/runner.dart';

Future<void> main(List<String> args) async {
  final exitCode = await RiverflowCommandRunner().run(args);
  exit(exitCode);
}
