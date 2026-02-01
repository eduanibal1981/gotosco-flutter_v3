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

---

## 🤖 JULES HANDOVER PROTOCOL (AGENT-TO-AGENT)

**Trigger Phrase:** "Handover to Jules" or "Give this to Jules"

When the user invokes this trigger, you act as the **Technical Architect** and **Context Manager**. You must **NOT** implement the code yourself. Instead, you prepare the work for Jules (The Builder).

### EXECUTION STEPS:
1.  **GATHER CONTEXT (NotebookLM):**
    *   Query NotebookLM for architectural patterns, rules, and existing business logic relevant to the requested task.
    *   *Goal:* Ensure Jules follows the project's "Constitution" effectively.

2.  **VERIFY SCHEMA (Supabase MCP):**
    *   Use `supabase-mcp` to verify database tables/columns exist or identify what needs modification.
    *   *Goal:* Prevent hallucinated database references.

3.  **DRAFT THE SPEC (The "Brain"):**
    *   Create a concise but highly technical summary (The Spec).
    *   *Include:* Files to modify, Schema changes, Logic flows, and "Gotchas".

4.  **GENERATE JULES COMMAND:**
    *   Construct the precise CLI command for the user to run.
    *   **Format:**
        ```bash
        jules remote new \
          --repo <repo_name> \
          --session "TASK: <User_Task_Name> | CONTEXT: <The_Spec_You_Drafted>"
        ```
    *   *Note:* Ensure the "Context" string is escaped properly if it contains complex characters, or suggest passing it via a temporary file if it's too long.