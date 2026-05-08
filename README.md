# Riverflow CLI

Modern Flutter scaffolding tool for **Riverpod + Clean Architecture + Freezed + Go Router**.

One command to generate a full feature module with all layers wired up.

**New here?** Read the [User Guide](GUIDE.md) for step-by-step examples with real code.

## Install

```bash
dart pub global activate riverflow_cli
```

## Commands

### Create a project

```bash
riv create project:my_app
```

Generates a ready-to-run Flutter project with:
- Clean Architecture folder structure
- Home module (view + viewmodel)
- Go Router with typed routes
- API client (Dio) with token refresh, retry, error handling
- API endpoints file
- Local storage (secure + shared preferences)
- Dependency injection via Riverpod providers
- App constants from `.env` (via flutter_dotenv)
- Freezed failure types
- Material 3 theme (light + dark)
- Shared widgets and models folders
- All dependencies pre-configured

### Create a feature module

```bash
riv create page:products
```

Generates the full Clean Architecture module in one shot:

```
lib/features/products/
├── data/
│   ├── datasources/product_remote_datasource.dart
│   ├── models/product_model.dart
│   └── repositories/product_repository_impl.dart
├── domain/
│   ├── entities/product.dart
│   ├── repositories/product_repository.dart
│   └── usecases/get_products_usecase.dart
└── presentation/
    ├── providers/product_providers.dart    # DI wiring
    ├── viewmodels/product_viewmodel.dart
    ├── views/product_view.dart
    └── widgets/
```

Also auto-registers the route in `app_router.dart` and runs `build_runner` if configured.

### Create individual components

```bash
riv create viewmodel:cart on products    # Riverpod ViewModel + Freezed state
riv create view:cart on products         # ConsumerWidget with state.when()
riv create provider:auth on users        # @riverpod data provider
riv create screen:settings               # Responsive layout (mobile/tablet/desktop)
```

### Delete a feature module

```bash
riv delete page:products           # asks for confirmation
riv delete page:products --force   # skip confirmation
```

Removes the module directory and unregisters its route.

### Generate model from JSON

```bash
riv generate model on products with data/product.json
```

Reads the JSON, infers Dart types, outputs a Freezed model with `fromJson()` and `toEntity()`.

### Generate translations

```bash
riv generate locales lib/l10n
```

### Convert existing project

```bash
riv init
```

Adds the Riverflow folder structure and core files to an existing Flutter project. Skips files that already exist.

### Watch mode

```bash
riv watch
```

Runs `build_runner watch` for continuous code generation. Press Ctrl+C to stop.

### Package management

```bash
riv install dio                   # add package
riv install mocktail --dev        # add dev package
riv remove unused_pkg             # remove package
```

### Other

```bash
riv sort                          # sort imports
riv update                        # update CLI to latest version
riv --version                     # show version
riv help                          # show all commands
riv create --help                 # help for a specific command
```

## Flags

| Flag | Used with | What it does |
|------|-----------|-------------|
| `--dry-run` | create, generate, init | Preview without writing files |
| `--on <module>` | viewmodel, view, provider | Target module |
| `--dev` / `-d` | install | Install as dev dependency |
| `--force` / `-f` | delete | Skip confirmation |

## Project Structure

```
my_app/
├── lib/
│   ├── core/                              # Core utilities and config
│   │   ├── constants/
│   │   │   └── app_constants.dart         # reads from .env
│   │   ├── errors/
│   │   │   └── failure.dart               # Freezed failure types
│   │   ├── network/
│   │   │   ├── api_client.dart            # Dio wrapper with auth/retry
│   │   │   └── api_end_points.dart        # endpoint constants
│   │   ├── storage/
│   │   │   └── local_storage.dart         # secure + shared prefs
│   │   ├── utils/
│   │   │   └── print_log.dart
│   │   ├── di/
│   │   │   └── app_providers.dart         # global Riverpod providers
│   │   └── theme/
│   │       └── app_theme.dart
│   │
│   ├── features/                          # Feature-based modules
│   │   ├── home/                          # default module
│   │   └── products/                      # riv create page:products
│   │       ├── data/
│   │       │   ├── datasources/           # remote & local data sources
│   │       │   ├── models/                # Freezed models
│   │       │   └── repositories/          # repository implementations
│   │       ├── domain/
│   │       │   ├── entities/              # business entities
│   │       │   ├── repositories/          # abstract contracts
│   │       │   └── usecases/              # business use cases
│   │       └── presentation/
│   │           ├── providers/             # Riverpod DI wiring
│   │           ├── viewmodels/            # state management (MVVM)
│   │           ├── views/                 # screens and pages
│   │           └── widgets/               # feature-specific widgets
│   │
│   ├── shared/                            # Shared across features
│   │   ├── widgets/                       # reusable UI components
│   │   └── models/                        # shared/common models
│   │
│   ├── app/
│   │   └── app_router.dart                # routes auto-registered
│   │
│   └── main.dart
│
├── .env                                    # APP_VERSION, BASE_URL
├── assets/
└── pubspec.yaml
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
