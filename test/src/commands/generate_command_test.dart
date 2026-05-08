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

  group('GenerateCommand', () {
    test('shows error when no argument is provided', () async {
      final exitCode = await runner.run(['generate']);
      expect(exitCode, equals(ExitCode.usage));
    });

    test('shows error for unknown generate type', () async {
      final exitCode = await runner.run(['generate', 'unknown']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err(
          'Unknown generate type "unknown". Available: model, locales',
        ),
      ).called(1);
    });

    test('shows error when model is missing module or json path', () async {
      final exitCode = await runner.run(['generate', 'model']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err(
          'Usage: riv generate model on <module> with <json_path>',
        ),
      ).called(1);
    });
  });
}
