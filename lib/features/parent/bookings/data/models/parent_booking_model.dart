import 'package:freezed_annotation/freezed_annotation.dart';

part 'parent_booking_model.freezed.dart';
part 'parent_booking_model.g.dart';

/// Type-safe model for parent bookings from the parent_bookings_view.
/// Includes enriched driver and school information from JOINs.
@freezed
abstract class ParentBooking with _$ParentBooking {
  const ParentBooking._();

  // ignore_for_file: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ParentBooking({
    // Core identifiers
    required String id,
    required String parentId,
    String? driverId,
    required String bookingType,
    String? status,

    // Location text
    String? hometxtLocation,
    String? schooltxtLocation,

    // Time fields
    String? homePickupTime,
    String? schoolPickupTime,

    // Pricing
    double? price,
    double? proposalPrice,

    // Notes
    String? notes,

    // Timestamps
    DateTime? createdAt,

    // Recurring booking fields
    @Default(false) bool isRecurring,
    Map<String, dynamic>? recurrencePattern,
    String? subscriptionStatus,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? recurringDays,
    @Default(false) bool isMonthlySubscription,

    // Geo locations (as text from view)
    String? homegeoLocationText,
    String? schoolgeoLocationText,
    double? homeLat,
    double? homeLng,
    double? schoolLat,
    double? schoolLng,

    // Route ordering
    int? routegoOrder,
    int? routeretOrder,

    // School reference
    String? studentId,
    String? schoolId,
    String? schoolName,
    List<String>? schoolIds,
    @Default(false) bool isMultiSchool,

    // Payment & cancellation
    String? paymentStatus,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancellationType,
    double? cancellationFee,
    DateTime? cancelRequestedAt,

    // Contract dates
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    DateTime? pauseStartDate,
    DateTime? pauseEndDate,

    // Trip category
    String? tripCategory,
    @Default(false) bool isOneTime,
    DateTime? scheduledPickupDatetime,
    DateTime? scheduledDropoffDatetime,

    // Custom locations
    String? customPickupLocationText,
    String? customPickupGeoText,
    String? customDropoffLocationText,
    String? customDropoffGeoText,
    double? customPickupLat,
    double? customPickupLng,
    double? customDropoffLat,
    double? customDropoffLng,

    // Booking flow
    String? bookingFlowStep,
    double? totalEstimatedDistanceKm,
    int? totalEstimatedDurationMinutes,
    @Default(false) bool isForParent,

    // ====== ENRICHED FROM VIEW (JOINs) ======

    // Driver info (from users table)
    String? driverName,
    String? driverPhoto,
    String? driverPhone,

    // School info (from schools table)
    String? schoolNameLookup,
    String? schoolAddress,

    // ====== ENRICHED IN DART (children) ======
    // These are populated by the repository after fetching from booking_children
    @Default(0) int kidsCount,
    @Default([]) List<String> childNames,
    @Default([]) List<Map<String, dynamic>> studentsInfo,
  }) = _ParentBooking;

  factory ParentBooking.fromJson(Map<String, dynamic> json) =>
      _$ParentBookingFromJson(json);

  /// Converts to legacy Map format for backwards compatibility during migration.
  /// This allows gradual migration of widgets from Map to typed model.
  Map<String, dynamic> toLegacyMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'driver_id': driverId,
      'driver_name': driverName,
      'driver_photo': driverPhoto,
      'driver_phone': driverPhone,
      'booking_type': bookingType,
      'status': status,
      'hometxt_location': hometxtLocation,
      'schooltxt_location': schooltxtLocation,
      'home_location': hometxtLocation,
      'school_location': schooltxtLocation,
      'home_pickup_time': homePickupTime,
      'school_pickup_time': schoolPickupTime,
      'price': price,
      'proposal_price': proposalPrice,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'is_recurring': isRecurring,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'recurring_days': recurringDays,
      'home_lat': homeLat,
      'home_lng': homeLng,
      'school_lat': schoolLat,
      'school_lng': schoolLng,
      'school_id': schoolId,
      'school_name': schoolNameLookup ?? schoolName,
      'school_address': schoolAddress,
      'kids_count': kidsCount,
      'child_names': childNames,
      'students_info': studentsInfo,
      'child_name': childNames.isNotEmpty ? childNames.first : null,
      'trip_category': tripCategory,
      'is_one_time': isOneTime,
      'is_for_parent': isForParent,
    };
  }
}
