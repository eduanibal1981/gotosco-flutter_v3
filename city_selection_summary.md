# City Selection Implementation Plan

## Overview
Added a professional City Selection flow to the Add Child process. To solve the problem of overwhelming school lists, the user is now required to select a city first. This filters the school search and pre-fills the city when adding a new school.

## Completed Tasks

### 1. Repository Update
- **SchoolsRepository**: Updated `searchSchools` method to accept an optional `cityId`. The query now dynamically adds a `.eq('city_id', cityId)` filter if provided.

### 2. UI Components
- **SchoolSelectionField**:
    - Added `cityId` parameter.
    - Updated `_searchSchools` to pass this `cityId` to the repository.
    - Updated `_addNewSchool` to pass `cityId` to the `AddSchoolScreen`.
- **AddSchoolScreen**:
    - Added `initialCityId` parameter.
    - Updated `_loadCities` to auto-select the initial city if provided, saving the user a step.

### 3. Feature Integration (AddChildScreen)
- **City Dropdown**: Added `_buildCityDropdown` to `AddChildScreen` which fetches cities from `SchoolsRepository`.
- **Logic**:
    - Selecting a city updates `_selectedCity`.
    - `_selectedCity.id` is passed to `SchoolSelectionField`.
    - Reset `_selectedSchool` when city changes to ensure consistency.

## Verification
- **Build**: Running `dart run build_runner build` to ensure all providers are sync'd.
- **Workflow**:
    1. Navigate to Add Child.
    2. See "School Details" section.
    3. Select City (e.g., Dubai).
    4. Type in School Name (e.g., "GEMS").
    5. Search results are now filtered by Dubai.
    6. If adding new school, City dropdown in "Add School" screen is pre-set to Dubai.

## Note on DB Schema
The schema provided by the user aligns with these changes. The `location` geography column is present in the schema but we continue to use `latitude` and `longitude` fields explicitly for the application logic, which exist in the schema as well.
