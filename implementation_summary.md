# School Integration Implementation Plan

## Overview
This feature integrates School Management into the Child enrollment process. Parents can now select an existing school from a database or add a new school by picking its location on a map.

## Completed Tasks

### 1. Data Layer
- **SchoolModel**: Created with Freezed support (`lib/features/shared/schools/data/school_model.dart`).
- **SchoolsRepository**: Implemented to `upsert` (create/update) schools and search them (`lib/features/shared/schools/data/schools_repository.dart`).
- **ChildModel**: Updated to include `schoolId` and logic to retrieve school name from relations (`lib/features/parent/children/data/child_model.dart`).
- **ChildrenRepository**: Updated `addChild` to accept optional `schoolId` and persist it. Updated `getAllChildren` to join with `schools` table.

### 2. Presentation Layer
- **LocationPickerScreen**: New screen to pick lat/long using `flutter_map` (`lib/features/shared/location/presentation/location_picker_screen.dart`).
- **AddSchoolScreen**: New screen to add school details (Name, City, Location, Address) (`lib/features/shared/schools/presentation/add_school_screen.dart`).
- **SchoolSelectionField**: New autocomplete widget allowing search or creating a new school (`lib/features/shared/schools/presentation/school_selection_field.dart`).
- **AddChildScreen**: Integrated `SchoolSelectionField` to replace the simple text input.

### 3. Database
- **Migration**: Created `supabase/migrations/20260121120000_add_schools_and_children_update.sql` to:
    - Create `schools` table (if not exists).
    - Add `school_id` column to `children` table.

## Verification
- Run `flutter pub get`.
- Run `dart run build_runner build` (Already executed).
- Apply the SQL migration in Supabase Dashboard SQL Editor.
- Test "Add Child" flow:
    1. Search for a school.
    2. If not found, click "Add new school".
    3. Fill details and pick location.
    4. Save school -> Auto-selected in Add Child form.
    5. Save Child -> Persisted with `school_id`.
