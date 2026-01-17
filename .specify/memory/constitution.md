# Project Constitution

**Version:** 1.0  
**Last Updated:** January 11, 2026  
**Project:** Gotosco (v3) - School Transport Management System

---

## Purpose

This document establishes the **non-negotiable technical standards and architectural patterns** for the Gotosco (v3) project. All code—whether human-written or AI-generated—must strictly adhere to these rules to ensure consistency, maintainability, and scalability.

---

## 1. Technology Stack

### Core Technologies
- **Framework:** Flutter (Latest Stable Channel)
- **Language:** Dart 3+ with strict typing and null safety enforced
- **State Management:** Riverpod 2.x with `riverpod_generator` and `riverpod_annotation`
- **Backend/Database:** Supabase (PostgreSQL + Auth + Realtime + Storage)
- **Navigation:** GoRouter (Latest stable version)
- **Code Generation:** `build_runner` for Riverpod, Freezed, and JSON Serialization

### Required Packages
```yaml
# State Management
flutter_riverpod: ^2.x
riverpod_annotation: ^2.x
riverpod_generator: ^2.x

# Code Generation
freezed: ^2.x
freezed_annotation: ^2.x
json_annotation: ^4.x
json_serializable: ^6.x
build_runner: ^2.x

# Backend
supabase_flutter: ^2.x

# Routing
go_router: ^14.x
```

### Recommended Additional Packages
- **UI/UX:** `flutter_svg`, `cached_network_image`, `shimmer`
- **Maps:** `google_maps_flutter`, `geolocator`, `geocoding`
- **Utilities:** `intl`, `url_launcher`, `image_picker`
- **Error Handling:** `dartz` (for functional error handling)

---

## 2. Architectural Pattern

### Feature-First Architecture

The project follows a **strict feature-first organization** where each business domain is isolated into its own feature module.

#### Root Structure
```lib/
├── main.dart
├── firebase_options.dart
├── core/                              # Shared infrastructure
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── enums.dart
│   ├── models/
│   │   ├── user_model.dart
│   │   └── user_session.dart
│   ├── providers/
│   │   └── user_session_provider.dart
│   ├── router/
│   │   └── router.dart
│   ├── services/
│   │   ├── notification_service.dart
│   │   └── supabase_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── formatters.dart
│   └── widgets/                       # Core reusable widgets
│       ├── app_button.dart
│       ├── custom_textfield.dart
│       ├── empty_state_widget.dart
│       ├── map_picker_screen.dart
│       └── role_switcher_button.dart
│
└── features/                          # Business logic by domain
    ├── auth/
    │   ├── data/
    │   │   └── auth_repository.dart
    │   └── presentation/
    │       ├── auth_controller.dart
    │       ├── login_screen.dart
    │       ├── role_selection_screen.dart
    │       ├── splash_screen.dart
    │       └── user_provider.dart
    │
    ├── driver/
    │   ├── availability/
    │   │   ├── data/
    │   │   │   ├── driver_availability_model.dart
    │   │   │   └── driver_availability_repository.dart
    │   │   └── presentation/
    │   │       ├── availability_control_sheet.dart
    │   │       └── driver_availability_controller.dart
    │   ├── bookings/
    │   │   ├── data/
    │   │   │   ├── booking_model.dart
    │   │   │   └── driver_bookings_repository.dart
    │   │   └── presentation/
    │   │       ├── driver_bookings_screen.dart
    │   │       └── widgets/
    │   ├── dashboard/
    │   │   ├── data/
    │   │   │   └── driver_dashboard_repository.dart
    │   │   └── presentation/
    │   │       ├── driver_dashboard_screen.dart
    │   │       ├── controllers/
    │   │       ├── screens/
    │   │       ├── tabs/
    │   │       └── widgets/
    │   ├── earnings/
    │   │   └── presentation/
    │   │       └── earnings_tab.dart
    │   ├── messages/
    │   │   ├── data/
    │   │   │   └── driver_messages_repository.dart
    │   │   └── presentation/
    │   │       └── driver_messages_screen.dart
    │   ├── profile/
    │   │   ├── data/
    │   │   │   ├── driver_profile_model.dart
    │   │   │   ├── driver_profile_repository.dart
    │   │   │   └── driver_schedule_model.dart
    │   │   └── presentation/
    │   │       └── driver_profile_tab.dart
    │   ├── requests/
    │   │   └── presentation/
    │   │       └── requests_tab.dart
    │   └── students/
    │       └── presentation/
    │           └── students_tab.dart
    │
    ├── parent/
    │   ├── bookings/
    │   │   ├── data/
    │   │   │   └── bookings_repository.dart
    │   │   └── presentation/
    │   │       ├── booking_screen.dart
    │   │       ├── bookings_controller.dart
    │   │       ├── my_bookings_tab.dart
    │   │       └── widgets/
    │   ├── children/
    │   │   ├── data/
    │   │   │   ├── attendance_model.dart
    │   │   │   ├── child_model.dart
    │   │   │   └── children_repository.dart
    │   │   └── presentation/
    │   │       ├── add_child_screen.dart
    │   │       ├── attendance_history_screen.dart
    │   │       ├── children_controller.dart
    │   │       ├── children_tab.dart
    │   │       ├── edit_child_screen.dart
    │   │       └── set_absence_screen.dart
    │   ├── dashboard/
    │   │   └── presentation/
    │   │       ├── dashboard_controller.dart
    │   │       ├── parent_dashboard_screen.dart
    │   │       ├── tabs/
    │   │       └── widgets/
    │   ├── find_driver/
    │   │   ├── data/
    │   │   │   ├── driver_ad_model.dart
    │   │   │   ├── drivers_repository.dart
    │   │   │   └── location_repository.dart
    │   │   └── presentation/
    │   │       ├── driver_detail_screen.dart
    │   │       ├── drivers_controller.dart
    │   │       ├── filter_drivers_screen.dart
    │   │       ├── find_drivers_screen.dart
    │   │       ├── providers/
    │   │       └── widgets/
    │   ├── messages/
    │   │   ├── data/
    │   │   │   └── parent_messages_repository.dart
    │   │   └── presentation/
    │   │       └── parent_messages_screen.dart
    │   ├── profile/
    │   │   └── presentation/
    │   │       └── profile_tab.dart
    │   └── tracking/
    │       ├── data/
    │       │   ├── driver_location_model.dart
    │       │   └── tracking_repository.dart
    │       └── presentation/
    │           ├── live_tracking_screen.dart
    │           ├── tracking_controller.dart
    │           └── widgets/
    │
    └── shared/
        └── chat/
            ├── data/
            │   ├── chat_repository.dart
            │   └── message_model.dart
            └── presentation/
                └── chat_screen.dart

### Layer Responsibilities

| Layer | Responsibilities | Dependencies |
|-------|-----------------|--------------|
| **Data** | API calls, database queries, data transformation | Supabase, JSON serialization |
| **Domain** | Business logic, entities, repository contracts | None (pure Dart) |
| **Presentation** | UI, user interactions, state management | Domain + Riverpod |

**Rule:** Dependencies flow **inward only** (Presentation → Domain ← Data)

---

## 3. State Management Rules (Riverpod)

### Provider Generation (Mandatory)
✅ **USE THIS:**
```dart
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
}

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

❌ **AVOID THIS:**
```dart
final currentUserProvider = FutureProvider<User>((ref) async { ... });
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>(...);
```

### Async Data Handling
Always use `AsyncValue` pattern for async operations:

```dart
// In UI
Consumer(
  builder: (context, ref, child) {
    final userAsync = ref.watch(currentUserProvider);
    
    return userAsync.when(
      data: (user) => Text('Hello ${user.name}'),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  },
)
```

### Controller Placement
- **Business Logic:** Must reside in `AsyncNotifier`/`Notifier` classes in `presentation/controllers/`
- **UI Logic:** Widget-level state can use local `useState` (flutter_hooks) or `StatefulWidget`

### Forbidden Patterns
❌ Do NOT use:
- `ChangeNotifier` or `ChangeNotifierProvider`
- `StateProvider` for complex state
- Business logic inside `build()` methods
- Direct Supabase calls in UI widgets

---

## 4. Coding Standards

### Data Models

#### Use Freezed for Immutability
```dart
@freezed
class Student with _$Student {
  const factory Student({
    required String id,
    required String fullName,
    required int age,
    String? photoUrl,
  }) = _Student;
  
  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}
```

**Rule:** All data models in `data/models/` must use Freezed. Domain entities can be plain Dart classes.

### UI Components

#### Widget Best Practices
```dart
// ✅ Good: ConsumerWidget with const constructor
class StudentCard extends ConsumerWidget {
  const StudentCard({super.key, required this.studentId});
  
  final String studentId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentProvider(studentId));
    return Card(child: Text(student.fullName));
  }
}

// ❌ Bad: StatefulWidget with Riverpod
class StudentCard extends StatefulWidget { ... }
```

#### Performance Rules
- Use `const` constructors wherever possible
- Avoid rebuilds: use `select()` to watch specific fields
  ```dart
  final userName = ref.watch(userProvider.select((user) => user.name));
  ```
- Extract heavy widgets into separate classes

### Supabase Integration

#### Repository Pattern (Mandatory)
```dart
// ✅ Good: Repository in data layer
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(supabase: Supabase.instance.client);
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabase;
  
  Future<User> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return User.fromJson(response.user!.toJson());
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    }
  }
}

// ❌ Bad: Direct Supabase call in UI
ElevatedButton(
  onPressed: () {
    Supabase.instance.client.auth.signInWithPassword(...); // FORBIDDEN
  },
)
```

#### Error Handling
- Catch Supabase exceptions (`AuthException`, `PostgrestException`)
- Transform into domain-specific failures
- Return user-friendly error messages

```dart
try {
  await supabase.from('bookings').insert(data);
} on PostgrestException catch (e) {
  if (e.code == '23505') {
    throw BookingFailure('Booking already exists');
  }
  throw BookingFailure('Failed to create booking: ${e.message}');
}
```

---

## 5. File & Naming Conventions

### File Naming
| Type | Convention | Example |
|------|------------|---------|
| Dart files | `snake_case.dart` | `auth_repository.dart` |
| Classes | `PascalCase` | `AuthRepository` |
| Variables/Functions | `camelCase` | `getCurrentUser()` |
| Constants | `lowerCamelCase` or `SCREAMING_SNAKE_CASE` | `kPrimaryColor` or `API_TIMEOUT` |
| Private members | Prefix `_` | `_privateMethod()` |

### Import Organization
```dart
// 1. Dart imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetical)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Relative imports (same feature)
import '../../data/repositories/auth_repository.dart';
import '../widgets/login_form.dart';

// 5. Absolute imports (core/other features)
import 'package:gotosco_v3/core/theme/app_colors.dart';
```

**Rule:** Within a feature, use relative imports. For `core/` or cross-feature access, use absolute imports.

---

## 6. Forbidden Practices

### 🚫 Security Violations
- ❌ Hardcoded API keys, secrets, or credentials
- ❌ Storing sensitive data in plain text (use Flutter Secure Storage)
- ❌ Exposing Supabase anon key in public repositories (use `.env` files)

### 🚫 State Management Anti-Patterns
- ❌ Using `setState()` for complex business logic
- ❌ Mixing business logic in `build()` methods
- ❌ Creating stateful widgets when Riverpod suffices
- ❌ Using global variables for state

### 🚫 Architecture Violations
- ❌ Importing presentation layer into data layer
- ❌ UI widgets directly calling Supabase
- ❌ Business logic in widgets
- ❌ Circular dependencies between features

### 🚫 Code Quality Issues
- ❌ Magic numbers/strings (use constants)
- ❌ Nested ternary operators (max depth: 1)
- ❌ Functions longer than 50 lines (refactor into smaller functions)
- ❌ Ignoring linter warnings without justification

---

## 7. Testing Requirements

### Mandatory Test Coverage
| Layer | Minimum Coverage | Test Type |
|-------|-----------------|-----------|
| Data Repositories | 80% | Unit Tests |
| Domain Logic | 90% | Unit Tests |
| Controllers | 75% | Unit + Widget Tests |
| UI Screens | 60% | Widget + Integration Tests |

### Test Organization
```
test/
├── features/
│   └── auth/
│       ├── data/
│       │   └── repositories/
│       │       └── auth_repository_test.dart
│       ├── domain/
│       └── presentation/
│           └── controllers/
│               └── auth_controller_test.dart
└── core/
```

### Testing Tools
- `flutter_test` for unit/widget tests
- `mocktail` for mocking
- `integration_test` for E2E tests

---

## 8. Git Workflow & Branch Strategy

### Branch Naming
```
main              # Production-ready code
develop           # Integration branch
feature/AUTH-123  # Feature branches (with ticket ID)
bugfix/TRIP-456   # Bug fixes
hotfix/PAYMENT    # Emergency production fixes
```

### Commit Messages (Conventional Commits)
```
feat(auth): add biometric login
fix(booking): resolve duplicate booking bug
refactor(driver): optimize route calculation
docs(constitution): update coding standards
test(trips): add unit tests for trip repository
```

### Pull Request Checklist
- [ ] Code follows constitution guidelines
- [ ] All tests pass (`flutter test`)
- [ ] No linter errors (`flutter analyze`)
- [ ] Code formatted (`dart format .`)
- [ ] Build succeeds (`flutter build apk --debug`)
- [ ] Screenshots attached (for UI changes)

---

## 9. Performance & Optimization Guidelines

### Image Optimization
- Use `cached_network_image` for remote images
- Compress images before upload (max 500KB)
- Use appropriate image formats (WebP > PNG > JPEG)

### Database Optimization
- Index frequently queried columns in Supabase
- Use pagination for large lists (`range()` in Supabase)
- Implement debouncing for search queries

### Build Size
- Enable code splitting (`--split-debug-info`)
- Remove unused packages (`flutter pub deps --no-dev`)
- Obfuscate release builds (`--obfuscate`)

---

## 10. Documentation Requirements

### Code Documentation
- All public APIs must have dartdoc comments
- Complex algorithms require inline comments
- Repository methods must document error cases

```dart
/// Signs in a user with email and password.
///
/// Throws [AuthFailure] if credentials are invalid or network fails.
/// Returns authenticated [User] on success.
Future<User> signIn(String email, String password);
```

### Feature Documentation
Each feature must have a `README.md`:
```markdown
# Auth Feature
+
## Overview
Handles user authentication using Supabase Auth.

## Dependencies
- `supabase_flutter`
- `flutter_secure_storage`

## Key Files
- `data/repositories/auth_repository.dart` - Authentication logic
- `presentation/screens/login_screen.dart` - Login UI
```

---

## 11. Recommended Optimizations

### 🔧 Consider Adding These (Optional but Beneficial)

1. **Dependency Injection Container**
   - Use `riverpod` as DI container (already included)
   - Alternative: `get_it` for service locator pattern

2. **Error Tracking**
   - Integrate Sentry or Firebase Crashlytics
   - Log errors in production builds

3. **Analytics**
   - Firebase Analytics or Mixpanel
   - Track critical user journeys

4. **Localization**
   - Add `flutter_localizations` and `intl`
   - Prepare for multi-language support

5. **CI/CD Pipeline**
   - GitHub Actions or Codemagic
   - Automated testing and deployment

6. **API Response Caching**
   - Use Riverpod's caching capabilities
   - Implement offline-first with `drift` or `hive`

7. **Real-time Updates**
   - Leverage Supabase Realtime subscriptions
   - Update UI automatically on database changes

---

## 12. Enforcement & Violations

### Code Review Process
- **2 approvals required** before merging to `develop`
- Constitution violations = **automatic rejection**
- Reviewers must verify adherence using this checklist

### Constitution Violation Severity

| Severity | Examples | Action |
|----------|----------|--------|
| **Critical** | Hardcoded secrets, Supabase in UI | Immediate rejection |
| **High** | Wrong architecture layer, missing tests | Request changes |
| **Medium** | Poor naming, missing docs | Request improvements |
| **Low** | Minor style issues | Optional fix |

---

## 13. Maintenance & Updates

### Review Schedule
- **Quarterly:** Review and update technology versions
- **Bi-annually:** Evaluate architectural patterns
- **Annually:** Major constitution revision

### Change Request Process
1. Propose change in team discussion
2. Document rationale and impact
3. Update constitution version
4. Communicate to all team members

---

## Appendix A: Quick Reference Checklist

**Before submitting code, verify:**
- [ ] Feature follows folder structure (`data/`, `domain/`, `presentation/`)
- [ ] Used `@riverpod` annotations (no legacy providers)
- [ ] Models use Freezed for immutability
- [ ] No Supabase calls in UI layer
- [ ] No hardcoded strings or secrets
- [ ] ConsumerWidget/ConsumerStatefulWidget for Riverpod
- [ ] File names are `snake_case`
- [ ] Imports properly organized
- [ ] Code formatted and analyzed
- [ ] Tests added/updated

---

## Appendix B: Database Schema Reference

### Core Tables for School Transport System

Based on best practices from global school transport services, the following tables are required:

#### Students Table
```sql
CREATE TABLE public.students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  age INTEGER NOT NULL,
  grade TEXT,
  school_id UUID REFERENCES schools(id),
  special_needs TEXT,
  emergency_contact TEXT,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Schools Table
```sql
CREATE TABLE public.schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  contact_phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Enhanced Bookings Table
```sql
ALTER TABLE public.bookings
  ADD COLUMN student_id UUID REFERENCES students(id) ON DELETE CASCADE,
  ADD COLUMN school_id UUID REFERENCES schools(id),
  ADD COLUMN start_date DATE NOT NULL,
  ADD COLUMN end_date DATE,
  ADD COLUMN recurring_days TEXT[],
  ADD COLUMN is_monthly_subscription BOOLEAN DEFAULT FALSE,
  ADD COLUMN subscription_start_date DATE,
  ADD COLUMN subscription_end_date DATE,
  ADD COLUMN payment_status TEXT DEFAULT 'unpaid' 
    CHECK (payment_status IN ('unpaid', 'paid', 'pending')),
  ADD COLUMN cancellation_reason TEXT,
  ADD COLUMN cancelled_at TIMESTAMPTZ;
```

#### Daily Trips Table
```sql
CREATE TABLE public.daily_trips (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES drivers(user_id) ON DELETE CASCADE,
  trip_date DATE NOT NULL,
  trip_type TEXT NOT NULL CHECK (trip_type IN ('morning_pickup', 'afternoon_dropoff')),
  status TEXT DEFAULT 'scheduled' 
    CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
  planned_start_time TIMESTAMPTZ,
  actual_start_time TIMESTAMPTZ,
  actual_end_time TIMESTAMPTZ,
  route_optimization JSONB,
  total_distance_km NUMERIC,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(driver_id, trip_date, trip_type)
);
```

#### Trip Stops Table
```sql
CREATE TABLE public.trip_stops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_trip_id UUID NOT NULL REFERENCES daily_trips(id) ON DELETE CASCADE,
  booking_id UUID NOT NULL REFERENCES bookings(id),
  student_id UUID NOT NULL REFERENCES students(id),
  stop_type TEXT NOT NULL CHECK (stop_type IN ('pickup', 'dropoff')),
  location_type TEXT NOT NULL CHECK (location_type IN ('home', 'school')),
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  address TEXT NOT NULL,
  sequence_order INTEGER NOT NULL,
  scheduled_time TIMESTAMPTZ,
  actual_arrival_time TIMESTAMPTZ,
  actual_departure_time TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' 
    CHECK (status IN ('pending', 'arrived', 'completed', 'skipped')),
  parent_notified BOOLEAN DEFAULT FALSE,
  notes TEXT,
  UNIQUE(daily_trip_id, sequence_order)
);
```

#### Trip Tracking Table
```sql
CREATE TABLE public.trip_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  daily_trip_id UUID NOT NULL REFERENCES daily_trips(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  heading DOUBLE PRECISION,
  speed DOUBLE PRECISION,
  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  battery_level INTEGER,
  network_type TEXT
);

CREATE INDEX idx_trip_tracking_trip_date 
  ON trip_tracking(daily_trip_id, recorded_at DESC);
```

#### Enhanced Driver Locations
```sql
ALTER TABLE public.driver_locations
  ADD COLUMN next_stop_id UUID REFERENCES trip_stops(id),
  ADD COLUMN eta_minutes INTEGER,
  ADD COLUMN students_onboard INTEGER DEFAULT 0;
```

---

## Appendix C: Feature Implementation Priority

### Phase 1: Core Infrastructure (Weeks 1-2)
1. Authentication (login, registration, role selection)
2. User profiles (driver, parent)
3. Basic navigation with GoRouter

### Phase 2: Essential Features (Weeks 3-5)
1. Driver registration & verification
2. Student management (parents)
3. School database
4. Booking system (create, view, status)

### Phase 3: Trip Management (Weeks 6-8)
1. Daily trip generation
2. Route optimization algorithm
3. Real-time location tracking
4. Trip stops management

### Phase 4: Advanced Features (Weeks 9-12)
1. Parent notifications (push, SMS)
2. Payment integration
3. Rating & review system
4. Analytics dashboard

### Phase 5: Polish & Launch (Weeks 13-14)
1. Performance optimization
2. E2E testing
3. Bug fixes
4. App store submission

---

## Appendix D: Environment Setup

### Required Tools
```bash
# Flutter SDK
flutter --version  # Should be 3.19+ or latest stable

# Dart SDK (included with Flutter)
dart --version  # Should be 3.3+ or latest

# Code generation
dart pub global activate build_runner
dart pub global activate freezed
```

### IDE Configuration

#### VS Code Extensions
```json
{
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter",
    "usernamehw.errorlens",
    "pflannery.vscode-versionlens",
    "robert-brunhage.flutter-riverpod-snippets"
  ]
}
```

#### VS Code Settings
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

### Supabase Local Development
```bash
# Install Supabase CLI
npm install -g supabase

# Initialize project
supabase init

# Start local Supabase
supabase start

# Apply migrations
supabase db reset
```

---

## Appendix E: Common Code Snippets

### Riverpod Provider Template
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feature_provider.g.dart';

@riverpod
class FeatureController extends _$FeatureController {
  @override
  FutureOr<FeatureState> build() async {
    // Initialize state
    return const FeatureState.initial();
  }

  Future<void> performAction() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Business logic here
      final result = await ref.read(repositoryProvider).doSomething();
      return FeatureState.success(result);
    });
  }
}
```

### Repository Template
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FeatureRepository {
  Future<List<Entity>> getAll();
  Future<Entity> getById(String id);
  Future<void> create(Entity entity);
  Future<void> update(Entity entity);
  Future<void> delete(String id);
}

class FeatureRepositoryImpl implements FeatureRepository {
  final SupabaseClient _supabase;
  
  FeatureRepositoryImpl({required SupabaseClient supabase}) 
      : _supabase = supabase;

  @override
  Future<List<Entity>> getAll() async {
    try {
      final response = await _supabase
          .from('table_name')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Entity.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException('Failed to fetch: ${e.message}');
    }
  }
}
```

### Screen Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeatureScreen extends ConsumerWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature')),
      body: state.when(
        data: (data) => _buildContent(data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildContent(FeatureState state) {
    return ListView(
      children: [
        // Your UI here
      ],
    );
  }
}
```

---

**Document Owner:** Lead Architect  
**Approved By:** Technical Team  
**Next Review:** April 2026

---

*This constitution is a living document and will evolve with project needs. All contributors must familiarize themselves with these standards before contributing code.*
