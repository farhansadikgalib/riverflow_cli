/// String utility extensions for case conversion used in code generation.
extension StringUtils on String {
  /// Converts a string to PascalCase.
  /// Example: 'my_feature' -> 'MyFeature'
  String get pascalCase {
    if (isEmpty) return this;
    return split(RegExp(r'[_\-\s]+'))
        .where((s) => s.isNotEmpty)
        .map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase())
        .join();
  }

  /// Converts a string to camelCase.
  /// Example: 'my_feature' -> 'myFeature'
  String get camelCase {
    final pascal = pascalCase;
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Converts a string to snake_case.
  /// Example: 'MyFeature' -> 'my_feature'
  String get snakeCase {
    if (isEmpty) return this;
    final result = replaceAllMapped(
      RegExp('([A-Z])'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
    return result.startsWith('_') ? result.substring(1) : result;
  }

  /// Returns the singular form by removing trailing 's'.
  /// Simple heuristic — covers common cases like 'products' -> 'product'.
  String get singular {
    if (length > 1 && endsWith('s') && !endsWith('ss')) {
      return substring(0, length - 1);
    }
    return this;
  }

  /// Validates that the string is a valid Dart identifier.
  bool get isValidDartIdentifier {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(this);
  }

  /// Validates that the string is a valid Dart package name.
  bool get isValidPackageName {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(this) &&
        !_dartReservedWords.contains(this);
  }
}

const _dartReservedWords = <String>{
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'function',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};
