## 2024-05-23 - Helper Widget Props
**Learning:** Custom helper widgets for inputs (like `_buildTextField`) often unintentionally swallow accessibility and usability props (autofill, input actions), blocking standard mobile behaviors.
**Action:** Always verify that custom input wrappers expose `autofillHints`, `textInputAction`, and `onSubmitted` callbacks.

## 2025-05-24 - Form Validation UX
**Learning:** Using `SnackBar` for form validation disrupts user flow and fails accessibility standards. Inline validation (via `TextFormField.validator`) provides persistent, context-aware feedback.
**Action:** Refactor custom input widgets to accept a `validator` function and wrap input groups in a `Form` widget.
