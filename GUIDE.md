# Riverflow CLI — User Guide

A step-by-step guide for building Flutter apps with Riverflow CLI.

---

## 1. Create a New Project

```bash
riv create project
```

The CLI will ask:

```
  What is the name of the project?: my_shop
  What is your company's domain?  Example: com.yourcompany (com.example): com.mycompany
```

This creates a full Flutter project with Clean Architecture, Riverpod, Freezed, Go Router, and a default home module.

After creation:

```bash
cd my_shop
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Or start watch mode so code generation runs automatically:

```bash
riv watch
```

---

## 2. Create a Feature Module

Let's say you need a products feature:

```bash
riv create page:products
```

This generates the entire module:

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

The route is auto-registered in `app_router.dart`. Run build_runner to generate the code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Freezed Models — How They Work

Riverflow generates two types of Freezed classes per feature:

### Entity (Domain Layer)

`lib/features/products/domain/entities/product.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? description,
    DateTime? createdAt,
  }) = _Product;
}
```

This is your pure business object. No JSON, no framework imports.

### Model (Data Layer)

`lib/features/products/data/models/product_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_shop/features/products/domain/entities/product.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required String id,
    required String name,
    String? description,
    DateTime? createdAt,
  }) = _ProductModel;

  // JSON parsing
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  // Map to domain entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
    );
  }
}
```

### Generate a Model from JSON

If you have a JSON file, you can auto-generate the model:

```bash
riv generate model on products with data/product.json
```

Where `data/product.json` contains:

```json
{
  "id": "abc123",
  "name": "Widget Pro",
  "price": 29.99,
  "in_stock": true
}
```

This infers the Dart types and creates the Freezed model automatically.

### Using Freezed Models

```dart
// Create
final product = Product(id: '1', name: 'Widget Pro');

// Copy with modification
final updated = product.copyWith(name: 'Widget Pro Max');

// From JSON (model layer)
final model = ProductModel.fromJson(jsonMap);
final entity = model.toEntity();
```

After creating or editing any Freezed class, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. API Calls — Using the Network Layer

### Setup

Your base URL is configured in `.env`:

```
BASE_URL=https://api.myshop.com/v1/
```

And read by `lib/core/constants/app_constants.dart`:

```dart
static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://api.example.com/';
```

### Add Your Endpoints

Edit `lib/core/network/api_end_points.dart`:

```dart
class ApiEndPoints {
  ApiEndPoints._();

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refresh = 'auth/refresh';

  // Products
  static const String products = 'products';
  static String productById(String id) => 'products/$id';
  static String searchProducts(String query) => 'products/search?q=$query';
}
```

### Making API Calls in Datasource

The generated datasource already uses `ApiClient`. Here's how it works:

```dart
class ProductRemoteDatasource {
  const ProductRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  // GET — fetch all products
  Future<List<ProductModel>> getAll() async {
    final response = await _apiClient.get(
      ApiEndPoints.products,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '[]');
    return (body as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // GET — fetch single product
  Future<ProductModel> getById(String id) async {
    final response = await _apiClient.get(
      ApiEndPoints.productById(id),
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ProductModel.fromJson(body as Map<String, dynamic>);
  }

  // POST — create product
  Future<ProductModel> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndPoints.products,
      data: data,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ProductModel.fromJson(body as Map<String, dynamic>);
  }

  // PUT — update product
  Future<ProductModel> update(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiEndPoints.productById(id),
      data: data,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ProductModel.fromJson(body as Map<String, dynamic>);
  }

  // PATCH — partial update
  Future<ProductModel> patch(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiEndPoints.productById(id),
      data: data,
      requiresAuth: true,
    );
    final body = jsonDecode(response?.data?.toString() ?? '{}');
    return ProductModel.fromJson(body as Map<String, dynamic>);
  }

  // DELETE
  Future<void> delete(String id) async {
    await _apiClient.delete(ApiEndPoints.productById(id), requiresAuth: true);
  }
}
```

### Available ApiClient Methods

| Method | Auth | Use for |
|--------|------|---------|
| `get()` | optional | Fetch data |
| `post()` | optional | Create data, login, upload |
| `put()` | default on | Full update |
| `patch()` | default on | Partial update |
| `delete()` | default on | Delete |
| `getJson()` | optional | GET that returns `Map<String, dynamic>` |
| `postJson()` | optional | POST that returns `Map<String, dynamic>` |

Set `requiresAuth: true` to auto-attach the Bearer token from secure storage.

### What ApiClient Handles Automatically

- Token refresh on 401 (queues other requests until refresh completes)
- Rate limiting on 429 (retries with exponential backoff)
- HTML error page detection (retries up to 5 times)
- Connection timeout and no-internet errors
- Debug logging in development

---

## 5. Secure Storage — Saving Tokens and Data

### Saving a Token After Login

```dart
import 'package:my_shop/core/storage/local_storage.dart';
import 'package:my_shop/core/di/app_providers.dart';

// In your login method (e.g., inside auth viewmodel):
final storage = ref.read(localStorageProvider);

await storage.saveToken('Bearer eyJhbGciOiJIUzI1...');
await storage.saveRefreshToken('refresh_token_here');
```

### Reading a Token

```dart
final token = await storage.getToken();
if (token != null) {
  // User is logged in
}
```

### Clearing on Logout

```dart
await storage.clearTokens();
```

### Saving User Preferences

```dart
// Save
await storage.setBool('dark_mode', value: true);
await storage.setString('language', 'en');

// Read
final isDark = storage.getBool('dark_mode');           // false by default
final lang = storage.getString('language');              // nullable
```

### Using Storage in a Provider

```dart
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();

    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.postJson(
      ApiEndPoints.login,
      data: {'email': email, 'password': password},
    );

    if (response['access_token'] != null) {
      final storage = ref.read(localStorageProvider);
      await storage.saveToken(response['access_token']);
      state = const AuthState.loaded(data: 'Login successful');
    } else {
      state = AuthState.error(message: response['message'] ?? 'Login failed');
    }
  }
}
```

---

## 6. Routing — Navigate Between Pages

### How Routes Work

When you run `riv create page:products`, the route is auto-added to `lib/app/app_router.dart`:

```dart
import 'package:my_shop/features/products/presentation/views/product_view.dart';

@TypedGoRoute<ProductRoute>(path: '/products')
class ProductRoute extends GoRouteData {
  const ProductRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProductView();
  }
}
```

### Navigate to a Page

```dart
// From anywhere in a widget:
const ProductRoute().go(context);

// Or push (adds to stack):
const ProductRoute().push(context);
```

### Route with Parameters

To pass data to a route, edit the generated route class:

```dart
@TypedGoRoute<ProductDetailRoute>(path: '/products/:id')
class ProductDetailRoute extends GoRouteData {
  const ProductDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ProductDetailView(id: id);
  }
}
```

Navigate with parameter:

```dart
ProductDetailRoute(id: '123').go(context);
```

### Go Back

```dart
context.pop();
```

After adding or editing routes, run build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 7. Full Example — Products Feature

Here's a complete example of a products feature with a list view, API call, and widget.

### ViewModel

`lib/features/products/presentation/viewmodels/product_viewmodel.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_shop/features/products/domain/entities/product.dart';
import 'package:my_shop/features/products/presentation/providers/product_providers.dart';

part 'product_viewmodel.freezed.dart';
part 'product_viewmodel.g.dart';

@freezed
sealed class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded({required List<Product> data}) = _Loaded;
  const factory ProductState.error({required String message}) = _Error;
}

@riverpod
class ProductViewModel extends _$ProductViewModel {
  @override
  ProductState build() {
    return const ProductState.initial();
  }

  Future<void> loadProducts() async {
    state = const ProductState.loading();
    final useCase = ref.read(getProductsUseCaseProvider);
    final result = await useCase();
    result.fold(
      (failure) => state = ProductState.error(message: failure.toString()),
      (products) => state = ProductState.loaded(data: products),
    );
  }

  Future<void> deleteProduct(String id) async {
    // Optimistic update — remove from list immediately
    final current = state;
    if (current is _Loaded) {
      state = ProductState.loaded(
        data: current.data.where((p) => p.id != id).toList(),
      );
    }
  }
}
```

### View with Widgets

`lib/features/products/presentation/views/product_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_shop/features/products/domain/entities/product.dart';
import 'package:my_shop/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:my_shop/features/products/presentation/widgets/product_card.dart';

class ProductView extends ConsumerStatefulWidget {
  const ProductView({super.key});

  @override
  ConsumerState<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<ProductView> {
  @override
  void initState() {
    super.initState();
    // Load products when the page opens
    Future.microtask(
      () => ref.read(productViewModelProvider.notifier).loadProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: state.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (products) => _buildProductList(products),
        error: (message) => _buildError(message),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(productViewModelProvider.notifier)
            .loadProducts(),
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(productViewModelProvider.notifier)
          .loadProducts(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(
            product: products[index],
            onTap: () {
              // Navigate to detail
              // ProductDetailRoute(id: products[index].id).go(context);
            },
            onDelete: () {
              ref
                  .read(productViewModelProvider.notifier)
                  .deleteProduct(products[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref
                .read(productViewModelProvider.notifier)
                .loadProducts(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

### Reusable Widget

`lib/features/products/presentation/widgets/product_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:my_shop/features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          product.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: product.description != null
            ? Text(
                product.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
```

---

## 8. Quick Command Reference

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
riv update
```

---

## 9. Build Runner Commands

After any change to Freezed, Riverpod, Go Router, or JSON serializable files:

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on save)
riv watch
```

If you get conflicts:

```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```
