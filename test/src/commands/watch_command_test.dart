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

  group('WatchCommand', () {
    test('shows error when not in a Flutter project', () async {
      final exitCode = await runner.run(['watch']);
      expect(exitCode, equals(ExitCode.software));
      verify(
        () => logger.err(
          'Not in a Flutter project. Run this from your project root.',
        ),
      ).called(1);
    });
  });
}
