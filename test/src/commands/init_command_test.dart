import 'package:mocktail/mocktail.dart';
import 'package:riverflow_cli/src/runner.dart';
import 'package:riverflow_cli/src/utils/logger.dart';
import 'package:test/test.dart';

class _MockCliLogger extends Mock implements CliLogger {}

class _MockCliProgress extends Mock implements CliProgress {}

void main() {
  late CliLogger logger;
  late RiverflowCommandRunner runner;

  setUp(() {
    logger = _MockCliLogger();
    when(() => logger.progress(any())).thenReturn(_MockCliProgress());
    runner = RiverflowCommandRunner(logger: logger);
  });

  group('InitCommand', () {
    test('shows error when not in a Flutter project', () async {
      // When run from the test directory (not a Flutter project),
      // init should fail gracefully.
      final exitCode = await runner.run(['init']);
      expect(exitCode, equals(ExitCode.software));
      verify(
        () => logger.err(
          'No pubspec.yaml found. Run this from a Flutter project root.',
        ),
      ).called(1);
    });
  });
}
