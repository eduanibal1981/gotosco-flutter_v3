// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gotosco_v3/core/utils/geo_parsing.dart';

part 'driver_request_model.freezed.dart';
part 'driver_request_model.g.dart';

@freezed
abstract class DriverRequest with _$DriverRequest {
  const DriverRequest._();

  const factory DriverRequest({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'parent_id') required String parentId,
    @JsonKey(name: 'driver_id') String? driverId,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'booking_type')
    String? bookingType, // 'one_time', 'recurring'
    @JsonKey(name: 'notes') String? notes,

    // Parent info (from join)
    @JsonKey(name: 'parent_name') String? parentName,
    @JsonKey(name: 'parent_photo') String? parentPhoto,
    @JsonKey(name: 'parent_phone') String? parentPhone,

    // Locations
    @JsonKey(name: 'hometxt_location') String? homeLocation,
    @JsonKey(name: 'schooltxt_location') String? schoolLocation,
    @JsonKey(name: 'homegeo_location') String? homeGeoLocation,
    @JsonKey(name: 'schoolgeo_location') String? schoolGeoLocation,

    // Dates/Times
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'home_pickup_time') String? pickupTime,
    @JsonKey(name: 'recurring_days') @Default([]) List<String> recurringDays,
    @JsonKey(name: 'proposal_price')
    dynamic proposalPrice, // Can be int or double
    // Arrays from View
    @JsonKey(name: 'students_info')
    @Default([])
    List<Map<String, dynamic>> studentsInfo,
    @JsonKey(name: 'schools_info')
    @Default([])
    List<Map<String, dynamic>> schoolsInfo,

    @JsonKey(name: 'is_monthly_subscription')
    @Default(false)
    bool isMonthlySubscription,
    @JsonKey(name: 'is_recurring') @Default(false) bool isRecurring,
    @JsonKey(name: 'is_multi_school') @Default(false) bool isMultiSchool,
    @JsonKey(name: 'school_name')
    String? schoolName, // Single school name if present
  }) = _DriverRequest;

  factory DriverRequest.fromJson(Map<String, dynamic> json) =>
      _$DriverRequestFromJson(json);

  Map<String, dynamic> toLegacyMap() {
    final firstChild = studentsInfo.isNotEmpty
        ? studentsInfo.first
        : <String, dynamic>{};
    final firstSchool = schoolsInfo.isNotEmpty
        ? schoolsInfo.first
        : <String, dynamic>{};

    // Parse geo
    final homeGeoData = parseGeoLocation(homeGeoLocation);
    final schoolGeoData = parseGeoLocation(schoolGeoLocation);

    return {
      'id': id,
      'parent_id': parentId,
      'parent_name': parentName ?? 'Parent',
      'parent_photo': parentPhoto,
      'parent_phone': parentPhone,
      'child_name': firstChild['name'] ?? 'Child',
      // Ensure null safety for primitive types extraction if needed, but legacy code usually handled nulls or expected them
      'child_gender': firstChild['gender'],
      'child_grade': firstChild['grade'],
      'child_age': firstChild['age'],
      'school_name': schoolName ?? (firstSchool['name'] ?? 'School'),
      'booking_type': bookingType,
      'trip_category': (schoolsInfo.isNotEmpty || isMultiSchool)
          ? 'school'
          : 'other',
      'hometxt_location': homeLocation,
      'schooltxt_location': schoolLocation,
      'notes': notes,
      'status': status == 'posted' ? 'open' : status,
      'created_at': createdAt?.toIso8601String(),
      'propsal_price': proposalPrice,
      'schedule_type': isMonthlySubscription
          ? 'Monthly Subscription'
          : (isRecurring ? 'Recurring Trip' : 'One-Time Trip'),
      'start_date': startDate,
      'end_date': endDate,
      'pickup_time': pickupTime,
      'days_of_week': recurringDays.join(', '),
      'home_lat': homeGeoData?['lat'],
      'home_lng': homeGeoData?['lng'],
      'school_lat': schoolGeoData?['lat'],
      'school_lng': schoolGeoData?['lng'],

      // Pass arrays too
      'students_info': studentsInfo,
      'schools_info': schoolsInfo,
      // Pass raw joined data as expected by some widgets if they inspect children array directly
      // But typically widgets use 'students_info' if they are updated?
      // Legacy code was `final children = childrenByBooking[bId] ?? [];`
      // So checking `students_info` in legacy map is good.
    };
  }
}
