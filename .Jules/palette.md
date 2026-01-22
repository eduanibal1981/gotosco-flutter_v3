## 2024-05-23 - Helper Widget Props
**Learning:** Custom helper widgets for inputs (like `_buildTextField`) often unintentionally swallow accessibility and usability props (autofill, input actions), blocking standard mobile behaviors.
**Action:** Always verify that custom input wrappers expose `autofillHints`, `textInputAction`, and `onSubmitted` callbacks.
