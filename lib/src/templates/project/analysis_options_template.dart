/// Returns the analysis_options.yaml content for a new Flutter project.
String analysisOptionsTemplate() => '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.gen.dart"
  errors:
    invalid_annotation_target: ignore
''';
