import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/booking_draft_model.dart';

part 'booking_flow_controller.g.dart';

/// Controller for managing booking flow state and navigation between steps
@riverpod
class BookingFlowController extends _$BookingFlowController {
  @override
  BookingDraftModel build() {
    return const BookingDraftModel();
  }

  // Step 1: Child Selection
  void selectChild(String studentId) {
    state = state.copyWith(studentId: studentId);
  }

  // Step 2: Trip Category
  void selectTripCategory(String category) {
    state = state.copyWith(tripCategory: category);
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
  void nextStep() {
    if (state.currentStep < 6) {
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
        return state.studentId != null && state.studentId!.isNotEmpty;
      case 2:
        return state.tripCategory.isNotEmpty;
      case 3:
        return state.bookingType != null && state.bookingType!.isNotEmpty;
      case 4:
        // Check based on direction
        final bookingType = state.bookingType ?? '';
        if (bookingType == 'Two Way') {
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
        } else if (bookingType == 'One Way to School') {
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
}
