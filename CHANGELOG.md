# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-05-08

### Added

- Auto-run `flutter pub get` and `build_runner build` after project creation.
- Full dartdoc comments on all public API symbols (100% coverage).

### Removed

- `riverflow.yaml` config file — no longer needed.
- `flutter_gen_runner` from generated projects (fixes dart_style version conflict breaking build_runner).

### Changed

- `build_runner` now always runs after code generation (no config check).
- Post-creation message simplified to `cd <name>` + `flutter run`.

### Fixed

- Added `example/example.dart` for pub.dev scoring.

## [0.1.1] - 2026-05-08

### Added

- `riv watch` — Run build_runner in watch mode for continuous code generation.
- `riv delete page:<name>` — Delete a feature module and unregister its route.
- Interactive project creation — prompts for project name and company domain.
- Swift (iOS) and Kotlin (Android) as default languages.
- Production API client with token refresh, 429 retry, HTML error detection.
- API endpoints file with default auth/user endpoints.
- Local storage helper (flutter_secure_storage + shared_preferences).
- App constants loaded from `.env` via flutter_dotenv.
- Dependency injection layer (`core/di/app_providers.dart`).
- Shared folder for reusable widgets and models.
- Print log utility for debug-only logging.
- Riverpod provider wiring (ApiClient → Datasource → Repository → UseCase).
- Auto build_runner after code generation (when configured in riverflow.yaml).
- Full dartdoc comments on public API.
- User guide (`GUIDE.md`) with step-by-step examples.
- MIT License.

### Changed

- Project structure now uses `features/` instead of `app/modules/`.
- Theme moved to `core/theme/` instead of `app/theme/`.
- Router moved to `lib/app/app_router.dart`.
- Errors folder renamed to `core/errors/` (plural).
- Feature providers moved inside `presentation/providers/`.
- Screens generated in `shared/widgets/` instead of `core/widgets/`.
- Replaced `mason_logger` with `logger` package.
- Replaced `cli_completion` with `completion` package.
- Replaced `very_good_analysis` with `flutter_lints`.
- Datasources now use `ApiClient` instead of raw `Dio`.
- ViewModels now inject use cases via Riverpod providers.

## [0.1.0] - 2026-05-08

### Added

- `riv create project:<name>` — Scaffold a complete Flutter project with Clean Architecture, Riverpod, Freezed, Go Router, and Dio.
- `riv create page:<name>` — Generate a full feature module with domain, data, and presentation layers.
- `riv create viewmodel:<name> on <module>` — Generate a Riverpod Notifier-based ViewModel with Freezed state.
- `riv create view:<name> on <module>` — Generate a ConsumerWidget view with state.when() pattern matching.
- `riv create provider:<name> on <module>` — Generate a Riverpod data provider.
- `riv create screen:<name>` — Generate a responsive screen layout.
- `riv generate model on <module> with <json>` — Generate a Freezed model from JSON.
- `riv generate locales <path>` — Generate i18n translations from ARB files.
- `riv init` — Convert an existing Flutter project to Riverflow structure.
- `riv sort` — Sort and organize imports.
- `riv install <package>` — Install Flutter packages.
- `riv remove <package>` — Remove Flutter packages.
- `riv update` — Self-update the CLI.
- `--dry-run` flag for previewing changes.
- Automatic route registration in `app_router.dart`.
- `riverflow.yaml` configuration file support.
