# EV Connect India — Agent Guide

This file documents conventions, patterns, and architecture rules for LLM coding agents working on this project.

## Project Overview

```
ev-connect-india/
├── backend/           # Node.js + Express API
├── frontend/          # Flutter mobile app
└── admin-dashboard/   # React admin panel
```

---

## Coding Conventions

### General

- **No comments in code** — code should be self-documenting via clear naming
- Follow existing patterns rather than introducing new ones
- Keep functions focused — do one thing well
- Use meaningful, descriptive names (even if long)

### Dart / Flutter

- **Naming:** `camelCase` for variables, functions, and parameters; `PascalCase` for classes, enums, and types; `lowercase_with_underscores` for file names and directories
- **Imports:** group by: (1) Dart SDK, (2) Flutter/packages, (3) project imports, with blank line separators
- **Constants:** prefer `static const` in classes rather than top-level constants; use `AppConfig` class for app-wide config
- **Constructors:** use `const` constructors wherever possible; use `super` parameters
- **Null safety:** prefer nullable fields (`?`) over `late`; avoid `!` operator outside of tests
- **Model classes:** always implement `fromJson` factory and `toJson` method; use `copyWith` for immutability

### JavaScript / Node.js

- **Naming:** `camelCase` for variables and functions; `PascalCase` for classes; `UPPER_SNAKE_CASE` for constants
- **ESM:** use `import`/`export` syntax (the project uses `"type": "module"`)
- **Async:** prefer `async/await` over `.then()`
- **Error handling:** use `try/catch` with meaningful error messages; pass errors to Express error middleware
- **Route handlers:** keep controllers thin — business logic goes in controllers, validation in middleware

---

## Riverpod Patterns (Flutter)

### StateNotifierProvider

Use for complex mutable state with methods to modify it:

```dart
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(const MyState());

  void doSomething() {
    state = state.copyWith(/* ... */);
  }
}

final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});
```

### Provider

Use for derived/computed state or simple dependency injection:

```dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
```

### State Notifier Rules

- State classes are **immutable** — always use `copyWith` to create new instances
- State enums use a `status` field (e.g., `AuthStatus.initial`, `loading`, `authenticated`, `error`)
- Error is stored as a nullable `String?` field cleared before each operation
- Providers are defined at the bottom of the file after the notifier class

---

## GoRouter Patterns (Flutter)

- Routes are defined in `config/routes.dart` using `GoRouter` with `ShellRoute` for bottom navigation
- Route paths are stored as `static const` in the `Routes` class
- Route parameters (e.g., `:id`) are accessed via `state.pathParameters`
- Auth redirect logic lives in the `redirect` callback on the router
- All screens are `const` constructors

### Route Names

```dart
Routes.home          // /home
Routes.map           // /map
Routes.search        // /search
Routes.favorites     // /favorites
Routes.profile       // /profile
Routes.login         // /login
Routes.phoneLogin    // /phone-login
Routes.addStation    // /add-station
Routes.routePlanner  // /route-planner
Routes.stationDetails(id)  // /station/:id
Routes.addReview(stationId) // /station/:id/review
Routes.reportIssue(stationId) // /station/:id/report
```

---

## Theme System

- Define colors in `theme/color_schemes.dart` using the `EVColorSchemes` class
- Build themes in `theme/app_theme.dart` using `AppTheme.lightTheme` and `AppTheme.darkTheme`
- Theme is controlled by `themeProvider` (a `StateProvider<ThemeMode>`)
- All widgets use `Theme.of(context)` and `colorScheme` for colors — no hardcoded color values
- Custom EV colors: primary green (`#00C853`), secondary blue (`#2196F3`), tertiary amber (`#FFC107`)

### Adding a New Color

1. Add the color as a `static const` in `EVColorSchemes`
2. Add it to the `lightColorScheme` and `darkColorScheme` if it's a semantic color
3. Reference it as `Theme.of(context).colorScheme.primary` (or your custom property)

---

## API Integration Patterns

### ApiService Singleton

```dart
final api = ApiService();
final response = await api.get('/stations/nearby', queryParams: {
  'lat': '19.0602',
  'lng': '72.8697',
});
```

### API Call in Provider

```dart
Future<void> loadStations() async {
  state = state.copyWith(status: AsyncValue.loading);
  final response = await api.get('/stations');
  if (response.isSuccess) {
    final stations = (response.data!['data'] as List)
        .map((j) => Station.fromJson(j))
        .toList();
    state = state.copyWith(status: AsyncValue.data(stations));
  }
}
```

### Error Handling

- `ApiService` returns `ApiResponse` — check `isSuccess` before accessing data
- Network errors return `statusCode: -1` with a user-friendly message
- Token expiry triggers automatic refresh via `_executeWithAuth`
- Show errors via `ScaffoldMessenger` snackbar or error state widgets

### Endpoint Conventions

- All responses wrapped in `{ "success": bool, "data": ..., "message": ... }`
- Paginated responses include `"pagination": { "page", "limit", "total", "total_pages" }`
- Errors follow `{ "success": false, "message": "...", "errors": {...} }`

---

## Model Conventions

- Every model has `fromJson()` factory and `toJson()` method
- Use `Station.fromJson(json)` for deserialization
- Use `station.toJson()` for serialization
- Provide `copyWith()` for immutable updates
- Computed properties go as `get` methods (e.g., `isAvailable`, `priceRange`)

---

## Project Structure Rules

### Feature-Based Organization

Each feature in `frontend/lib/features/` is self-contained:
```
features/
├── auth/
│   ├── login_screen.dart
│   └── phone_login_screen.dart
├── home/
│   ├── home_screen.dart
│   └── main_shell.dart
├── station_details/
│   ├── station_details_screen.dart
│   ├── review_screen.dart
│   └── report_issue_screen.dart
...
```

### Shared Code

- **widgets/** — reusable widgets used in multiple features
- **services/** — API clients, auth, location, caching
- **providers/** — state management (Riverpod notifiers)
- **models/** — data models shared across features
- **theme/** — app theme and color definitions
- **utils/** — formatters, validators, constants
- **config/** — app config and routing

---

## Testing Strategy

- **Unit tests:** test models, utils, and services (`frontend/test/unit/`)
- **Widget tests:** test individual widgets (`frontest/test/widget/`)
- **Integration tests:** test full flows (`frontend/test/integration/`)
- Use `mocktail` for mocking dependencies
- Test provider state transitions, error states, and loading states

### Running Tests

```bash
cd frontend
flutter test
flutter test --coverage
```

### Backend Testing

```bash
cd backend
npm test
```

---

## Common Pitfalls

### 1. Forgetting `const` on Widget Constructors
Always use `const` constructor for widgets: `const MyWidget({super.key})`.

### 2. Not Using `copyWith`
Never mutate state properties directly — always use `state = state.copyWith(...)`.

### 3. Blocking the UI Thread
All API calls, file I/O, and heavy computations must be in `async` methods. Use `compute()` for CPU-intensive work.

### 4. Missing Error Handling
Every API call should handle: network errors (no internet), server errors (5xx), auth errors (401 → token refresh), and validation errors (422).

### 5. Hardcoded Strings
Never hardcode strings in widgets — use the `AppConfig` class or a constants file.

### 6. Ignoring the Theme
Never use raw `Color()` or fixed `EdgeInsets` — use `Theme.of(context)` and `ThemeData` properties.

### 7. Routes in Widgets
Never use `Navigator.push` directly — use `context.go()` or `context.push()` from GoRouter.

### 8. Firebase Config in Code
Never commit `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` — they are in `.gitignore`.

### 9. API Keys in Source
Google Maps and Firebase API keys are passed as `--dart-define` at build time, never hardcoded.

### 10. Database Migrations
Always create new `.sql` migration files rather than modifying existing ones. Migrations run in alphabetical order.

---

## Docker Notes

- `docker-compose.yml` orchestrates PostgreSQL + backend + admin
- Flutter app cannot be Dockerized for mobile — it runs natively on devices
- Production secrets go in `.env` (not in `docker-compose.yml`)
- Backend Dockerfile uses `node:18-alpine` for minimal image size

---

## Git Commit Convention

Use conventional commits:
```
feat: add route planner with waypoints
fix: correct distance calculation in nearby search
chore: update dependencies
docs: add API documentation
refactor: extract station card widget
test: add auth provider unit tests
```
