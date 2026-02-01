# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Gotosco v3** is a Flutter mobile/web application for school transport management, connecting parents with drivers for children's transportation.

**Supabase Project ID:** `ixjkvasziamjkeupqvfc`

## Development Commands

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed, JSON serialization) - REQUIRED after model changes
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run single test file
flutter test test/<path_to_test>.dart
```

## Architecture

### Feature-First Structure
```
lib/
├── core/                    # Shared infrastructure (theme, router, utils, services)
└── features/
    └── <feature_name>/
        ├── data/            # Repositories, models (Supabase API calls)
        ├── domain/          # Business logic entities, repository contracts (pure Dart)
        └── presentation/    # UI screens, controllers (AsyncNotifier)
```

### Data Flow (Strict)
**UI → Controller → Repository → Supabase**

- UI never calls Supabase directly
- Business logic lives in `AsyncNotifier` controllers, not widgets
- Widgets only display data using `ref.watch()`

### Key Entry Points
- **App Entry:** `lib/main.dart`
- **Router:** `lib/core/router/router.dart` (GoRouter with auth redirects)
- **User Session:** `lib/core/providers/user_session_provider.dart`
- **Theme:** `lib/core/theme/app_theme.dart`

## Code Patterns

### State Management (Riverpod with Code Generation)
```dart
// Provider - use @riverpod annotation (MANDATORY)
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(Supabase.instance.client);
}

// Controller with AsyncNotifier
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signIn(email, password);
    });
  }
}
```

### Data Models (Freezed - MANDATORY)
```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

### UI Widgets
- Use `ConsumerWidget` or `ConsumerStatefulWidget`
- Use `AsyncValue.when()` pattern for loading/error/data states
- Use `ref.watch().select()` to minimize rebuilds

## Critical Rules

1. **Database Schema:** Respect `supabase/migrations` strictly - never invent column names
2. **No Legacy Providers:** Use `@riverpod` annotations only (no `StateNotifierProvider`, `ChangeNotifier`)
3. **Null Safety:** Strict Dart 3 rules - avoid `!` operators unless absolutely safe
4. **Error Handling:** Wrap repository calls in `try/catch`, throw domain-specific exceptions
5. **File Size:** Keep files under 300 lines - split large widgets
6. **UI Styling:** Use `AppTheme` constants - avoid hardcoded colors/sizes

## Database

### Core Tables
- `users` - User profiles (parent/driver roles)
- `drivers` - Driver-specific data (pricing, vehicle, ratings, is_online, is_available)
- `students` - Children managed by parents
- `schools` - School information with location
- `bookings` - Transportation bookings
- `trips` / `daily_trips` - Daily trip instances
- `trip_stops` - Individual pickup/dropoff points
- `driver_locations` - Real-time location tracking (PostGIS)
- `messages` - Chat messages
- `driver_service_areas` / `driver_covered_schools` - Coverage areas

### Supabase Edge Functions
- `supabase/functions/send-notification/` - FCM push notifications

## Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Files | `snake_case.dart` | `auth_repository.dart` |
| Classes | `PascalCase` | `AuthRepository` |
| Variables/Functions | `camelCase` | `getCurrentUser()` |
| Private members | Prefix `_` | `_privateMethod()` |

## Git Commits (Conventional)
```
feat(auth): add biometric login
fix(booking): resolve duplicate booking bug
refactor(driver): optimize route calculation
```

## Key Features

- **Dual Roles:** Users can be both parent and driver
- **6-Step Booking Flow:** `lib/features/booking_flow/` (see README.md there)
- **Live Tracking:** Real-time driver location with flutter_map
- **Smart Availability:** Automatic online/offline based on scheduled trips
- **Multi-School Support:** Drivers can cover multiple schools
