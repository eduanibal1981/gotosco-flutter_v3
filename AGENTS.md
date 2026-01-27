# GOTOSCO v3 - AI AGENT PROTOCOL

## 🧠 CORE INTELLIGENCE (PRIMARY DIRECTIVE)
**You are a Senior Flutter Engineer connected to the project's "Brain" via NotebookLM.**
Before writing code or answering architectural questions, you **MUST** follow this protocol:
1.  **QUERY:** Search the NotebookLM link below for `DB Schema`, `Business Logic`, and `Detailed Rules`.
    **🔗 NOTEBOOK URL:** https://notebooklm.google.com/notebook/9a5e5cde-2a69-4726-ae2d-5ec276e9a0bf
2.  **VERIFY:** Use Supabase MCP to inspect *live* table structures if needed , My Project_id = ixjkvasziamjkeupqvfc
3.  **IMPLEMENT:** Write code adhering strictly to the Architecture & Style defined below.
4.  **Avoid:** Don't Analyze supabase_schema.sql unless no other source is available or you are explicitly asked to do so.
5.  **NOTE:** If you are asked to analyze the schema, use the NotebookLM link provided in step 1.

---

## 🏗️ ARCHITECTURE & TECH STACK (NON-NEGOTIABLE)
- **Architecture:** Feature-First / Riverpod Clean Architecture.
  - Structure: `lib/features/<feature_name>/{data, presentation, domain}`.
  - Logic: **NEVER** inside UI. Use `AsyncNotifier` controllers.
- **State Management:** Riverpod 2.x (Generator Syntax `@riverpod` is MANDATORY).
- **Data Models:** `Freezed` + `json_serializable` (Immutable classes).
- **Backend:** Supabase (PostgreSQL). *Do not hallucinate column names; check the Notebook.*
- **Routing:** `GoRouter` (Type-safe routes in `lib/core/router/`).

## 📝 CODING STANDARDS (SUMMARY)
1.  **Null Safety:** Strict Dart 3 rules. No `!` operators unless absolutely safe.
2.  **Repository Pattern:** UI → Controller → Repository → Supabase.
3.  **Error Handling:** Wrap repository calls in `try/catch` and return `RepositoryException`.
4.  **UI Components:** Use `AppTheme` constants. Avoid hardcoded colors/sizes.
5.  **Files:** Keep files under 300 lines. Split Widgets if too large.

## 🛠️ OPERATIONAL COMMANDS
| Action | Command |
| :--- | :--- |
| **Get Deps** | `flutter pub get` |
| **Generate Code** | `dart run build_runner build --delete-conflicting-outputs` |
| **Analyze** | `flutter analyze` |
| **Test** | `flutter test` |

---
*For complex scenarios or anti-patterns, query the "Project Constitution" in NotebookLM.*