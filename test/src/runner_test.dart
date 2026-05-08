import 'package:mocktail/mocktail.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:riverflow_cli/src/version.dart';
import 'package:test/test.dart';

class _MockCliLogger extends Mock implements CliLogger {}

void main() {
  late CliLogger logger;
  late RiverflowCommandRunner runner;

  setUp(() {
    logger = _MockCliLogger();
    runner = RiverflowCommandRunner(logger: logger);
  });

  group('RiverflowCommandRunner', () {
    test('prints version when --version flag is passed', () async {
      final exitCode = await runner.run(['--version']);
      expect(exitCode, equals(ExitCode.success));
      verify(() => logger.info('riv version: $packageVersion')).called(1);
    });

    test('handles unknown command gracefully', () async {
      final exitCode = await runner.run(['nonexistent']);
      expect(exitCode, equals(ExitCode.usage));
    });
  });
}
