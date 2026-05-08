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

  group('DeleteCommand', () {
    test('shows error when no argument is provided', () async {
      final exitCode = await runner.run(['delete']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err('Missing argument. Usage: riv delete page:<name>'),
      ).called(1);
    });

    test('shows error when format is invalid', () async {
      final exitCode = await runner.run(['delete', 'products']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err('Invalid format. Use: riv delete page:<name>'),
      ).called(1);
    });

    test('shows error when name is empty', () async {
      final exitCode = await runner.run(['delete', 'page:']);
      expect(exitCode, equals(ExitCode.usage));
      verify(() => logger.err('Name cannot be empty.')).called(1);
    });

    test('shows error for unsupported delete type', () async {
      final exitCode = await runner.run(['delete', 'viewmodel:test']);
      expect(exitCode, equals(ExitCode.usage));
      verify(
        () => logger.err(
          'Only page deletion is supported. Use: riv delete page:<name>',
        ),
      ).called(1);
    });

    test('shows error when module does not exist', () async {
      final exitCode = await runner.run(['delete', 'page:products']);
      expect(exitCode, equals(ExitCode.software));
    });
  });
}
