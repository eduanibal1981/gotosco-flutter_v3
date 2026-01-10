# Project Constitution

This document defines the non-negotiable technical standards and architectural patterns for the **Gotosco (v3)** project. All AI-generated code must strictly adhere to these rules.

## 1. Technology Stack
- **Framework:** Flutter (Latest Stable).
- **Language:** Dart 3+ (Enforce strict typing and null safety).
- **State Management:** Riverpod (Use `riverpod_generator` syntax with annotations `@riverpod` whenever possible).
- **Backend/Database:** Supabase (PostgreSQL).
- **Routing:** GoRouter (Defined in `lib/core/router/`).
- **Code Generation:** Use `build_runner` for Riverpod, Freezed, and JSON Serialization.

## 2. Architectural Pattern
- **Feature-First Architecture:** The project is organized by features in `lib/features/`.
- **Folder Structure per Feature:**
  Each feature (e.g., `auth`, `driver`, `parent`) must follow this structure:
  ```text
  lib/features/feature_name/
  ├── data/           # Repositories & Data Sources (Supabase calls)
  ├── domain/         # Data Models (Plain Dart classes or Freezed)
  ├── presentation/   # Widgets, Screens & Controllers (Riverpod Notifiers)
  Core Folder: Shared logic, themes, and utilities reside in lib/core/.

3. State Management Rules (Riverpod)
Providers: Prefer using @riverpod annotation to generate providers.

Async Data: Handle loading/error states using AsyncValue pattern (.when or .whenData) in the UI.

Controllers: Business logic must reside in AsyncNotifier or Notifier classes (Presentation Layer), not in UI widgets.

Avoid Legacy: Do NOT use ChangeNotifier or StateProvider unless absolutely necessary.

4. Coding Standards
Immutability: Data models should be immutable. Use final fields.

UI Components:

Use ConsumerWidget or ConsumerStatefulWidget to read providers.

Prefer const constructors for widgets to optimize performance.

Avoid hardcoded strings; use constants or localization if available.

Supabase Integration:

Database logic must remain in the Data Layer (Repositories).

Do not call Supabase.instance.client directly inside UI Widgets.

Handle Supabase exceptions gracefully and return user-friendly errors.

5. File & Naming Conventions
Filenames: Use snake_case (e.g., auth_repository.dart).

Class Names: Use PascalCase (e.g., AuthRepository).

Imports: Prefer relative imports (e.g., ../../data/model.dart) within the same feature, and absolute imports (e.g., package:gotosco_v3/core/...) for core utilities.

6. Forbidden Practices
Do not put hardcoded API keys in the code.

Do not use setState for complex state management (leave that to Riverpod).

Do not mix business logic inside the build() method of widgets.