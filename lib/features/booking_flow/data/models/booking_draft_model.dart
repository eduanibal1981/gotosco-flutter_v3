import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_draft_model.freezed.dart';
part 'booking_draft_model.g.dart';

/// Model for storing booking draft data as user progresses through flow
@freezed
abstract class BookingDraftModel with _$BookingDraftModel {
  const factory BookingDraftModel({
    // Step 1: Child Selection
    String? studentId,

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
    @Default(false) bool isMonthlySubscription,
    DateTime? scheduledPickupDatetime,
    DateTime? scheduledDropoffDatetime,
    DateTime? contractStartDate,
    DateTime? contractEndDate,
    List<String>? recurringDays, // ['monday', 'tuesday', etc.]
    String? homePickupTime, // For recurring/subscription
    String? schoolPickupTime,

    // Step 6: Review / Metadata
    String? driverId,
    double? estimatedPrice,
    double? totalEstimatedDistanceKm,
    int? totalEstimatedDurationMinutes,
    String? notes,

    // Current flow state
    @Default(1) int currentStep,
    @Default('draft') String flowStep, // 'draft', 'submitted', 'confirmed'
  }) = _BookingDraftModel;

  factory BookingDraftModel.fromJson(Map<String, dynamic> json) =>
      _$BookingDraftModelFromJson(json);
}
