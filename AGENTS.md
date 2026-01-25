# AGENTS.md - Gotosco v3 (School Transport Management)

## Commands
- **Get dependencies:** `flutter pub get`
- **Build/analyze:** `flutter analyze`
- **Run tests:** `flutter test`
- **Run single test:** `flutter test test/<filename>.dart`
- **Code generation:** `dart run build_runner build --delete-conflicting-outputs`
- **Run app:** `flutter run`

## Architecture
- **Feature-first structure:** `lib/features/{auth,driver,parent,shared}/` with `data/` and `presentation/` layers
- **Core module:** `lib/core/` contains constants, models, providers, router, services, theme, utils, widgets
- **Backend:** Supabase (PostgreSQL + Auth + Realtime + Storage) - use MCP tools for live schema inspection
- **State management:** Riverpod with `@riverpod` annotations and code generation
- **Navigation:** GoRouter in `lib/core/router/`
- **Models:** Use Freezed + json_serializable for immutable data classes

## Code Style
- **Dart 3+ with strict null safety** - no implicit casts
- **Use generated Riverpod providers** - always use `@riverpod` annotation, never manual providers
- **AsyncValue.guard()** for async state management in controllers
- **Repository pattern** for data layer - abstract interface + implementation
- **Widgets:** ConsumerWidget/ConsumerStatefulWidget for Riverpod access
- **Imports:** Relative within feature, absolute (`package:gotosco_v3/`) for cross-feature
- **Formatting:** 80-char line limit, `flutter format .` or editor format-on-save
