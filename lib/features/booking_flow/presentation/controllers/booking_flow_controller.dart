import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/school_location_model.dart';
import '../../data/models/booking_draft_model.dart';
import '../../../parent/children/data/children_repository.dart'; // Import repo

part 'booking_flow_controller.g.dart';

/// Controller for managing booking flow state and navigation between steps
@riverpod
class BookingFlowController extends _$BookingFlowController {
  @override
  BookingDraftModel build() {
    // Initialize with smart defaults for school transport scenario
    return const BookingDraftModel(
      tripCategory: 'school',
      bookingType: 'Two Way',
    );
  }

  // Step 1: Child Selection (Single child - backward compatibility)
  void selectChild(String studentId) {
    state = state.copyWith(
      studentId: studentId,
      studentIds: [studentId], // Also update list for consistency
    );
  }

  // Step 1: Multiple Children Selection
  void toggleChildSelection(String studentId) {
    final currentIds = List<String>.from(state.studentIds);

    if (currentIds.contains(studentId)) {
      currentIds.remove(studentId);
    } else {
      currentIds.add(studentId);
    }

    state = state.copyWith(
      studentIds: currentIds,
      studentId: currentIds.isEmpty
          ? null
          : currentIds.first, // Keep first for backward compat
    );
  }

  // Clear all child selections
  void clearChildSelections() {
    state = state.copyWith(studentId: null, studentIds: []);
  }

  // Step 2: Trip Category
  Future<void> selectTripCategory(String category) async {
    // Logic:
    // If switching TO 'school' -> Re-evaluate multi-school logic
    // If switching AWAY from 'school' -> Reset multi-school logic

    if (category == 'school') {
      // 1. Update category
      state = state.copyWith(tripCategory: category);

      // 2. Re-evaluate
      await buildSchoolLocationsFromChildren();
    } else {
      // 1. Update category
      // 2. Disable multi-school
      state = state.copyWith(
        tripCategory: category,
        isMultiSchool: false,
        schoolLocations: [],
      );
    }
  }

  // Step 3: Direction
  void selectDirection(String bookingType) {
    state = state.copyWith(bookingType: bookingType);
  }

  // Step 4: Locations
  void setPickupLocation({
    required String locationText,
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(
      pickupLocationText: locationText,
      pickupLat: lat,
      pickupLng: lng,
    );
  }

  void setDropoffLocation({
    required String locationText,
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(
      dropoffLocationText: locationText,
      dropoffLat: lat,
      dropoffLng: lng,
    );
  }

  // Step 5: Schedule Type
  void selectScheduleType({
    required bool isOneTime,
    required bool isRecurring,
    required bool isMonthlySubscription,
  }) {
    state = state.copyWith(
      isOneTime: isOneTime,
      isRecurring: isRecurring,
      isMonthlySubscription: isMonthlySubscription,
    );
  }

  void setOneTimeSchedule({
    required DateTime pickupDatetime,
    DateTime? dropoffDatetime,
  }) {
    state = state.copyWith(
      scheduledPickupDatetime: pickupDatetime,
      scheduledDropoffDatetime: dropoffDatetime,
    );
  }

  void setRecurringSchedule({
    required List<String> recurringDays,
    required String pickupTime,
    String? dropoffTime,
  }) {
    state = state.copyWith(
      recurringDays: recurringDays,
      homePickupTime: pickupTime,
      schoolPickupTime: dropoffTime,
    );
  }

  void setMonthlySubscription({
    required DateTime contractStartDate,
    required DateTime contractEndDate,
    required String pickupTime,
    String? dropoffTime,
  }) {
    state = state.copyWith(
      contractStartDate: contractStartDate,
      contractEndDate: contractEndDate,
      homePickupTime: pickupTime,
      schoolPickupTime: dropoffTime,
    );
  }

  // Navigation
  Future<void> nextStep() async {
    if (state.currentStep < 6) {
      // PRE-TRANSITION LOGIC

      // If we are about to enter Step 4 (Locations) and category is 'school',
      // ensure we have the correct multi-school state.
      // Current Step is 3 (Direction) -> Next is 4.
      if (state.currentStep == 3 && state.tripCategory == 'school') {
        // Force rebuild to ensure state is fresh based on current selections
        await buildSchoolLocationsFromChildren();
      }

      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 6) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Validation
  bool canProceedFromStep(int step) {
    switch (step) {
      case 1:
        // Support both single and multiple child selection
        return (state.studentId != null && state.studentId!.isNotEmpty) ||
            (state.studentIds.isNotEmpty);
      case 2:
        return state.tripCategory.isNotEmpty;
      case 3:
        return state.bookingType != null && state.bookingType!.isNotEmpty;
      case 4:
        // Check based on direction
        final bookingType = state.bookingType ?? '';
        // Check multi-school logic first
        if (state.isMultiSchool) {
          // Must have Pickup
          if (!_hasValidLocation(
            state.pickupLocationText,
            state.pickupLat,
            state.pickupLng,
          )) {
            return false;
          }
          // Must have valid Schools (allowed if auto-populated)
          if (state.schoolLocations.isEmpty) return false;

          return state.schoolLocations.every(
            (s) => s.schoolId.isNotEmpty && s.schoolId != 'pending_selection',
          );
        }

        if (bookingType == 'Two Way' || bookingType == 'One Way to School') {
          return _hasValidLocation(
                state.pickupLocationText,
                state.pickupLat,
                state.pickupLng,
              ) &&
              _hasValidLocation(
                state.dropoffLocationText,
                state.dropoffLat,
                state.dropoffLng,
              );
        } else if (bookingType == 'One Way Back Home') {
          return _hasValidLocation(
            state.dropoffLocationText,
            state.dropoffLat,
            state.dropoffLng,
          );
        }
        return false;
      case 5:
        // Check schedule type is selected and has required data
        if (state.isOneTime) {
          return state.scheduledPickupDatetime != null;
        } else if (state.isRecurring) {
          return state.recurringDays != null &&
              state.recurringDays!.isNotEmpty &&
              state.homePickupTime != null &&
              state.homePickupTime!.isNotEmpty;
        } else if (state.isMonthlySubscription) {
          return state.contractStartDate != null &&
              state.contractEndDate != null &&
              state.homePickupTime != null &&
              state.homePickupTime!.isNotEmpty;
        }
        return false;
      default:
        return true;
    }
  }

  bool _hasValidLocation(String? text, double? lat, double? lng) {
    return text != null &&
        text.isNotEmpty &&
        lat != null &&
        lng != null &&
        lat != 0 &&
        lng != 0;
  }

  // Reset flow
  void reset() {
    state = const BookingDraftModel();
  }

  // Set driver and price for review
  void setDriverAndPrice({
    required String driverId,
    required double estimatedPrice,
    double? distanceKm,
    int? durationMinutes,
  }) {
    state = state.copyWith(
      driverId: driverId,
      estimatedPrice: estimatedPrice,
      totalEstimatedDistanceKm: distanceKm,
      totalEstimatedDurationMinutes: durationMinutes,
    );
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  // Auto-populate locations from user profile and child's school
  void autoPopulateLocations({
    String? homeLocationText,
    double? homeLat,
    double? homeLng,
    String? schoolLocationText,
    double? schoolLat,
    double? schoolLng,
    bool? requiresManualSelection, // If children go to different schools
  }) {
    state = state.copyWith(
      pickupLocationText: homeLocationText,
      pickupLat: homeLat,
      pickupLng: homeLng,
      dropoffLocationText: requiresManualSelection == true
          ? null
          : schoolLocationText,
      dropoffLat: requiresManualSelection == true ? null : schoolLat,
      dropoffLng: requiresManualSelection == true ? null : schoolLng,
      // If manual selection required, it might be due to multi-school
      // We don't set isMultiSchool here directly, it's set by buildSchoolLocationsFromChildren
    );
  }

  // Build school locations structure for multi-child/multi-school scenarios
  Future<void> buildSchoolLocationsFromChildren() async {
    final selectedIds = state.studentIds;
    if (selectedIds.isEmpty) {
      state = state.copyWith(isMultiSchool: false, schoolLocations: []);
      return;
    }

    // Only activate multi-school logic if Trip Category is 'school'
    if (state.tripCategory != 'school') {
      state = state.copyWith(isMultiSchool: false, schoolLocations: []);
      return;
    }

    // Fetch children internally
    // We use ref.read to get the latest value from the provider
    // This might be async if not loaded, but typically it's cached by Riverpod if previously watched.
    // Using `.future` ensures we await it if it's loading.
    final allChildren = await ref.read(myChildrenProvider.future);

    final selectedChildren = allChildren
        .where((c) => selectedIds.contains(c.id))
        .toList();

    // Group children by school
    final Map<String, List<dynamic>> childrenBySchool = {};
    final List<dynamic> childrenWithoutSchool = [];

    for (final child in selectedChildren) {
      final String? schoolId = child.schoolId;
      if (schoolId != null && schoolId.isNotEmpty) {
        childrenBySchool.putIfAbsent(schoolId, () => []).add(child);
      } else {
        childrenWithoutSchool.add(child);
      }
    }

    final uniqueSchools = childrenBySchool.keys.toList();

    // The user requested: "School Transport ... Dropoff replaced with schools of child(s)"
    // ALWAYS use multi-school mode if Trip Category is 'school'.
    // This ensures consistent UI showing the list of schools instead of text field.
    const bool useMultiSchool = true;

    if (useMultiSchool) {
      final List<SchoolLocationModel> locations = [];
      final supabase = Supabase.instance.client;

      // 1. Fetch details for known schools
      if (uniqueSchools.isNotEmpty) {
        try {
          final response = await supabase
              .from('schools')
              .select('id, name, address, latitude, longitude')
              .filter('id', 'in', uniqueSchools);

          final schoolsData = response as List;

          for (final schoolData in schoolsData) {
            final schoolId = schoolData['id'] as String;
            final students = childrenBySchool[schoolId] ?? [];
            final studentIds = students.map((c) => c.id as String).toList();

            locations.add(
              SchoolLocationModel(
                schoolId: schoolId,
                schoolName: schoolData['name'] ?? 'Unknown School',
                schoolAddress: schoolData['address'],
                latitude: schoolData['latitude'],
                longitude: schoolData['longitude'],
                studentIds: studentIds,
              ),
            );
          }
        } catch (e) {
          // Handle error (maybe offline)
          // Fallback to basic info from children objects
          for (final schoolId in uniqueSchools) {
            final students = childrenBySchool[schoolId] ?? [];
            final firstChild = students.isNotEmpty ? students.first : null;
            final studentIds = students.map((c) => c.id as String).toList();

            locations.add(
              SchoolLocationModel(
                schoolId: schoolId,
                schoolName: firstChild?.schoolName ?? 'School',
                studentIds: studentIds,
              ),
            );
          }
        }
      }

      // 2. Handle children without school (Placeholder locations)
      if (childrenWithoutSchool.isNotEmpty) {
        // We might group them or add individually?
        // Let's add one "Unknown School" entry for them OR separate entries?
        // Ideally we need to ask user to select school for these children.
        // We can create a placeholder SchoolLocationModel with empty ID/Coords

        // Group them into one "Pending Selection" entry?
        // Or one entry per child?
        // The UI will likely iterate schoolLocations.
        // If we want "Child A -> Select School", we basically need a location wrapper per child?
        // But SchoolLocationModel is cleaner as "School -> [Children]".

        // Let's create a "Pending" location for these children
        final pendingStudentIds = childrenWithoutSchool
            .map((c) => c.id as String)
            .toList();
        locations.add(
          SchoolLocationModel(
            schoolId: 'pending_selection',
            schoolName: 'Select School',
            studentIds: pendingStudentIds,
          ),
        );
      }

      state = state.copyWith(
        isMultiSchool: true,
        schoolLocations: locations,
        dropoffLocationText: null, // Clear single dropoff
        dropoffLat: null,
        dropoffLng: null,
      );
    } else {
      // Single school case logic (already handled by autoPopulateLocations mostly)
      // But we ensure isMultiSchool is false
      state = state.copyWith(isMultiSchool: false, schoolLocations: []);
    }
  }

  // Update a specific school location
  void updateSchoolLocation(int index, SchoolLocationModel newLocation) {
    print(
      'Updating school location at index $index with ${newLocation.schoolName}',
    );
    final currentLocations = List<SchoolLocationModel>.from(
      state.schoolLocations,
    );
    if (index >= 0 && index < currentLocations.length) {
      currentLocations[index] = newLocation;
      state = state.copyWith(schoolLocations: currentLocations);
    }
  }

  // Set default contract dates (August to May)
  void setDefaultContractDates() {
    final now = DateTime.now();
    final currentYear = now.year;

    // Academic year: August current year to May next year
    final startDate = DateTime(currentYear, 8, 1); // August 1st
    final endDate = DateTime(currentYear + 1, 5, 31); // May 31st next year

    state = state.copyWith(
      contractStartDate: startDate,
      contractEndDate: endDate,
    );
  }

  void setDriverInfo({required String driverId, String? notes}) {
    state = state.copyWith(driverId: driverId, notes: notes);
  }

  void setPublicRequestMode(bool isPublic) {
    state = state.copyWith(isPublicRequest: isPublic);
  }

  void setEstimatedPrice(double price) {
    state = state.copyWith(estimatedPrice: price);
  }
}
