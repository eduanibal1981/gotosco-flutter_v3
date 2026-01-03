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
    String? homeLocation,
    String? schoolLocation,
    double? homeLat,
    double? homeLng,
    double? schoolLat,
    double? schoolLng,
    TimeOfDay? homePickupTime,
    TimeOfDay? schoolPickupTime,
    String? notes,
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

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(bookingsRepositoryProvider)
          .createBooking(
            driverId: driverId,
            childIds: childIds,
            bookingType: bookingType,
            homeLocation: homeLocation ?? '',
            schoolLocation: schoolLocation ?? '',
            homeLat: homeLat,
            homeLng: homeLng,
            schoolLat: schoolLat,
            schoolLng: schoolLng,
            homePickupTime: homePickupTime,
            schoolPickupTime: schoolPickupTime,
            notes: notes ?? '',
          );
    });

    return !state.hasError;
  }

  /// Cancels a booking by ID.
  Future<bool> cancelBooking(String bookingId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(bookingsRepositoryProvider).cancelBooking(bookingId);
    });

    return !state.hasError;
  }
}
