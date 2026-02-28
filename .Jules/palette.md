## 2024-05-23 - Helper Widget Props
**Learning:** Custom helper widgets for inputs (like `_buildTextField`) often unintentionally swallow accessibility and usability props (autofill, input actions), blocking standard mobile behaviors.
**Action:** Always verify that custom input wrappers expose `autofillHints`, `textInputAction`, and `onSubmitted` callbacks.

## 2024-05-24 - InkWell Visibility Over Opaque Containers
**Learning:** Wrapping `Container` with `InkWell` when the container has a `color` set hides the ripple effect, as the splash is painted on the underlying Material.
**Action:** Use `Material(color: ..., child: InkWell(child: Container(...)))` to ensure touch feedback is visible.

## 2024-05-25 - Form Mode Switching Keys
**Learning:** When toggling between related forms (e.g., Login vs. Signup) within the same widget tree, Flutter may reuse Elements/state incorrectly if fields are similar.
**Action:** Assign `ValueKey`s to `TextFormField`s (even inside helper methods) to ensure correct state preservation and prevent validation error leakage across mode switches.
