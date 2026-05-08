/// Returns the pubspec.yaml content for a new Flutter project.
String pubspecTemplate(String name) => '''
name: $name
description: A Flutter project built with Riverflow CLI using Clean Architecture.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Routing
  go_router: ^14.2.0

  # Networking
  dio: ^5.4.3+1
  connectivity_plus: ^6.0.3

  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2

  # Environment
  flutter_dotenv: ^6.0.1

  # Logging
  logger: ^2.7.0

  # Functional Programming
  dartz: ^0.10.1

  # Code Generation Annotations
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  go_router_builder: ^2.6.1

  # Linting
  riverpod_lint: ^2.3.10
  custom_lint: ^0.6.4
  flutter_lints: ^5.0.0

  # Testing
  mocktail: ^1.0.3

flutter:
  uses-material-design: true
  generate: true

  assets:
    - .env
    - assets/images/
    - assets/icons/
    - assets/fonts/
''';
