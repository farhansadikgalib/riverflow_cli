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

  group('CreateCommand', () {
    test('shows error when no argument is provided', () async {
      final exitCode = await runner.run(['create']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err('Missing argument. Usage: riv create <type>:<name>'),
      ).called(1);
    });

    test('shows error when page name is missing', () async {
      final exitCode = await runner.run(['create', 'page']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err('Missing name. Use: riv create page:<name>'),
      ).called(1);
    });

    test('shows error for unknown type', () async {
      final exitCode = await runner.run(['create', 'unknown:test']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err(
          'Unknown type "unknown". '
          'Available: project, page, viewmodel, view, provider, screen',
        ),
      ).called(1);
    });

    test('shows error when viewmodel has no module', () async {
      final exitCode = await runner.run(['create', 'viewmodel:product']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err(
          'Missing module. Usage: riv create viewmodel:product on <module>',
        ),
      ).called(1);
    });

    test('shows error when view has no module', () async {
      final exitCode = await runner.run(['create', 'view:product']);
      expect(exitCode, equals(ExitCode.usage));
    });

    test('shows error when provider has no module', () async {
      final exitCode = await runner.run(['create', 'provider:product']);
      expect(exitCode, equals(ExitCode.usage));
    });
  });
}
