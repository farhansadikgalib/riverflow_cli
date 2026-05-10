# Riverflow CLI — User Guide

A step-by-step guide for building Flutter apps with Riverflow CLI.

---

## 1. Create a New Project

```bash
riv create project
```

The CLI will ask for a project name and company domain, then scaffolds a full Flutter project with Clean Architecture, Riverpod, Freezed, Go Router, ScreenUtil, and a default home module.

```bash
cd my_shop
flutter run
```

---

## 2. Create a Feature Module

```bash
riv create page:products
```

This generates the entire module and auto-registers the route:

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
    ├── providers/product_providers.dart
    ├── viewmodels/product_viewmodel.dart
    ├── views/product_view.dart
    └── widgets/
```

---

## 3. ViewModel — Adding Methods

The generated viewmodel is a clean shell:

```dart
@riverpod
class ProductViewModel extends _$ProductViewModel {
  @override
  dynamic build() => null;
}
```

Add your own state and methods as needed:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_shop/features/products/domain/entities/product.dart';
import 'package:my_shop/features/products/presentation/providers/product_providers.dart';

part 'product_viewmodel.g.dart';

// ── State ────────────────────────────────────────────────────────────────────

sealed class ProductState {
  const ProductState();
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  const ProductLoaded({required this.products});
  final List<Product> products;
}

class ProductError extends ProductState {
  const ProductError({required this.message});
  final String message;
}

// ── ViewModel ────────────────────────────────────────────────────────────────

@riverpod
class ProductViewModel extends _$ProductViewModel {
  @override
  ProductState build() => const ProductInitial();

  Future<void> loadProducts() async {
    state = const ProductLoading();
    final useCase = ref.read(getProductsUseCaseProvider);
    final (data, failure) = await useCase();
    if (failure != null) {
      state = ProductError(message: failure.toString());
    } else {
      state = ProductLoaded(products: data ?? []);
    }
  }

  Future<void> deleteProduct(String id) async {
    final current = state;
    if (current is ProductLoaded) {
      state = ProductLoaded(
        products: current.products.where((p) => p.id != id).toList(),
      );
    }
  }
}
```

Then use it in the view with Dart 3 `switch`:

```dart
final state = ref.watch(productViewModelProvider);

body: switch (state) {
  ProductLoading() => const Center(child: CircularProgressIndicator()),
  ProductLoaded(:final products) => ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) => Text(products[i].name),
    ),
  ProductError(:final message) => Center(child: Text(message)),
  _ => const SizedBox.shrink(),
},
```

After editing, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. ScreenUtil — Responsive Sizing

ScreenUtil is pre-configured with a `375x812` design size (iPhone ratio). Use the `.w`, `.h`, `.sp`, `.r` extensions for responsive sizing:

```dart
import 'package:flutter_screenutil/flutter_screenutil.dart';

Container(
  width: 200.w,                      // responsive width
  height: 50.h,                      // responsive height
  padding: EdgeInsets.all(16.r),     // responsive radius/padding
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp), // responsive font size
  ),
)
```

Common patterns:

```dart
// Spacing
SizedBox(height: 16.h)
SizedBox(width: 8.w)

// Border radius
BorderRadius.circular(12.r)

// Edge insets
EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h)

// Icon size
Icon(Icons.home, size: 24.r)
```

---

## 5. Snackbar — Riv.snackbar()

Show snackbars with `Riv.snackbar()`:

```dart
import 'package:my_shop/core/utils/riv_snackbar.dart';

// Success
Riv.snackbar(
  context,
  title: 'Success',
  subtitle: 'Product saved successfully.',
  color: Colors.green,
);

// Error
Riv.snackbar(
  context,
  title: 'Error',
  subtitle: 'Something went wrong.',
  color: Colors.red,
);

// Info (uses theme primary color by default)
Riv.snackbar(
  context,
  title: 'Info',
  subtitle: 'Your cart has been updated.',
);
```

---

## 6. Routing — Type-Safe Navigation

Routes are defined in `lib/app/routes.dart`:

```dart
class Routes {
  Routes._();
  static const String home = '/';
  static const String products = '/products';
  static const String auth = '/auth';
}
```

Navigate using route constants:

```dart
import 'package:go_router/go_router.dart';
import 'package:my_shop/app/routes.dart';

// Go (replaces current)
context.go(Routes.products);

// Push (adds to stack)
context.push(Routes.auth);

// Go back
context.pop();
```

When you run `riv create page:orders`, the route is auto-registered in both `routes.dart` and `app_router.dart`.

---

## 7. Freezed Models

### Entity (Domain Layer) — immutable business object

```dart
@freezed
sealed class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? description,
  }) = _Product;
}
```

### Model (Data Layer) — handles JSON

```dart
@freezed
abstract class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required String id,
    required String name,
    String? description,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Product toEntity() => Product(id: id, name: name, description: description);
}
```

### Generate from JSON

```bash
riv generate model on products with data/product.json
```

### Usage

```dart
final product = Product(id: '1', name: 'Widget Pro');
final updated = product.copyWith(name: 'Widget Pro Max');

final model = ProductModel.fromJson(jsonMap);
final entity = model.toEntity();
```

---

## 8. API Calls

### Setup

Set your base URL in `.env`:

```
BASE_URL=https://api.myshop.com/v1/
```

Uncomment endpoints in `lib/core/network/api_end_points.dart`:

```dart
class ApiEndPoints {
  ApiEndPoints._();

  static const String login = 'auth/login';
  static const String products = 'products';
  static String productById(String id) => 'products/$id';
}
```

### Datasource example

```dart
Future<List<ProductModel>> getAll() async {
  final response = await _apiClient.get(
    '/products',
    requiresAuth: true,
  );
  final body = jsonDecode(response?.data?.toString() ?? '[]');
  return (body as List)
      .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
      .toList();
}
```

### Repository — error handling with records

```dart
Future<(List<Product>?, Failure?)> getAll() async {
  try {
    final models = await _remoteDatasource.getAll();
    return (models.map((m) => m.toEntity()).toList(), null);
  } on DioException catch (e) {
    return (null, Failure.server(
      message: e.message ?? 'Server error',
      statusCode: e.response?.statusCode,
    ));
  }
}
```

### Consuming in ViewModel

```dart
final (data, failure) = await useCase();
if (failure != null) {
  state = ProductError(message: failure.toString());
} else {
  state = ProductLoaded(products: data ?? []);
}
```

---

## 9. Secure Storage

```dart
final storage = ref.read(localStorageProvider);

// Tokens
await storage.saveToken('Bearer eyJhbG...');
await storage.saveRefreshToken('refresh_token_here');
final token = await storage.getToken();
await storage.clearTokens();

// Generic key-value
await storage.write('user_id', '12345');
final userId = await storage.read('user_id');
await storage.delete('user_id');
await storage.clearAll();
```

---

## 10. Testing

```bash
riv test
```

This auto-installs `mocktail` on first run, then executes `flutter test`. Pass arguments through:

```bash
riv test --coverage
```

---

## 11. Localization

```bash
riv generate locales lib/l10n
```

This auto-adds `flutter_localizations` and `generate: true` to your pubspec, then runs `flutter gen-l10n`.

---

## 12. Quick Command Reference

```bash
# Project
riv create project              # interactive
riv create project:my_app       # with name

# Feature module
riv create page:products        # full module
riv delete page:products        # remove module

# Components
riv create viewmodel:cart on products
riv create view:cart on products
riv create provider:auth on users
riv create screen:settings

# Code generation
riv generate model on products with data/product.json
riv generate locales lib/l10n
riv watch                       # continuous build_runner

# Utilities
riv install dio
riv install mocktail --dev
riv remove unused_pkg
riv sort
riv test
riv update
```

---

## 13. Build Runner

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode
riv watch

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```
