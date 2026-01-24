import 'package:freezed_annotation/freezed_annotation.dart';
import 'school_location_model.dart';

part 'booking_draft_model.freezed.dart';
part 'booking_draft_model.g.dart';

/// Model for storing booking draft data as user progresses through flow
@freezed
abstract class BookingDraftModel with _$BookingDraftModel {
  const factory BookingDraftModel({
    // Step 1: Child Selection
    // Single student (backward compatibility)
    String? studentId,
    // Multiple students support
    @Default([]) List<String> studentIds,

    // Multi-School Support
    @Default(false) bool isMultiSchool,
    @Default([])
    List<SchoolLocationModel>
    schoolLocations, // Using dynamic to avoid circular dep issues during gen, maps to SchoolLocationModel
    // Step 2: Trip Category
    @Default('school') String tripCategory, // 'school', 'Journey', 'Other'
    // Step 3: Direction
    String? bookingType, // 'Two Way', 'One Way to School', 'One Way Back Home'
    // Step 4: Locations
    String? pickupLocationText,
    double? pickupLat,
    double? pickupLng,
    String? dropoffLocationText,
    double? dropoffLat,
    double? dropoffLng,

    // Step 5: Schedule
    @Default(false) bool isOneTime,
    @Default(false) bool isRecurring,
    @Default(true) bool isMonthlySubscription, // Default to monthly
    DateTime? scheduledPickupDatetime,
    DateTime? scheduledDropoffDatetime,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    List<String>? recurringDays, // ['monday', 'tuesday', etc.]
    String? homePickupTime, // Go pickup time (morning)
    String? schoolPickupTime, // Return pickup time (afternoon)
    // Step 6: Review / Metadata
    String? driverId,
    double? estimatedPrice,
    double? totalEstimatedDistanceKm,
    int? totalEstimatedDurationMinutes,
    String? notes,

    // Current flow state
    @Default(false) bool isPublicRequest,
    @Default(1) int currentStep,
    @Default('draft') String flowStep, // 'draft', 'submitted', 'confirmed'
  }) = _BookingDraftModel;

  factory BookingDraftModel.fromJson(Map<String, dynamic> json) =>
      _$BookingDraftModelFromJson(json);
}
