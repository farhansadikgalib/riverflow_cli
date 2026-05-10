# Changelog

## [0.1.7] - 2026-05-10

- ViewModel now generates clean shell with plain sealed classes — no `@freezed`, no `.freezed.dart`
- Views use Dart 3 `switch` pattern matching instead of `.when()`
- Added `flutter_screenutil` (375x812 design) with `ScreenUtilInit` in main
- Freezed entity uses `sealed class`, model uses `abstract class` (freezed 3.x)
- Removed unused `api_end_points.dart` import from datasource template
- Updated GUIDE.md and example files with ScreenUtil, sealed state, and `Riv.snackbar()` usage

## [0.1.6] - 2026-05-10

- Added `riv test` — auto-installs `mocktail` on first run, then runs `flutter test`
- Added `Riv.snackbar(context, title:, subtitle:, color:)` utility
- `riv generate locales` auto-adds `flutter_localizations` and `generate: true`
- Replaced `dartz` Either with Dart 3 records `(T?, Failure?)`
- Updated `@riverpod` providers to use `Ref` (riverpod_annotation 4.x)
- Simplified theme to light/dark with `SystemUiOverlayStyle` status bar
- Removed `shared_preferences`, `dartz`, `riverpod_lint`, `custom_lint`, `json_annotation`, `go_router_builder`
- Fixed analyzer version conflict between `custom_lint` and `json_serializable`
- Generated project passes `flutter analyze` with zero issues

## [0.1.5] - 2026-05-10

- Added `Routes` class (`lib/app/routes.dart`) for type-safe navigation
- `riv create page` / `riv delete page` auto-registers route names in `Routes`
- `riv init` now auto-installs all required packages
- Removed `FloatingActionButton` from generated views
- API endpoints now ship fully commented out as reference
- Updated all packages to latest stable versions

## [0.1.4] - 2026-05-10

- Fixed Windows `ProcessException` — added `runInShell: true` to all process calls

## [0.1.3] - 2026-05-08

- Router uses manual `Provider<GoRouter>` instead of code gen
- Home module uses plain `Notifier` + `sealed class` instead of Freezed
- Views use Dart 3 `switch` instead of `.when()`
- Routes use `GoRoute()` instead of `@TypedGoRoute`
- Generated project compiles immediately without `build_runner`

## [0.1.2] - 2026-05-08

- Auto-run `flutter pub get` and `build_runner build` after project creation
- Removed `riverflow.yaml` config and `flutter_gen_runner`

## [0.1.1] - 2026-05-08

- Added `riv watch`, `riv delete page`, interactive prompts
- Production API client with token refresh and 429 retry
- Local storage, app constants, DI layer, print log utility
- User guide (`GUIDE.md`)

## [0.1.0] - 2026-05-08

- Initial release with `riv create`, `riv init`, `riv generate`, `riv sort`, `riv install`, `riv remove`, `riv update`
