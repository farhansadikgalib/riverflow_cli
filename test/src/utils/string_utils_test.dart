import 'package:riverflow_cli/src/utils/string_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringUtils', () {
    group('pascalCase', () {
      test('converts snake_case', () {
        expect('my_feature'.pascalCase, equals('MyFeature'));
      });

      test('converts single word', () {
        expect('feature'.pascalCase, equals('Feature'));
      });

      test('converts multi-word with hyphens', () {
        expect('my-feature'.pascalCase, equals('MyFeature'));
      });

      test('handles empty string', () {
        expect(''.pascalCase, equals(''));
      });
    });

    group('camelCase', () {
      test('converts snake_case', () {
        expect('my_feature'.camelCase, equals('myFeature'));
      });

      test('converts single word', () {
        expect('feature'.camelCase, equals('feature'));
      });
    });

    group('snakeCase', () {
      test('converts PascalCase', () {
        expect('MyFeature'.snakeCase, equals('my_feature'));
      });

      test('converts camelCase', () {
        expect('myFeature'.snakeCase, equals('my_feature'));
      });

      test('handles single lowercase word', () {
        expect('feature'.snakeCase, equals('feature'));
      });
    });

    group('singular', () {
      test('removes trailing s', () {
        expect('products'.singular, equals('product'));
      });

      test('does not modify non-plural words', () {
        expect('boss'.singular, equals('boss'));
      });

      test('does not modify single character', () {
        expect('s'.singular, equals('s'));
      });
    });

    group('isValidDartIdentifier', () {
      test('accepts valid identifiers', () {
        expect('my_feature'.isValidDartIdentifier, isTrue);
        expect('feature1'.isValidDartIdentifier, isTrue);
      });

      test('rejects invalid identifiers', () {
        expect('MyFeature'.isValidDartIdentifier, isFalse);
        expect('1feature'.isValidDartIdentifier, isFalse);
        expect('my-feature'.isValidDartIdentifier, isFalse);
      });
    });

    group('isValidPackageName', () {
      test('accepts valid package names', () {
        expect('my_package'.isValidPackageName, isTrue);
      });

      test('rejects reserved words', () {
        expect('class'.isValidPackageName, isFalse);
        expect('void'.isValidPackageName, isFalse);
      });
    });
  });
}
