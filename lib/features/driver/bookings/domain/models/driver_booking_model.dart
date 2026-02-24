// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_booking_model.freezed.dart';
part 'driver_booking_model.g.dart';

/// Freezed model for driver bookings with hybrid architecture pattern.
/// Uses explicit JsonKey annotations for Supabase snake_case mapping.
/// Includes toLegacyMap() for backward compatibility during migration.
@freezed
abstract class DriverBooking with _$DriverBooking {
  const DriverBooking._();

  const factory DriverBooking({
    // Core identifiers
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'driver_id') required String driverId,
    @JsonKey(name: 'parent_id') required String parentId,
    @JsonKey(name: 'status') @Default('pending') String status,
    @JsonKey(name: 'booking_type') @Default('') String bookingType,

    // Pricing
    @JsonKey(name: 'price') @Default(0.0) double price,
    @JsonKey(name: 'proposal_price') double? proposalPrice,

    // Location text
    @JsonKey(name: 'hometxt_location') @Default('') String homeLocation,
    @JsonKey(name: 'schooltxt_location') @Default('') String schoolLocation,

    // Location coordinates
    @JsonKey(name: 'home_lat') double? homeLat,
    @JsonKey(name: 'home_lng') double? homeLng,
    @JsonKey(name: 'school_lat') double? schoolLat,
    @JsonKey(name: 'school_lng') double? schoolLng,

    // School references
    @JsonKey(name: 'school_id') String? schoolId,
    @JsonKey(name: 'school_ids') List<String>? schoolIds,
    @JsonKey(name: 'school_name') String? schoolName,

    // Time fields
    @JsonKey(name: 'home_pickup_time') String? homePickupTime,
    @JsonKey(name: 'school_pickup_time') String? schoolPickupTime,

    // Date fields
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'created_at') @Default('') String createdAt,

    // Recurring booking fields
    @JsonKey(name: 'is_recurring') @Default(false) bool isRecurring,
    @JsonKey(name: 'recurring_days') @Default([]) List<String> recurringDays,
    @JsonKey(name: 'is_monthly_subscription')
    @Default(false)
    bool isMonthlySubscription,

    // Subscription & Contract
    @JsonKey(name: 'subscription_status') String? subscriptionStatus,
    @JsonKey(name: 'contract_start_date') String? contractStartDate,
    @JsonKey(name: 'contract_end_date') String? contractEndDate,

    // Pause dates
    @JsonKey(name: 'pause_start_date') String? pauseStartDate,
    @JsonKey(name: 'pause_end_date') String? pauseEndDate,

    // Cancellation
    @JsonKey(name: 'cancellation_type') String? cancellationType,
    @JsonKey(name: 'cancellation_reason') String? cancellationReason,
    @JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,

    // Route ordering
    @JsonKey(name: 'routego_order') int? routegoOrder,
    @JsonKey(name: 'routeret_order') int? routeretOrder,

    // Notes
    @JsonKey(name: 'notes') String? notes,

    // === ENRICHED FROM VIEW (JOINs) ===
    // Parent info
    @JsonKey(name: 'parent_name') String? parentName,
    @JsonKey(name: 'parent_photo') String? parentPhoto,
    @JsonKey(name: 'parent_phone') String? parentPhone,

    // Children info (from booking_children junction)
    @JsonKey(name: 'children') @Default([]) List<BookingChild> children,
  }) = _DriverBooking;

  factory DriverBooking.fromJson(Map<String, dynamic> json) =>
      _$DriverBookingFromJson(json);

  /// Legacy compatibility: Converts to Map for widgets still using Map access
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'driver_id': driverId,
      'parent_id': parentId,
      'status': status,
      'booking_type': bookingType,
      'price': price,
      'proposal_price': proposalPrice,
      'hometxt_location': homeLocation,
      'schooltxt_location': schoolLocation,
      'home_lat': homeLat,
      'home_lng': homeLng,
      'school_lat': schoolLat,
      'school_lng': schoolLng,
      'school_id': schoolId,
      'school_ids': schoolIds,
      'school_name': schoolName,
      'home_pickup_time': homePickupTime,
      'school_pickup_time': schoolPickupTime,
      'start_date': startDate,
      'end_date': endDate,
      'created_at': createdAt,
      'is_recurring': isRecurring,
      'recurring_days': recurringDays,
      'is_monthly_subscription': isMonthlySubscription,
      'subscription_status': subscriptionStatus,
      'contract_start_date': contractStartDate,
      'contract_end_date': contractEndDate,
      'pause_start_date': pauseStartDate,
      'pause_end_date': pauseEndDate,
      'cancellation_type': cancellationType,
      'cancellation_reason': cancellationReason,
      'cancel_requested_at': cancelRequestedAt,
      'cancelled_at': cancelledAt,
      'routego_order': routegoOrder,
      'routeret_order': routeretOrder,
      'notes': notes,
      'parent_name': parentName,
      'parent_photo': parentPhoto,
      'parent_phone': parentPhone,
      'children': children.map((c) => c.toLegacyMap()).toList(),
      // Convenience fields for widgets
      'child_name': children.isNotEmpty ? children.first.name : null,
      'kids_count': children.length,
    };
  }

  /// Check if booking request is expired (older than 7 days and still pending)
  bool get isExpired {
    if (status != 'pending') return false;
    final created = DateTime.tryParse(createdAt);
    if (created == null) return false;
    return DateTime.now().difference(created).inDays > 7;
  }

  /// Get first child name for display
  String get firstChildName =>
      children.isNotEmpty ? children.first.name : 'Child';

  /// Get formatted list of child names
  String get childNamesFormatted => children.map((c) => c.name).join(', ');
}

/// Freezed model for booking children
@freezed
abstract class BookingChild with _$BookingChild {
  const BookingChild._();

  const factory BookingChild({
    @JsonKey(name: 'id') @Default('') String id,
    @JsonKey(name: 'name') @Default('') String name,
    @JsonKey(name: 'school_name') @Default('') String schoolName,
    @JsonKey(name: 'grade') @Default('') String grade,
    @JsonKey(name: 'age') int? age,
    @JsonKey(name: 'gender') String? gender,
  }) = _BookingChild;

  factory BookingChild.fromJson(Map<String, dynamic> json) =>
      _$BookingChildFromJson(json);

  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'name': name,
      'school_name': schoolName,
      'grade': grade,
      'age': age,
      'gender': gender,
    };
  }
}
