import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'booking_flow_contract_provider.dart';
import '../domain/contracts/booking_flow_contract.dart';
import '../domain/models/booking_draft_model.dart';
import '../domain/models/booking_flow_child_model.dart';
import '../domain/models/booking_flow_school_model.dart';
import '../domain/models/school_location_model.dart';

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

  BookingFlowContract get _bookingFlowContract =>
      ref.read(bookingFlowContractProvider);

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
      isForParent: false, // Deselect parent if selecting children
    );
  }

  // Clear all child selections
  void clearChildSelections() {
    state = state.copyWith(studentId: null, studentIds: [], isForParent: false);
  }

  // Step 1: Parent booking for themselves
  void selectParentSelf() {
    state = state.copyWith(isForParent: true, studentId: null, studentIds: []);
  }

  // Deselect parent self (when selecting children instead)
  void deselectParentSelf() {
    state = state.copyWith(isForParent: false);
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
    String? pickupTime,
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
    String? pickupTime,
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
        // Support child selection OR parent booking for themselves
        return state.isForParent ||
            (state.studentId != null && state.studentId!.isNotEmpty) ||
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
        }

        final bookingType = state.bookingType ?? 'Two Way';
        final hasHomeTime =
            state.homePickupTime != null && state.homePickupTime!.isNotEmpty;
        final hasSchoolTime =
            state.schoolPickupTime != null &&
            state.schoolPickupTime!.isNotEmpty;

        bool timeValid = false;
        if (bookingType == 'Two Way') {
          timeValid = hasHomeTime && hasSchoolTime;
        } else if (bookingType == 'One Way to School') {
          timeValid = hasHomeTime;
        } else if (bookingType == 'One Way Back Home') {
          timeValid = hasSchoolTime;
        }

        if (state.isRecurring) {
          return state.recurringDays != null &&
              state.recurringDays!.isNotEmpty &&
              timeValid;
        } else if (state.isMonthlySubscription) {
          return state.contractStartDate != null &&
              state.contractEndDate != null &&
              timeValid;
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

  Future<List<BookingFlowSchoolModel>> searchSchools(
    String query, {
    String? cityId,
  }) {
    return _bookingFlowContract.searchSchools(query, cityId: cityId);
  }

  Future<void> autoPopulateLocationsForSelectedChildren() async {
    final selectedIds = state.studentIds;
    if (selectedIds.isEmpty) {
      autoPopulateLocations(
        homeLocationText: null,
        homeLat: null,
        homeLng: null,
        schoolLocationText: null,
        schoolLat: null,
        schoolLng: null,
      );
      return;
    }

    final userLocation = await _bookingFlowContract.getCurrentUserLocation();
    final allChildren = await _bookingFlowContract.getMyChildren();
    final selectedChildren = allChildren
        .where((child) => selectedIds.contains(child.id))
        .toList();

    String? schoolLocationText;
    double? schoolLat;
    double? schoolLng;
    var requiresManualSelection = false;

    if (selectedChildren.isNotEmpty) {
      final schoolIds = selectedChildren
          .where((child) => child.schoolId != null && child.schoolId!.isNotEmpty)
          .map((child) => child.schoolId!)
          .toSet()
          .toList();

      if (schoolIds.isEmpty) {
        requiresManualSelection = true;
      } else if (schoolIds.length == 1) {
        final schools = await _bookingFlowContract.getSchoolsByIds(schoolIds);
        if (schools.isNotEmpty) {
          final school = schools.first;
          schoolLocationText =
              school.address ??
              school.name;
          schoolLat = school.latitude;
          schoolLng = school.longitude;
        } else {
          final firstChild = selectedChildren.first;
          schoolLocationText = firstChild.schoolName.isNotEmpty
              ? firstChild.schoolName
              : null;
        }
      } else {
        requiresManualSelection = true;
      }
    }

    autoPopulateLocations(
      homeLocationText: userLocation?.locationText,
      homeLat: userLocation?.locationLat,
      homeLng: userLocation?.locationLng,
      schoolLocationText: schoolLocationText,
      schoolLat: schoolLat,
      schoolLng: schoolLng,
      requiresManualSelection: requiresManualSelection,
    );

    await buildSchoolLocationsFromChildren();
  }

  // Build school locations structure for multi-child/multi-school scenarios
  Future<void> buildSchoolLocationsFromChildren() async {
    final selectedIds = state.studentIds;
    if (selectedIds.isEmpty || state.tripCategory != 'school') {
      state = state.copyWith(isMultiSchool: false, schoolLocations: []);
      return;
    }

    final allChildren = await _bookingFlowContract.getMyChildren();
    final selectedChildren = allChildren
        .where((child) => selectedIds.contains(child.id))
        .toList();

    final childrenBySchool = <String, List<BookingFlowChildModel>>{};
    final childrenWithoutSchool = <BookingFlowChildModel>[];

    for (final child in selectedChildren) {
      final schoolId = child.schoolId;
      if (schoolId != null && schoolId.isNotEmpty) {
        childrenBySchool.putIfAbsent(schoolId, () => []).add(child);
      } else {
        childrenWithoutSchool.add(child);
      }
    }

    final locations = <SchoolLocationModel>[];
    final uniqueSchoolIds = childrenBySchool.keys.toList();

    if (uniqueSchoolIds.isNotEmpty) {
      final schools = await _bookingFlowContract.getSchoolsByIds(uniqueSchoolIds);
      final schoolsById = <String, BookingFlowSchoolModel>{
        for (final school in schools) school.id: school,
      };

      for (final schoolId in uniqueSchoolIds) {
        final students = childrenBySchool[schoolId] ?? const [];
        final studentIds = students.map((student) => student.id).toList();
        final school = schoolsById[schoolId];

        locations.add(
          SchoolLocationModel(
            schoolId: schoolId,
            schoolName:
                school?.name ??
                (students.isNotEmpty ? students.first.schoolName : 'School'),
            schoolAddress: school?.address,
            latitude: school?.latitude,
            longitude: school?.longitude,
            studentIds: studentIds,
          ),
        );
      }
    }

    if (childrenWithoutSchool.isNotEmpty) {
      final pendingStudentIds = childrenWithoutSchool
          .map((child) => child.id)
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
      dropoffLocationText: null,
      dropoffLat: null,
      dropoffLng: null,
    );
  }

  // Update a specific school location
  void updateSchoolLocation(int index, SchoolLocationModel newLocation) {
    developer.log(
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

  // Set default contract dates (August to May) - only if not already set
  void setDefaultContractDates() {
    // Skip if dates are already set (e.g. from edit mode)
    if (state.contractStartDate != null && state.contractEndDate != null) {
      return;
    }

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

  /// Reset the booking flow to initial state
  void resetBookingFlow() {
    state = const BookingDraftModel(
      tripCategory: 'school',
      bookingType: 'Two Way',
    );
  }

  /// Load booking data from an existing booking for editing
  /// This populates all draft fields from a booking Map retrieved from DB
  void loadFromBooking(Map<String, dynamic> booking, {String? editBookingId}) {
    developer.log('ðŸ”„ Loading booking data for edit: ${booking.keys.toList()}');

    // Parse child IDs from students_info
    // The students_info comes from booking_children join with children(id, name)
    List<String> childIds = [];
    if (booking['students_info'] != null && booking['students_info'] is List) {
      final studentsInfo = booking['students_info'] as List;
      developer.log('ðŸ“‹ Students info: $studentsInfo');

      for (final child in studentsInfo) {
        if (child is Map<String, dynamic>) {
          // Try direct 'id' field first
          if (child['id'] != null) {
            childIds.add(child['id'] as String);
          }
        }
      }
    }

    // If students_info didn't work, try child_ids array (if stored directly)
    if (childIds.isEmpty && booking['child_ids'] != null) {
      childIds = (booking['child_ids'] as List)
          .map((id) => id.toString())
          .toList();
    }

    developer.log('ðŸ‘¶ Extracted child IDs: $childIds');

    // Parse pickup times
    String? homePickupTime;
    String? schoolPickupTime;
    if (booking['home_pickup_time'] != null) {
      final t = booking['home_pickup_time'].toString();
      if (t.isNotEmpty) homePickupTime = t;
    }
    if (booking['school_pickup_time'] != null) {
      final t = booking['school_pickup_time'].toString();
      if (t.isNotEmpty) schoolPickupTime = t;
    }
    developer.log('â° Pickup times - Home: $homePickupTime, School: $schoolPickupTime');

    // Parse dates
    DateTime? contractStartDate;
    DateTime? contractEndDate;
    if (booking['start_date'] != null) {
      contractStartDate = DateTime.tryParse(booking['start_date'].toString());
    }
    if (booking['end_date'] != null) {
      contractEndDate = DateTime.tryParse(booking['end_date'].toString());
    } else if (booking['contract_end_date'] != null) {
      contractEndDate = DateTime.tryParse(
        booking['contract_end_date'].toString(),
      );
    }
    developer.log('ðŸ“… Dates - Start: $contractStartDate, End: $contractEndDate');

    // Parse scheduled datetime for one-time trips
    // Supabase stores timestamps in UTC, so convert to local time
    DateTime? scheduledPickupDatetime;
    DateTime? scheduledDropoffDatetime;
    if (booking['scheduled_pickup_datetime'] != null) {
      final parsed = DateTime.tryParse(
        booking['scheduled_pickup_datetime'].toString(),
      );
      scheduledPickupDatetime = parsed?.toLocal();
    }
    if (booking['scheduled_dropoff_datetime'] != null) {
      final parsed = DateTime.tryParse(
        booking['scheduled_dropoff_datetime'].toString(),
      );
      scheduledDropoffDatetime = parsed?.toLocal();
    }
    developer.log(
      'ðŸ• Scheduled - Pickup: $scheduledPickupDatetime, Dropoff: $scheduledDropoffDatetime',
    );

    // Parse recurring days
    List<String>? recurringDays;
    if (booking['recurring_days'] != null &&
        booking['recurring_days'] is List) {
      recurringDays = (booking['recurring_days'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Determine trip category (defaults to 'school' if not set)
    String tripCategory = (booking['trip_category'] as String?) ?? 'school';

    // Get booking type
    String? bookingType = booking['booking_type'] as String?;
    developer.log('ðŸš— Trip category: $tripCategory, Booking type: $bookingType');

    // Parse locations - try multiple field names
    String? pickupLocationText =
        booking['home_location'] as String? ??
        booking['hometxt_location'] as String?;
    String? dropoffLocationText =
        booking['school_location'] as String? ??
        booking['schooltxt_location'] as String?;

    // Parse geo coordinates
    double? pickupLat = _parseDouble(booking['home_lat']);
    double? pickupLng = _parseDouble(booking['home_lng']);
    double? dropoffLat = _parseDouble(booking['school_lat']);
    double? dropoffLng = _parseDouble(booking['school_lng']);

    developer.log(
      'ðŸ“ Locations - Pickup: $pickupLocationText, Dropoff: $dropoffLocationText',
    );
    developer.log(
      'ðŸ—ºï¸ Coords - Pickup: ($pickupLat, $pickupLng), Dropoff: ($dropoffLat, $dropoffLng)',
    );

    // Parse price
    double? estimatedPrice =
        _parseDouble(booking['price']) ??
        _parseDouble(booking['proposal_price']);

    state = BookingDraftModel(
      // Step 1: Child Selection
      studentIds: childIds,
      studentId: childIds.isNotEmpty ? childIds.first : null,
      isForParent: booking['is_for_parent'] == true,

      // Step 2: Trip Category
      tripCategory: tripCategory,

      // Step 3: Direction
      bookingType: bookingType,

      // Step 4: Locations
      pickupLocationText: pickupLocationText,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropoffLocationText: dropoffLocationText,
      dropoffLat: dropoffLat,
      dropoffLng: dropoffLng,

      // Multi-school
      isMultiSchool: booking['is_multi_school'] == true,

      // Step 5: Schedule
      isOneTime: booking['is_one_time'] == true,
      isRecurring: booking['is_recurring'] == true,
      isMonthlySubscription: booking['is_monthly_subscription'] == true,
      contractStartDate: contractStartDate,
      contractEndDate: contractEndDate,
      scheduledPickupDatetime: scheduledPickupDatetime,
      scheduledDropoffDatetime: scheduledDropoffDatetime,
      recurringDays: recurringDays,
      homePickupTime: homePickupTime,
      schoolPickupTime: schoolPickupTime,

      // Step 6: Review
      driverId: booking['driver_id'] as String?,
      estimatedPrice: estimatedPrice,
      notes: booking['notes'] as String?,

      // Flow state - start at step 6 (review) so user sees summary
      currentStep: 6,
      flowStep: 'draft',
      isPublicRequest: booking['driver_id'] == null,
    );

    developer.log(
      'âœ… Booking draft loaded: studentIds=${state.studentIds}, tripCategory=${state.tripCategory}',
    );

    // Auto-populate school locations if it's a school trip
    if (state.tripCategory == 'school') {
      buildSchoolLocationsFromChildren();
    }
  }

  /// Helper to safely parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

