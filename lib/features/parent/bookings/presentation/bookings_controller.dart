import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/bookings_repository.dart';
import '../../children/data/children_repository.dart';

part 'bookings_controller.g.dart';

/// Controller that encapsulates all booking business logic.
/// Handles validation and submission of booking requests.
@riverpod
class BookingsController extends _$BookingsController {
  @override
  FutureOr<void> build() {}

  /// Validates booking data and submits to repository.
  /// Returns true on success, throws on validation error.
  Future<bool> submitBooking({
    required String driverId,
    required List<String> childIds,
    required String bookingType,
    String? schoolId,
    String? schoolName,
    String? homeLocation,
    String? schoolLocation,
    double? homeLat,
    double? homeLng,
    double? schoolLat,
    double? schoolLng,
    TimeOfDay? homePickupTime,
    TimeOfDay? schoolPickupTime,
    String? notes,
    // NEW: Recurring Params
    required DateTime startDate,
    required DateTime endDate,
    bool isRecurring = false,
    List<String>? recurringDays,
    bool isMonthlySubscription = false,
  }) async {
    // Validation
    if (childIds.isEmpty) {
      throw Exception('Please select at least one child');
    }

    if (bookingType == 'Two Way' &&
        (homePickupTime == null || schoolPickupTime == null)) {
      throw Exception('Please select both pickup times for Two Way booking');
    }

    if (bookingType == 'One Way to School' && homePickupTime == null) {
      throw Exception('Please select home pickup time');
    }

    if (bookingType == 'One Way Back Home' && schoolPickupTime == null) {
      throw Exception('Please select school pickup time');
    }

    if (endDate.isBefore(startDate)) {
      throw Exception('End date cannot be before start date');
    }

    if (isRecurring && (recurringDays == null || recurringDays.isEmpty)) {
      throw Exception('Please select at least one day for recurring booking');
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingsRepositoryProvider)
          .createBooking(
            driverId: driverId,
            childIds: childIds,
            bookingType: bookingType,
            schoolId: schoolId,
            schoolName: schoolName,
            homeLocation: homeLocation ?? '',
            schoolLocation: schoolLocation ?? '',
            homeLat: homeLat,
            homeLng: homeLng,
            schoolLat: schoolLat,
            schoolLng: schoolLng,
            homePickupTime: homePickupTime,
            schoolPickupTime: schoolPickupTime,
            notes: notes ?? '',
            startDate: startDate,
            endDate: endDate,
            isRecurring: isRecurring,
            recurringDays: recurringDays,
            isMonthlySubscription: isMonthlySubscription,
          );
    });

    if (!state.hasError) {
      ref.invalidate(myBookingsProvider);
    }

    return !state.hasError;
  }

  /// Cancels a booking by ID.
  Future<bool> cancelBooking(
    String bookingId, {
    String status = 'cancelled',
    String? cancellationType,
    String? cancellationReason,
    DateTime? contractEndDate,
    DateTime? pauseStartDate,
    DateTime? pauseEndDate,
    double? cancellationFee,
    DateTime? cancelRequestedAt,
    String? subscriptionStatus,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingsRepositoryProvider)
          .cancelBooking(
            bookingId,
            status: status,
            cancellationType: cancellationType,
            cancellationReason: cancellationReason,
            contractEndDate: contractEndDate,
            pauseStartDate: pauseStartDate,
            pauseEndDate: pauseEndDate,
            cancellationFee: cancellationFee,
            cancelRequestedAt: cancelRequestedAt,
            subscriptionStatus: subscriptionStatus,
          );
    });

    if (!state.hasError) {
      ref.invalidate(myBookingsProvider);
    }

    return !state.hasError;
  }

  Future<bool> updateBookingFields(
    String bookingId,
    Map<String, dynamic> fields,
  ) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingsRepositoryProvider)
          .updateBookingFields(bookingId, fields);
    });

    return !state.hasError;
  }
}
