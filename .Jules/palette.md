## 2024-05-23 - Helper Widget Props
**Learning:** Custom helper widgets for inputs (like `_buildTextField`) often unintentionally swallow accessibility and usability props (autofill, input actions), blocking standard mobile behaviors.
**Action:** Always verify that custom input wrappers expose `autofillHints`, `textInputAction`, and `onSubmitted` callbacks.

## 2024-05-23 - Interactive Card Feedback
**Learning:** Wrapping a decorated Container with InkWell hides the ripple effect because the Container's background paint covers the Material ink layer.
**Action:** Use the `Material(color: ..., child: InkWell(child: Container(...)))` pattern for interactive cards with background colors.
