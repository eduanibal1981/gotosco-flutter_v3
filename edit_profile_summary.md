# Edit Child & Profile Enhancements

## Overview
Extended the City Selection and School Management features to the "Edit Child" screen and the "Child Profile" card.

## Changes Implemented

### 1. Edit Child Screen (`EditChildScreen`)
- **Refactored UI**: Replaced the simple School Name text field with the context-aware `SchoolSelectionField`.
- **City Selection**: Added a City Dropdown to filter schools, similar to the Add Child screen.
- **Pre-filling Logic**:
  - Fetches the child's school details using `schoolId`.
  - Automatically selects the city associated with the school.
  - Automatically presets the school in the selection field.
- **Update Logic**: Now persists the `schoolId` (linking to the `schools` table) instead of just the name.

### 2. Child Profile Display (`ChildrenTab`)
- **Data Model Update**: Updated `ChildModel` to include `cityName`.
- **Repository Update**: Modified `getChildren` query to join `schools` AND `cities` (nested join: `schools(name, cities(name))`).
- **UI Update**: `_ChildCard` now displays "School Name, City" (e.g., "GEMS World Academy, Dubai") instead of just the school name.

### 3. Data Integrity
- Restored `schoolId` field in `ChildModel` which was momentarily lost during refactoring.
- Ensured `SchoolSelectionField` correctly handles initial values.

## Verification
1.  **Edit Child**: Open an existing child. If they have a linked school, the City and School dropdowns should be pre-filled. Changing the city clears the school selection. Saving updates the database with the valid `school_id`.
2.  **View Profile**: The list of children now shows the city name next to the school name, providing better context.

## Next Steps
- Verify that the Supabase query `schools(name, cities(name))` works as expected (requires `cities` relation on `schools` table, which matches the schema).
