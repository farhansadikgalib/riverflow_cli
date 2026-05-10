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
  cupertino_icons: ^1.0.9

  # State Management
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

  # Routing
  go_router: ^17.2.3

  # Networking
  dio: ^5.9.2
  connectivity_plus: ^7.1.1

  # Storage
  flutter_secure_storage: ^10.1.0
  shared_preferences: ^2.5.5

  # Environment
  flutter_dotenv: ^6.0.1

  # Logging
  logger: ^2.7.0

  # Functional Programming
  dartz: ^0.10.1

  # Code Generation Annotations
  freezed_annotation: ^3.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.15.0
  freezed: ^3.2.5
  json_serializable: ^6.13.2
  riverpod_generator: ^4.0.3

  # Linting
  riverpod_lint: ^3.1.3
  custom_lint: ^0.8.1
  flutter_lints: ^6.0.0

  # Testing
  mocktail: ^1.0.5

flutter:
  uses-material-design: true
  generate: true

  assets:
    - .env
    - assets/images/
    - assets/icons/
    - assets/fonts/
''';
