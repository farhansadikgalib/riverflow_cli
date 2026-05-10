import 'package:riverflow_cli/src/utils/string_utils.dart';

/// Holds information about a generated class.
class ClassDefinition {
  ClassDefinition({
    required this.className,
    required this.fields,
    this.jsonKeys = const {},
  });

  /// PascalCase class name without "Model" suffix (e.g. "Product").
  final String className;

  /// Dart field name → Dart type.
  final Map<String, String> fields;

  /// Dart field name → original JSON key (only entries where they differ).
  final Map<String, String> jsonKeys;
}

/// Returns a Freezed model file content generated from JSON fields.
///
/// [classes] must have the main/root class at index 0; nested classes follow.
String jsonModelTemplate({
  required String projectName,
  required String moduleName,
  required String className,
  required List<ClassDefinition> classes,
}) {
  final snakeName = className.snakeCase;
  final entityFile = moduleName.singular.snakeCase;

  final buf = StringBuffer();

  // ── Imports & parts ──────────────────────────────────────────────────
  buf.writeln("import 'package:freezed_annotation/freezed_annotation.dart';");
  buf.writeln(
    "import 'package:$projectName/features/$moduleName/domain/entities/$entityFile.dart';",
  );
  buf.writeln();
  buf.writeln("part '${snakeName}_model.freezed.dart';");
  buf.writeln("part '${snakeName}_model.g.dart';");

  // ── Generate each class ──────────────────────────────────────────────
  for (var i = 0; i < classes.length; i++) {
    final cls = classes[i];
    final isRoot = i == 0;
    final pascal = cls.className;

    buf.writeln();
    buf.writeln('@freezed');
    buf.writeln('abstract class ${pascal}Model with _\$${pascal}Model {');
    buf.writeln('  const ${pascal}Model._();');
    buf.writeln();
    buf.writeln('  const factory ${pascal}Model({');

    for (final entry in cls.fields.entries) {
      final fieldName = entry.key;
      final fieldType = entry.value;
      final jsonKey = cls.jsonKeys[fieldName];

      if (jsonKey != null) {
        buf.writeln("    @JsonKey(name: '$jsonKey')");
      }

      if (_isRequired(fieldType)) {
        buf.writeln('    required $fieldType $fieldName,');
      } else {
        buf.writeln('    $fieldType? $fieldName,');
      }
    }

    buf.writeln('  }) = _${pascal}Model;');
    buf.writeln();
    buf.writeln(
      '  factory ${pascal}Model.fromJson(Map<String, dynamic> json) =>',
    );
    buf.writeln('      _\$${pascal}ModelFromJson(json);');

    // Only the root class gets a toEntity() method.
    if (isRoot) {
      final entityName = moduleName.singular.pascalCase;
      buf.writeln();
      buf.writeln('  $entityName toEntity() {');
      buf.writeln('    return $entityName(');
      for (final entry in cls.fields.entries) {
        buf.writeln('      ${entry.key}: ${entry.key},');
      }
      buf.writeln('    );');
      buf.writeln('  }');
    }

    buf.writeln('}');
  }

  return buf.toString();
}

/// Primitive types that should be `required` (non-nullable).
bool _isRequired(String type) {
  return type == 'String' ||
      type == 'int' ||
      type == 'double' ||
      type == 'bool';
}

/// Infers a Dart type string from a JSON [value].
///
/// When the value is a nested object, [fieldName] is used to derive the class
/// name (e.g. field `"address"` → type `AddressModel`).
///
/// When the value is a list, the first element is inspected to produce a typed
/// list (e.g. `List<String>`, `List<OrderModel>`).
String inferDartType(dynamic value, String fieldName) {
  if (value == null) return 'dynamic';
  if (value is bool) return 'bool'; // must come before int (bool is not int in Dart, but just to be safe)
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is String) return 'String';
  if (value is List) {
    if (value.isEmpty) return 'List<dynamic>';
    final first = value.first;
    if (first is Map<String, dynamic>) {
      return 'List<${fieldName.singular.pascalCase}Model>';
    }
    return 'List<${inferDartType(first, fieldName)}>';
  }
  if (value is Map) {
    return '${fieldName.pascalCase}Model';
  }
  return 'dynamic';
}
