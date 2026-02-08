// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parent_booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ParentBooking {

// Core identifiers
 String get id; String get parentId; String? get driverId; String get bookingType; String? get status;// Location text
 String? get hometxtLocation; String? get schooltxtLocation;// Time fields
 String? get homePickupTime; String? get schoolPickupTime;// Pricing
 double? get price; double? get proposalPrice;// Notes
 String? get notes;// Timestamps
 DateTime? get createdAt;// Recurring booking fields
 bool get isRecurring; Map<String, dynamic>? get recurrencePattern; String? get subscriptionStatus; DateTime? get startDate; DateTime? get endDate; List<String>? get recurringDays; bool get isMonthlySubscription;// Geo locations (as text from view)
 String? get homegeoLocationText; String? get schoolgeoLocationText; double? get homeLat; double? get homeLng; double? get schoolLat; double? get schoolLng;// Route ordering
 int? get routegoOrder; int? get routeretOrder;// School reference
 String? get studentId; String? get schoolId; String? get schoolName; List<String>? get schoolIds; bool get isMultiSchool;// Payment & cancellation
 String? get paymentStatus; String? get cancellationReason; DateTime? get cancelledAt; String? get cancellationType; double? get cancellationFee; DateTime? get cancelRequestedAt;// Contract dates
 DateTime? get contractStartDate; DateTime? get contractEndDate; DateTime? get pauseStartDate; DateTime? get pauseEndDate;// Trip category
 String? get tripCategory; bool get isOneTime; DateTime? get scheduledPickupDatetime; DateTime? get scheduledDropoffDatetime;// Custom locations
 String? get customPickupLocationText; String? get customPickupGeoText; String? get customDropoffLocationText; String? get customDropoffGeoText; double? get customPickupLat; double? get customPickupLng; double? get customDropoffLat; double? get customDropoffLng;// Booking flow
 String? get bookingFlowStep; double? get totalEstimatedDistanceKm; int? get totalEstimatedDurationMinutes; bool get isForParent;// ====== ENRICHED FROM VIEW (JOINs) ======
// Driver info (from users table)
 String? get driverName; String? get driverPhoto; String? get driverPhone;// School info (from schools table)
 String? get schoolNameLookup; String? get schoolAddress;// ====== ENRICHED IN DART (children) ======
// These are populated by the repository after fetching from booking_children
 int get kidsCount; List<String> get childNames; List<Map<String, dynamic>> get studentsInfo;
/// Create a copy of ParentBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParentBookingCopyWith<ParentBooking> get copyWith => _$ParentBookingCopyWithImpl<ParentBooking>(this as ParentBooking, _$identity);

  /// Serializes this ParentBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParentBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.status, status) || other.status == status)&&(identical(other.hometxtLocation, hometxtLocation) || other.hometxtLocation == hometxtLocation)&&(identical(other.schooltxtLocation, schooltxtLocation) || other.schooltxtLocation == schooltxtLocation)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.proposalPrice, proposalPrice) || other.proposalPrice == proposalPrice)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.recurrencePattern, recurrencePattern)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.homegeoLocationText, homegeoLocationText) || other.homegeoLocationText == homegeoLocationText)&&(identical(other.schoolgeoLocationText, schoolgeoLocationText) || other.schoolgeoLocationText == schoolgeoLocationText)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.routegoOrder, routegoOrder) || other.routegoOrder == routegoOrder)&&(identical(other.routeretOrder, routeretOrder) || other.routeretOrder == routeretOrder)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&const DeepCollectionEquality().equals(other.schoolIds, schoolIds)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationType, cancellationType) || other.cancellationType == cancellationType)&&(identical(other.cancellationFee, cancellationFee) || other.cancellationFee == cancellationFee)&&(identical(other.cancelRequestedAt, cancelRequestedAt) || other.cancelRequestedAt == cancelRequestedAt)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&(identical(other.pauseStartDate, pauseStartDate) || other.pauseStartDate == pauseStartDate)&&(identical(other.pauseEndDate, pauseEndDate) || other.pauseEndDate == pauseEndDate)&&(identical(other.tripCategory, tripCategory) || other.tripCategory == tripCategory)&&(identical(other.isOneTime, isOneTime) || other.isOneTime == isOneTime)&&(identical(other.scheduledPickupDatetime, scheduledPickupDatetime) || other.scheduledPickupDatetime == scheduledPickupDatetime)&&(identical(other.scheduledDropoffDatetime, scheduledDropoffDatetime) || other.scheduledDropoffDatetime == scheduledDropoffDatetime)&&(identical(other.customPickupLocationText, customPickupLocationText) || other.customPickupLocationText == customPickupLocationText)&&(identical(other.customPickupGeoText, customPickupGeoText) || other.customPickupGeoText == customPickupGeoText)&&(identical(other.customDropoffLocationText, customDropoffLocationText) || other.customDropoffLocationText == customDropoffLocationText)&&(identical(other.customDropoffGeoText, customDropoffGeoText) || other.customDropoffGeoText == customDropoffGeoText)&&(identical(other.customPickupLat, customPickupLat) || other.customPickupLat == customPickupLat)&&(identical(other.customPickupLng, customPickupLng) || other.customPickupLng == customPickupLng)&&(identical(other.customDropoffLat, customDropoffLat) || other.customDropoffLat == customDropoffLat)&&(identical(other.customDropoffLng, customDropoffLng) || other.customDropoffLng == customDropoffLng)&&(identical(other.bookingFlowStep, bookingFlowStep) || other.bookingFlowStep == bookingFlowStep)&&(identical(other.totalEstimatedDistanceKm, totalEstimatedDistanceKm) || other.totalEstimatedDistanceKm == totalEstimatedDistanceKm)&&(identical(other.totalEstimatedDurationMinutes, totalEstimatedDurationMinutes) || other.totalEstimatedDurationMinutes == totalEstimatedDurationMinutes)&&(identical(other.isForParent, isForParent) || other.isForParent == isForParent)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhoto, driverPhoto) || other.driverPhoto == driverPhoto)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone)&&(identical(other.schoolNameLookup, schoolNameLookup) || other.schoolNameLookup == schoolNameLookup)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.kidsCount, kidsCount) || other.kidsCount == kidsCount)&&const DeepCollectionEquality().equals(other.childNames, childNames)&&const DeepCollectionEquality().equals(other.studentsInfo, studentsInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentId,driverId,bookingType,status,hometxtLocation,schooltxtLocation,homePickupTime,schoolPickupTime,price,proposalPrice,notes,createdAt,isRecurring,const DeepCollectionEquality().hash(recurrencePattern),subscriptionStatus,startDate,endDate,const DeepCollectionEquality().hash(recurringDays),isMonthlySubscription,homegeoLocationText,schoolgeoLocationText,homeLat,homeLng,schoolLat,schoolLng,routegoOrder,routeretOrder,studentId,schoolId,schoolName,const DeepCollectionEquality().hash(schoolIds),isMultiSchool,paymentStatus,cancellationReason,cancelledAt,cancellationType,cancellationFee,cancelRequestedAt,contractStartDate,contractEndDate,pauseStartDate,pauseEndDate,tripCategory,isOneTime,scheduledPickupDatetime,scheduledDropoffDatetime,customPickupLocationText,customPickupGeoText,customDropoffLocationText,customDropoffGeoText,customPickupLat,customPickupLng,customDropoffLat,customDropoffLng,bookingFlowStep,totalEstimatedDistanceKm,totalEstimatedDurationMinutes,isForParent,driverName,driverPhoto,driverPhone,schoolNameLookup,schoolAddress,kidsCount,const DeepCollectionEquality().hash(childNames),const DeepCollectionEquality().hash(studentsInfo)]);

@override
String toString() {
  return 'ParentBooking(id: $id, parentId: $parentId, driverId: $driverId, bookingType: $bookingType, status: $status, hometxtLocation: $hometxtLocation, schooltxtLocation: $schooltxtLocation, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, price: $price, proposalPrice: $proposalPrice, notes: $notes, createdAt: $createdAt, isRecurring: $isRecurring, recurrencePattern: $recurrencePattern, subscriptionStatus: $subscriptionStatus, startDate: $startDate, endDate: $endDate, recurringDays: $recurringDays, isMonthlySubscription: $isMonthlySubscription, homegeoLocationText: $homegeoLocationText, schoolgeoLocationText: $schoolgeoLocationText, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, routegoOrder: $routegoOrder, routeretOrder: $routeretOrder, studentId: $studentId, schoolId: $schoolId, schoolName: $schoolName, schoolIds: $schoolIds, isMultiSchool: $isMultiSchool, paymentStatus: $paymentStatus, cancellationReason: $cancellationReason, cancelledAt: $cancelledAt, cancellationType: $cancellationType, cancellationFee: $cancellationFee, cancelRequestedAt: $cancelRequestedAt, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, pauseStartDate: $pauseStartDate, pauseEndDate: $pauseEndDate, tripCategory: $tripCategory, isOneTime: $isOneTime, scheduledPickupDatetime: $scheduledPickupDatetime, scheduledDropoffDatetime: $scheduledDropoffDatetime, customPickupLocationText: $customPickupLocationText, customPickupGeoText: $customPickupGeoText, customDropoffLocationText: $customDropoffLocationText, customDropoffGeoText: $customDropoffGeoText, customPickupLat: $customPickupLat, customPickupLng: $customPickupLng, customDropoffLat: $customDropoffLat, customDropoffLng: $customDropoffLng, bookingFlowStep: $bookingFlowStep, totalEstimatedDistanceKm: $totalEstimatedDistanceKm, totalEstimatedDurationMinutes: $totalEstimatedDurationMinutes, isForParent: $isForParent, driverName: $driverName, driverPhoto: $driverPhoto, driverPhone: $driverPhone, schoolNameLookup: $schoolNameLookup, schoolAddress: $schoolAddress, kidsCount: $kidsCount, childNames: $childNames, studentsInfo: $studentsInfo)';
}


}

/// @nodoc
abstract mixin class $ParentBookingCopyWith<$Res>  {
  factory $ParentBookingCopyWith(ParentBooking value, $Res Function(ParentBooking) _then) = _$ParentBookingCopyWithImpl;
@useResult
$Res call({
 String id, String parentId, String? driverId, String bookingType, String? status, String? hometxtLocation, String? schooltxtLocation, String? homePickupTime, String? schoolPickupTime, double? price, double? proposalPrice, String? notes, DateTime? createdAt, bool isRecurring, Map<String, dynamic>? recurrencePattern, String? subscriptionStatus, DateTime? startDate, DateTime? endDate, List<String>? recurringDays, bool isMonthlySubscription, String? homegeoLocationText, String? schoolgeoLocationText, double? homeLat, double? homeLng, double? schoolLat, double? schoolLng, int? routegoOrder, int? routeretOrder, String? studentId, String? schoolId, String? schoolName, List<String>? schoolIds, bool isMultiSchool, String? paymentStatus, String? cancellationReason, DateTime? cancelledAt, String? cancellationType, double? cancellationFee, DateTime? cancelRequestedAt, DateTime? contractStartDate, DateTime? contractEndDate, DateTime? pauseStartDate, DateTime? pauseEndDate, String? tripCategory, bool isOneTime, DateTime? scheduledPickupDatetime, DateTime? scheduledDropoffDatetime, String? customPickupLocationText, String? customPickupGeoText, String? customDropoffLocationText, String? customDropoffGeoText, double? customPickupLat, double? customPickupLng, double? customDropoffLat, double? customDropoffLng, String? bookingFlowStep, double? totalEstimatedDistanceKm, int? totalEstimatedDurationMinutes, bool isForParent, String? driverName, String? driverPhoto, String? driverPhone, String? schoolNameLookup, String? schoolAddress, int kidsCount, List<String> childNames, List<Map<String, dynamic>> studentsInfo
});




}
/// @nodoc
class _$ParentBookingCopyWithImpl<$Res>
    implements $ParentBookingCopyWith<$Res> {
  _$ParentBookingCopyWithImpl(this._self, this._then);

  final ParentBooking _self;
  final $Res Function(ParentBooking) _then;

/// Create a copy of ParentBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = null,Object? driverId = freezed,Object? bookingType = null,Object? status = freezed,Object? hometxtLocation = freezed,Object? schooltxtLocation = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? price = freezed,Object? proposalPrice = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? isRecurring = null,Object? recurrencePattern = freezed,Object? subscriptionStatus = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? recurringDays = freezed,Object? isMonthlySubscription = null,Object? homegeoLocationText = freezed,Object? schoolgeoLocationText = freezed,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? routegoOrder = freezed,Object? routeretOrder = freezed,Object? studentId = freezed,Object? schoolId = freezed,Object? schoolName = freezed,Object? schoolIds = freezed,Object? isMultiSchool = null,Object? paymentStatus = freezed,Object? cancellationReason = freezed,Object? cancelledAt = freezed,Object? cancellationType = freezed,Object? cancellationFee = freezed,Object? cancelRequestedAt = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? pauseStartDate = freezed,Object? pauseEndDate = freezed,Object? tripCategory = freezed,Object? isOneTime = null,Object? scheduledPickupDatetime = freezed,Object? scheduledDropoffDatetime = freezed,Object? customPickupLocationText = freezed,Object? customPickupGeoText = freezed,Object? customDropoffLocationText = freezed,Object? customDropoffGeoText = freezed,Object? customPickupLat = freezed,Object? customPickupLng = freezed,Object? customDropoffLat = freezed,Object? customDropoffLng = freezed,Object? bookingFlowStep = freezed,Object? totalEstimatedDistanceKm = freezed,Object? totalEstimatedDurationMinutes = freezed,Object? isForParent = null,Object? driverName = freezed,Object? driverPhoto = freezed,Object? driverPhone = freezed,Object? schoolNameLookup = freezed,Object? schoolAddress = freezed,Object? kidsCount = null,Object? childNames = null,Object? studentsInfo = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,hometxtLocation: freezed == hometxtLocation ? _self.hometxtLocation : hometxtLocation // ignore: cast_nullable_to_non_nullable
as String?,schooltxtLocation: freezed == schooltxtLocation ? _self.schooltxtLocation : schooltxtLocation // ignore: cast_nullable_to_non_nullable
as String?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrencePattern: freezed == recurrencePattern ? _self.recurrencePattern : recurrencePattern // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringDays: freezed == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>?,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,homegeoLocationText: freezed == homegeoLocationText ? _self.homegeoLocationText : homegeoLocationText // ignore: cast_nullable_to_non_nullable
as String?,schoolgeoLocationText: freezed == schoolgeoLocationText ? _self.schoolgeoLocationText : schoolgeoLocationText // ignore: cast_nullable_to_non_nullable
as String?,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,routegoOrder: freezed == routegoOrder ? _self.routegoOrder : routegoOrder // ignore: cast_nullable_to_non_nullable
as int?,routeretOrder: freezed == routeretOrder ? _self.routeretOrder : routeretOrder // ignore: cast_nullable_to_non_nullable
as int?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolIds: freezed == schoolIds ? _self.schoolIds : schoolIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationType: freezed == cancellationType ? _self.cancellationType : cancellationType // ignore: cast_nullable_to_non_nullable
as String?,cancellationFee: freezed == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double?,cancelRequestedAt: freezed == cancelRequestedAt ? _self.cancelRequestedAt : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pauseStartDate: freezed == pauseStartDate ? _self.pauseStartDate : pauseStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pauseEndDate: freezed == pauseEndDate ? _self.pauseEndDate : pauseEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tripCategory: freezed == tripCategory ? _self.tripCategory : tripCategory // ignore: cast_nullable_to_non_nullable
as String?,isOneTime: null == isOneTime ? _self.isOneTime : isOneTime // ignore: cast_nullable_to_non_nullable
as bool,scheduledPickupDatetime: freezed == scheduledPickupDatetime ? _self.scheduledPickupDatetime : scheduledPickupDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledDropoffDatetime: freezed == scheduledDropoffDatetime ? _self.scheduledDropoffDatetime : scheduledDropoffDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,customPickupLocationText: freezed == customPickupLocationText ? _self.customPickupLocationText : customPickupLocationText // ignore: cast_nullable_to_non_nullable
as String?,customPickupGeoText: freezed == customPickupGeoText ? _self.customPickupGeoText : customPickupGeoText // ignore: cast_nullable_to_non_nullable
as String?,customDropoffLocationText: freezed == customDropoffLocationText ? _self.customDropoffLocationText : customDropoffLocationText // ignore: cast_nullable_to_non_nullable
as String?,customDropoffGeoText: freezed == customDropoffGeoText ? _self.customDropoffGeoText : customDropoffGeoText // ignore: cast_nullable_to_non_nullable
as String?,customPickupLat: freezed == customPickupLat ? _self.customPickupLat : customPickupLat // ignore: cast_nullable_to_non_nullable
as double?,customPickupLng: freezed == customPickupLng ? _self.customPickupLng : customPickupLng // ignore: cast_nullable_to_non_nullable
as double?,customDropoffLat: freezed == customDropoffLat ? _self.customDropoffLat : customDropoffLat // ignore: cast_nullable_to_non_nullable
as double?,customDropoffLng: freezed == customDropoffLng ? _self.customDropoffLng : customDropoffLng // ignore: cast_nullable_to_non_nullable
as double?,bookingFlowStep: freezed == bookingFlowStep ? _self.bookingFlowStep : bookingFlowStep // ignore: cast_nullable_to_non_nullable
as String?,totalEstimatedDistanceKm: freezed == totalEstimatedDistanceKm ? _self.totalEstimatedDistanceKm : totalEstimatedDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDurationMinutes: freezed == totalEstimatedDurationMinutes ? _self.totalEstimatedDurationMinutes : totalEstimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,isForParent: null == isForParent ? _self.isForParent : isForParent // ignore: cast_nullable_to_non_nullable
as bool,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhoto: freezed == driverPhoto ? _self.driverPhoto : driverPhoto // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,schoolNameLookup: freezed == schoolNameLookup ? _self.schoolNameLookup : schoolNameLookup // ignore: cast_nullable_to_non_nullable
as String?,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,kidsCount: null == kidsCount ? _self.kidsCount : kidsCount // ignore: cast_nullable_to_non_nullable
as int,childNames: null == childNames ? _self.childNames : childNames // ignore: cast_nullable_to_non_nullable
as List<String>,studentsInfo: null == studentsInfo ? _self.studentsInfo : studentsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParentBooking].
extension ParentBookingPatterns on ParentBooking {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParentBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParentBooking() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParentBooking value)  $default,){
final _that = this;
switch (_that) {
case _ParentBooking():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParentBooking value)?  $default,){
final _that = this;
switch (_that) {
case _ParentBooking() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parentId,  String? driverId,  String bookingType,  String? status,  String? hometxtLocation,  String? schooltxtLocation,  String? homePickupTime,  String? schoolPickupTime,  double? price,  double? proposalPrice,  String? notes,  DateTime? createdAt,  bool isRecurring,  Map<String, dynamic>? recurrencePattern,  String? subscriptionStatus,  DateTime? startDate,  DateTime? endDate,  List<String>? recurringDays,  bool isMonthlySubscription,  String? homegeoLocationText,  String? schoolgeoLocationText,  double? homeLat,  double? homeLng,  double? schoolLat,  double? schoolLng,  int? routegoOrder,  int? routeretOrder,  String? studentId,  String? schoolId,  String? schoolName,  List<String>? schoolIds,  bool isMultiSchool,  String? paymentStatus,  String? cancellationReason,  DateTime? cancelledAt,  String? cancellationType,  double? cancellationFee,  DateTime? cancelRequestedAt,  DateTime? contractStartDate,  DateTime? contractEndDate,  DateTime? pauseStartDate,  DateTime? pauseEndDate,  String? tripCategory,  bool isOneTime,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  String? customPickupLocationText,  String? customPickupGeoText,  String? customDropoffLocationText,  String? customDropoffGeoText,  double? customPickupLat,  double? customPickupLng,  double? customDropoffLat,  double? customDropoffLng,  String? bookingFlowStep,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  bool isForParent,  String? driverName,  String? driverPhoto,  String? driverPhone,  String? schoolNameLookup,  String? schoolAddress,  int kidsCount,  List<String> childNames,  List<Map<String, dynamic>> studentsInfo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParentBooking() when $default != null:
return $default(_that.id,_that.parentId,_that.driverId,_that.bookingType,_that.status,_that.hometxtLocation,_that.schooltxtLocation,_that.homePickupTime,_that.schoolPickupTime,_that.price,_that.proposalPrice,_that.notes,_that.createdAt,_that.isRecurring,_that.recurrencePattern,_that.subscriptionStatus,_that.startDate,_that.endDate,_that.recurringDays,_that.isMonthlySubscription,_that.homegeoLocationText,_that.schoolgeoLocationText,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.routegoOrder,_that.routeretOrder,_that.studentId,_that.schoolId,_that.schoolName,_that.schoolIds,_that.isMultiSchool,_that.paymentStatus,_that.cancellationReason,_that.cancelledAt,_that.cancellationType,_that.cancellationFee,_that.cancelRequestedAt,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.tripCategory,_that.isOneTime,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.customPickupLocationText,_that.customPickupGeoText,_that.customDropoffLocationText,_that.customDropoffGeoText,_that.customPickupLat,_that.customPickupLng,_that.customDropoffLat,_that.customDropoffLng,_that.bookingFlowStep,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.isForParent,_that.driverName,_that.driverPhoto,_that.driverPhone,_that.schoolNameLookup,_that.schoolAddress,_that.kidsCount,_that.childNames,_that.studentsInfo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parentId,  String? driverId,  String bookingType,  String? status,  String? hometxtLocation,  String? schooltxtLocation,  String? homePickupTime,  String? schoolPickupTime,  double? price,  double? proposalPrice,  String? notes,  DateTime? createdAt,  bool isRecurring,  Map<String, dynamic>? recurrencePattern,  String? subscriptionStatus,  DateTime? startDate,  DateTime? endDate,  List<String>? recurringDays,  bool isMonthlySubscription,  String? homegeoLocationText,  String? schoolgeoLocationText,  double? homeLat,  double? homeLng,  double? schoolLat,  double? schoolLng,  int? routegoOrder,  int? routeretOrder,  String? studentId,  String? schoolId,  String? schoolName,  List<String>? schoolIds,  bool isMultiSchool,  String? paymentStatus,  String? cancellationReason,  DateTime? cancelledAt,  String? cancellationType,  double? cancellationFee,  DateTime? cancelRequestedAt,  DateTime? contractStartDate,  DateTime? contractEndDate,  DateTime? pauseStartDate,  DateTime? pauseEndDate,  String? tripCategory,  bool isOneTime,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  String? customPickupLocationText,  String? customPickupGeoText,  String? customDropoffLocationText,  String? customDropoffGeoText,  double? customPickupLat,  double? customPickupLng,  double? customDropoffLat,  double? customDropoffLng,  String? bookingFlowStep,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  bool isForParent,  String? driverName,  String? driverPhoto,  String? driverPhone,  String? schoolNameLookup,  String? schoolAddress,  int kidsCount,  List<String> childNames,  List<Map<String, dynamic>> studentsInfo)  $default,) {final _that = this;
switch (_that) {
case _ParentBooking():
return $default(_that.id,_that.parentId,_that.driverId,_that.bookingType,_that.status,_that.hometxtLocation,_that.schooltxtLocation,_that.homePickupTime,_that.schoolPickupTime,_that.price,_that.proposalPrice,_that.notes,_that.createdAt,_that.isRecurring,_that.recurrencePattern,_that.subscriptionStatus,_that.startDate,_that.endDate,_that.recurringDays,_that.isMonthlySubscription,_that.homegeoLocationText,_that.schoolgeoLocationText,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.routegoOrder,_that.routeretOrder,_that.studentId,_that.schoolId,_that.schoolName,_that.schoolIds,_that.isMultiSchool,_that.paymentStatus,_that.cancellationReason,_that.cancelledAt,_that.cancellationType,_that.cancellationFee,_that.cancelRequestedAt,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.tripCategory,_that.isOneTime,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.customPickupLocationText,_that.customPickupGeoText,_that.customDropoffLocationText,_that.customDropoffGeoText,_that.customPickupLat,_that.customPickupLng,_that.customDropoffLat,_that.customDropoffLng,_that.bookingFlowStep,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.isForParent,_that.driverName,_that.driverPhoto,_that.driverPhone,_that.schoolNameLookup,_that.schoolAddress,_that.kidsCount,_that.childNames,_that.studentsInfo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parentId,  String? driverId,  String bookingType,  String? status,  String? hometxtLocation,  String? schooltxtLocation,  String? homePickupTime,  String? schoolPickupTime,  double? price,  double? proposalPrice,  String? notes,  DateTime? createdAt,  bool isRecurring,  Map<String, dynamic>? recurrencePattern,  String? subscriptionStatus,  DateTime? startDate,  DateTime? endDate,  List<String>? recurringDays,  bool isMonthlySubscription,  String? homegeoLocationText,  String? schoolgeoLocationText,  double? homeLat,  double? homeLng,  double? schoolLat,  double? schoolLng,  int? routegoOrder,  int? routeretOrder,  String? studentId,  String? schoolId,  String? schoolName,  List<String>? schoolIds,  bool isMultiSchool,  String? paymentStatus,  String? cancellationReason,  DateTime? cancelledAt,  String? cancellationType,  double? cancellationFee,  DateTime? cancelRequestedAt,  DateTime? contractStartDate,  DateTime? contractEndDate,  DateTime? pauseStartDate,  DateTime? pauseEndDate,  String? tripCategory,  bool isOneTime,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  String? customPickupLocationText,  String? customPickupGeoText,  String? customDropoffLocationText,  String? customDropoffGeoText,  double? customPickupLat,  double? customPickupLng,  double? customDropoffLat,  double? customDropoffLng,  String? bookingFlowStep,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  bool isForParent,  String? driverName,  String? driverPhoto,  String? driverPhone,  String? schoolNameLookup,  String? schoolAddress,  int kidsCount,  List<String> childNames,  List<Map<String, dynamic>> studentsInfo)?  $default,) {final _that = this;
switch (_that) {
case _ParentBooking() when $default != null:
return $default(_that.id,_that.parentId,_that.driverId,_that.bookingType,_that.status,_that.hometxtLocation,_that.schooltxtLocation,_that.homePickupTime,_that.schoolPickupTime,_that.price,_that.proposalPrice,_that.notes,_that.createdAt,_that.isRecurring,_that.recurrencePattern,_that.subscriptionStatus,_that.startDate,_that.endDate,_that.recurringDays,_that.isMonthlySubscription,_that.homegeoLocationText,_that.schoolgeoLocationText,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.routegoOrder,_that.routeretOrder,_that.studentId,_that.schoolId,_that.schoolName,_that.schoolIds,_that.isMultiSchool,_that.paymentStatus,_that.cancellationReason,_that.cancelledAt,_that.cancellationType,_that.cancellationFee,_that.cancelRequestedAt,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.tripCategory,_that.isOneTime,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.customPickupLocationText,_that.customPickupGeoText,_that.customDropoffLocationText,_that.customDropoffGeoText,_that.customPickupLat,_that.customPickupLng,_that.customDropoffLat,_that.customDropoffLng,_that.bookingFlowStep,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.isForParent,_that.driverName,_that.driverPhoto,_that.driverPhone,_that.schoolNameLookup,_that.schoolAddress,_that.kidsCount,_that.childNames,_that.studentsInfo);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ParentBooking extends ParentBooking {
  const _ParentBooking({required this.id, required this.parentId, this.driverId, required this.bookingType, this.status, this.hometxtLocation, this.schooltxtLocation, this.homePickupTime, this.schoolPickupTime, this.price, this.proposalPrice, this.notes, this.createdAt, this.isRecurring = false, final  Map<String, dynamic>? recurrencePattern, this.subscriptionStatus, this.startDate, this.endDate, final  List<String>? recurringDays, this.isMonthlySubscription = false, this.homegeoLocationText, this.schoolgeoLocationText, this.homeLat, this.homeLng, this.schoolLat, this.schoolLng, this.routegoOrder, this.routeretOrder, this.studentId, this.schoolId, this.schoolName, final  List<String>? schoolIds, this.isMultiSchool = false, this.paymentStatus, this.cancellationReason, this.cancelledAt, this.cancellationType, this.cancellationFee, this.cancelRequestedAt, this.contractStartDate, this.contractEndDate, this.pauseStartDate, this.pauseEndDate, this.tripCategory, this.isOneTime = false, this.scheduledPickupDatetime, this.scheduledDropoffDatetime, this.customPickupLocationText, this.customPickupGeoText, this.customDropoffLocationText, this.customDropoffGeoText, this.customPickupLat, this.customPickupLng, this.customDropoffLat, this.customDropoffLng, this.bookingFlowStep, this.totalEstimatedDistanceKm, this.totalEstimatedDurationMinutes, this.isForParent = false, this.driverName, this.driverPhoto, this.driverPhone, this.schoolNameLookup, this.schoolAddress, this.kidsCount = 0, final  List<String> childNames = const [], final  List<Map<String, dynamic>> studentsInfo = const []}): _recurrencePattern = recurrencePattern,_recurringDays = recurringDays,_schoolIds = schoolIds,_childNames = childNames,_studentsInfo = studentsInfo,super._();
  factory _ParentBooking.fromJson(Map<String, dynamic> json) => _$ParentBookingFromJson(json);

// Core identifiers
@override final  String id;
@override final  String parentId;
@override final  String? driverId;
@override final  String bookingType;
@override final  String? status;
// Location text
@override final  String? hometxtLocation;
@override final  String? schooltxtLocation;
// Time fields
@override final  String? homePickupTime;
@override final  String? schoolPickupTime;
// Pricing
@override final  double? price;
@override final  double? proposalPrice;
// Notes
@override final  String? notes;
// Timestamps
@override final  DateTime? createdAt;
// Recurring booking fields
@override@JsonKey() final  bool isRecurring;
 final  Map<String, dynamic>? _recurrencePattern;
@override Map<String, dynamic>? get recurrencePattern {
  final value = _recurrencePattern;
  if (value == null) return null;
  if (_recurrencePattern is EqualUnmodifiableMapView) return _recurrencePattern;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? subscriptionStatus;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
 final  List<String>? _recurringDays;
@override List<String>? get recurringDays {
  final value = _recurringDays;
  if (value == null) return null;
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isMonthlySubscription;
// Geo locations (as text from view)
@override final  String? homegeoLocationText;
@override final  String? schoolgeoLocationText;
@override final  double? homeLat;
@override final  double? homeLng;
@override final  double? schoolLat;
@override final  double? schoolLng;
// Route ordering
@override final  int? routegoOrder;
@override final  int? routeretOrder;
// School reference
@override final  String? studentId;
@override final  String? schoolId;
@override final  String? schoolName;
 final  List<String>? _schoolIds;
@override List<String>? get schoolIds {
  final value = _schoolIds;
  if (value == null) return null;
  if (_schoolIds is EqualUnmodifiableListView) return _schoolIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isMultiSchool;
// Payment & cancellation
@override final  String? paymentStatus;
@override final  String? cancellationReason;
@override final  DateTime? cancelledAt;
@override final  String? cancellationType;
@override final  double? cancellationFee;
@override final  DateTime? cancelRequestedAt;
// Contract dates
@override final  DateTime? contractStartDate;
@override final  DateTime? contractEndDate;
@override final  DateTime? pauseStartDate;
@override final  DateTime? pauseEndDate;
// Trip category
@override final  String? tripCategory;
@override@JsonKey() final  bool isOneTime;
@override final  DateTime? scheduledPickupDatetime;
@override final  DateTime? scheduledDropoffDatetime;
// Custom locations
@override final  String? customPickupLocationText;
@override final  String? customPickupGeoText;
@override final  String? customDropoffLocationText;
@override final  String? customDropoffGeoText;
@override final  double? customPickupLat;
@override final  double? customPickupLng;
@override final  double? customDropoffLat;
@override final  double? customDropoffLng;
// Booking flow
@override final  String? bookingFlowStep;
@override final  double? totalEstimatedDistanceKm;
@override final  int? totalEstimatedDurationMinutes;
@override@JsonKey() final  bool isForParent;
// ====== ENRICHED FROM VIEW (JOINs) ======
// Driver info (from users table)
@override final  String? driverName;
@override final  String? driverPhoto;
@override final  String? driverPhone;
// School info (from schools table)
@override final  String? schoolNameLookup;
@override final  String? schoolAddress;
// ====== ENRICHED IN DART (children) ======
// These are populated by the repository after fetching from booking_children
@override@JsonKey() final  int kidsCount;
 final  List<String> _childNames;
@override@JsonKey() List<String> get childNames {
  if (_childNames is EqualUnmodifiableListView) return _childNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childNames);
}

 final  List<Map<String, dynamic>> _studentsInfo;
@override@JsonKey() List<Map<String, dynamic>> get studentsInfo {
  if (_studentsInfo is EqualUnmodifiableListView) return _studentsInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_studentsInfo);
}


/// Create a copy of ParentBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParentBookingCopyWith<_ParentBooking> get copyWith => __$ParentBookingCopyWithImpl<_ParentBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ParentBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParentBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.status, status) || other.status == status)&&(identical(other.hometxtLocation, hometxtLocation) || other.hometxtLocation == hometxtLocation)&&(identical(other.schooltxtLocation, schooltxtLocation) || other.schooltxtLocation == schooltxtLocation)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.price, price) || other.price == price)&&(identical(other.proposalPrice, proposalPrice) || other.proposalPrice == proposalPrice)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._recurrencePattern, _recurrencePattern)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.homegeoLocationText, homegeoLocationText) || other.homegeoLocationText == homegeoLocationText)&&(identical(other.schoolgeoLocationText, schoolgeoLocationText) || other.schoolgeoLocationText == schoolgeoLocationText)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.routegoOrder, routegoOrder) || other.routegoOrder == routegoOrder)&&(identical(other.routeretOrder, routeretOrder) || other.routeretOrder == routeretOrder)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&const DeepCollectionEquality().equals(other._schoolIds, _schoolIds)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationType, cancellationType) || other.cancellationType == cancellationType)&&(identical(other.cancellationFee, cancellationFee) || other.cancellationFee == cancellationFee)&&(identical(other.cancelRequestedAt, cancelRequestedAt) || other.cancelRequestedAt == cancelRequestedAt)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&(identical(other.pauseStartDate, pauseStartDate) || other.pauseStartDate == pauseStartDate)&&(identical(other.pauseEndDate, pauseEndDate) || other.pauseEndDate == pauseEndDate)&&(identical(other.tripCategory, tripCategory) || other.tripCategory == tripCategory)&&(identical(other.isOneTime, isOneTime) || other.isOneTime == isOneTime)&&(identical(other.scheduledPickupDatetime, scheduledPickupDatetime) || other.scheduledPickupDatetime == scheduledPickupDatetime)&&(identical(other.scheduledDropoffDatetime, scheduledDropoffDatetime) || other.scheduledDropoffDatetime == scheduledDropoffDatetime)&&(identical(other.customPickupLocationText, customPickupLocationText) || other.customPickupLocationText == customPickupLocationText)&&(identical(other.customPickupGeoText, customPickupGeoText) || other.customPickupGeoText == customPickupGeoText)&&(identical(other.customDropoffLocationText, customDropoffLocationText) || other.customDropoffLocationText == customDropoffLocationText)&&(identical(other.customDropoffGeoText, customDropoffGeoText) || other.customDropoffGeoText == customDropoffGeoText)&&(identical(other.customPickupLat, customPickupLat) || other.customPickupLat == customPickupLat)&&(identical(other.customPickupLng, customPickupLng) || other.customPickupLng == customPickupLng)&&(identical(other.customDropoffLat, customDropoffLat) || other.customDropoffLat == customDropoffLat)&&(identical(other.customDropoffLng, customDropoffLng) || other.customDropoffLng == customDropoffLng)&&(identical(other.bookingFlowStep, bookingFlowStep) || other.bookingFlowStep == bookingFlowStep)&&(identical(other.totalEstimatedDistanceKm, totalEstimatedDistanceKm) || other.totalEstimatedDistanceKm == totalEstimatedDistanceKm)&&(identical(other.totalEstimatedDurationMinutes, totalEstimatedDurationMinutes) || other.totalEstimatedDurationMinutes == totalEstimatedDurationMinutes)&&(identical(other.isForParent, isForParent) || other.isForParent == isForParent)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhoto, driverPhoto) || other.driverPhoto == driverPhoto)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone)&&(identical(other.schoolNameLookup, schoolNameLookup) || other.schoolNameLookup == schoolNameLookup)&&(identical(other.schoolAddress, schoolAddress) || other.schoolAddress == schoolAddress)&&(identical(other.kidsCount, kidsCount) || other.kidsCount == kidsCount)&&const DeepCollectionEquality().equals(other._childNames, _childNames)&&const DeepCollectionEquality().equals(other._studentsInfo, _studentsInfo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentId,driverId,bookingType,status,hometxtLocation,schooltxtLocation,homePickupTime,schoolPickupTime,price,proposalPrice,notes,createdAt,isRecurring,const DeepCollectionEquality().hash(_recurrencePattern),subscriptionStatus,startDate,endDate,const DeepCollectionEquality().hash(_recurringDays),isMonthlySubscription,homegeoLocationText,schoolgeoLocationText,homeLat,homeLng,schoolLat,schoolLng,routegoOrder,routeretOrder,studentId,schoolId,schoolName,const DeepCollectionEquality().hash(_schoolIds),isMultiSchool,paymentStatus,cancellationReason,cancelledAt,cancellationType,cancellationFee,cancelRequestedAt,contractStartDate,contractEndDate,pauseStartDate,pauseEndDate,tripCategory,isOneTime,scheduledPickupDatetime,scheduledDropoffDatetime,customPickupLocationText,customPickupGeoText,customDropoffLocationText,customDropoffGeoText,customPickupLat,customPickupLng,customDropoffLat,customDropoffLng,bookingFlowStep,totalEstimatedDistanceKm,totalEstimatedDurationMinutes,isForParent,driverName,driverPhoto,driverPhone,schoolNameLookup,schoolAddress,kidsCount,const DeepCollectionEquality().hash(_childNames),const DeepCollectionEquality().hash(_studentsInfo)]);

@override
String toString() {
  return 'ParentBooking(id: $id, parentId: $parentId, driverId: $driverId, bookingType: $bookingType, status: $status, hometxtLocation: $hometxtLocation, schooltxtLocation: $schooltxtLocation, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, price: $price, proposalPrice: $proposalPrice, notes: $notes, createdAt: $createdAt, isRecurring: $isRecurring, recurrencePattern: $recurrencePattern, subscriptionStatus: $subscriptionStatus, startDate: $startDate, endDate: $endDate, recurringDays: $recurringDays, isMonthlySubscription: $isMonthlySubscription, homegeoLocationText: $homegeoLocationText, schoolgeoLocationText: $schoolgeoLocationText, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, routegoOrder: $routegoOrder, routeretOrder: $routeretOrder, studentId: $studentId, schoolId: $schoolId, schoolName: $schoolName, schoolIds: $schoolIds, isMultiSchool: $isMultiSchool, paymentStatus: $paymentStatus, cancellationReason: $cancellationReason, cancelledAt: $cancelledAt, cancellationType: $cancellationType, cancellationFee: $cancellationFee, cancelRequestedAt: $cancelRequestedAt, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, pauseStartDate: $pauseStartDate, pauseEndDate: $pauseEndDate, tripCategory: $tripCategory, isOneTime: $isOneTime, scheduledPickupDatetime: $scheduledPickupDatetime, scheduledDropoffDatetime: $scheduledDropoffDatetime, customPickupLocationText: $customPickupLocationText, customPickupGeoText: $customPickupGeoText, customDropoffLocationText: $customDropoffLocationText, customDropoffGeoText: $customDropoffGeoText, customPickupLat: $customPickupLat, customPickupLng: $customPickupLng, customDropoffLat: $customDropoffLat, customDropoffLng: $customDropoffLng, bookingFlowStep: $bookingFlowStep, totalEstimatedDistanceKm: $totalEstimatedDistanceKm, totalEstimatedDurationMinutes: $totalEstimatedDurationMinutes, isForParent: $isForParent, driverName: $driverName, driverPhoto: $driverPhoto, driverPhone: $driverPhone, schoolNameLookup: $schoolNameLookup, schoolAddress: $schoolAddress, kidsCount: $kidsCount, childNames: $childNames, studentsInfo: $studentsInfo)';
}


}

/// @nodoc
abstract mixin class _$ParentBookingCopyWith<$Res> implements $ParentBookingCopyWith<$Res> {
  factory _$ParentBookingCopyWith(_ParentBooking value, $Res Function(_ParentBooking) _then) = __$ParentBookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String parentId, String? driverId, String bookingType, String? status, String? hometxtLocation, String? schooltxtLocation, String? homePickupTime, String? schoolPickupTime, double? price, double? proposalPrice, String? notes, DateTime? createdAt, bool isRecurring, Map<String, dynamic>? recurrencePattern, String? subscriptionStatus, DateTime? startDate, DateTime? endDate, List<String>? recurringDays, bool isMonthlySubscription, String? homegeoLocationText, String? schoolgeoLocationText, double? homeLat, double? homeLng, double? schoolLat, double? schoolLng, int? routegoOrder, int? routeretOrder, String? studentId, String? schoolId, String? schoolName, List<String>? schoolIds, bool isMultiSchool, String? paymentStatus, String? cancellationReason, DateTime? cancelledAt, String? cancellationType, double? cancellationFee, DateTime? cancelRequestedAt, DateTime? contractStartDate, DateTime? contractEndDate, DateTime? pauseStartDate, DateTime? pauseEndDate, String? tripCategory, bool isOneTime, DateTime? scheduledPickupDatetime, DateTime? scheduledDropoffDatetime, String? customPickupLocationText, String? customPickupGeoText, String? customDropoffLocationText, String? customDropoffGeoText, double? customPickupLat, double? customPickupLng, double? customDropoffLat, double? customDropoffLng, String? bookingFlowStep, double? totalEstimatedDistanceKm, int? totalEstimatedDurationMinutes, bool isForParent, String? driverName, String? driverPhoto, String? driverPhone, String? schoolNameLookup, String? schoolAddress, int kidsCount, List<String> childNames, List<Map<String, dynamic>> studentsInfo
});




}
/// @nodoc
class __$ParentBookingCopyWithImpl<$Res>
    implements _$ParentBookingCopyWith<$Res> {
  __$ParentBookingCopyWithImpl(this._self, this._then);

  final _ParentBooking _self;
  final $Res Function(_ParentBooking) _then;

/// Create a copy of ParentBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = null,Object? driverId = freezed,Object? bookingType = null,Object? status = freezed,Object? hometxtLocation = freezed,Object? schooltxtLocation = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? price = freezed,Object? proposalPrice = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? isRecurring = null,Object? recurrencePattern = freezed,Object? subscriptionStatus = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? recurringDays = freezed,Object? isMonthlySubscription = null,Object? homegeoLocationText = freezed,Object? schoolgeoLocationText = freezed,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? routegoOrder = freezed,Object? routeretOrder = freezed,Object? studentId = freezed,Object? schoolId = freezed,Object? schoolName = freezed,Object? schoolIds = freezed,Object? isMultiSchool = null,Object? paymentStatus = freezed,Object? cancellationReason = freezed,Object? cancelledAt = freezed,Object? cancellationType = freezed,Object? cancellationFee = freezed,Object? cancelRequestedAt = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? pauseStartDate = freezed,Object? pauseEndDate = freezed,Object? tripCategory = freezed,Object? isOneTime = null,Object? scheduledPickupDatetime = freezed,Object? scheduledDropoffDatetime = freezed,Object? customPickupLocationText = freezed,Object? customPickupGeoText = freezed,Object? customDropoffLocationText = freezed,Object? customDropoffGeoText = freezed,Object? customPickupLat = freezed,Object? customPickupLng = freezed,Object? customDropoffLat = freezed,Object? customDropoffLng = freezed,Object? bookingFlowStep = freezed,Object? totalEstimatedDistanceKm = freezed,Object? totalEstimatedDurationMinutes = freezed,Object? isForParent = null,Object? driverName = freezed,Object? driverPhoto = freezed,Object? driverPhone = freezed,Object? schoolNameLookup = freezed,Object? schoolAddress = freezed,Object? kidsCount = null,Object? childNames = null,Object? studentsInfo = null,}) {
  return _then(_ParentBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,hometxtLocation: freezed == hometxtLocation ? _self.hometxtLocation : hometxtLocation // ignore: cast_nullable_to_non_nullable
as String?,schooltxtLocation: freezed == schooltxtLocation ? _self.schooltxtLocation : schooltxtLocation // ignore: cast_nullable_to_non_nullable
as String?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double?,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as double?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurrencePattern: freezed == recurrencePattern ? _self._recurrencePattern : recurrencePattern // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringDays: freezed == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>?,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,homegeoLocationText: freezed == homegeoLocationText ? _self.homegeoLocationText : homegeoLocationText // ignore: cast_nullable_to_non_nullable
as String?,schoolgeoLocationText: freezed == schoolgeoLocationText ? _self.schoolgeoLocationText : schoolgeoLocationText // ignore: cast_nullable_to_non_nullable
as String?,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,routegoOrder: freezed == routegoOrder ? _self.routegoOrder : routegoOrder // ignore: cast_nullable_to_non_nullable
as int?,routeretOrder: freezed == routeretOrder ? _self.routeretOrder : routeretOrder // ignore: cast_nullable_to_non_nullable
as int?,studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,schoolIds: freezed == schoolIds ? _self._schoolIds : schoolIds // ignore: cast_nullable_to_non_nullable
as List<String>?,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationType: freezed == cancellationType ? _self.cancellationType : cancellationType // ignore: cast_nullable_to_non_nullable
as String?,cancellationFee: freezed == cancellationFee ? _self.cancellationFee : cancellationFee // ignore: cast_nullable_to_non_nullable
as double?,cancelRequestedAt: freezed == cancelRequestedAt ? _self.cancelRequestedAt : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pauseStartDate: freezed == pauseStartDate ? _self.pauseStartDate : pauseStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,pauseEndDate: freezed == pauseEndDate ? _self.pauseEndDate : pauseEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,tripCategory: freezed == tripCategory ? _self.tripCategory : tripCategory // ignore: cast_nullable_to_non_nullable
as String?,isOneTime: null == isOneTime ? _self.isOneTime : isOneTime // ignore: cast_nullable_to_non_nullable
as bool,scheduledPickupDatetime: freezed == scheduledPickupDatetime ? _self.scheduledPickupDatetime : scheduledPickupDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledDropoffDatetime: freezed == scheduledDropoffDatetime ? _self.scheduledDropoffDatetime : scheduledDropoffDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,customPickupLocationText: freezed == customPickupLocationText ? _self.customPickupLocationText : customPickupLocationText // ignore: cast_nullable_to_non_nullable
as String?,customPickupGeoText: freezed == customPickupGeoText ? _self.customPickupGeoText : customPickupGeoText // ignore: cast_nullable_to_non_nullable
as String?,customDropoffLocationText: freezed == customDropoffLocationText ? _self.customDropoffLocationText : customDropoffLocationText // ignore: cast_nullable_to_non_nullable
as String?,customDropoffGeoText: freezed == customDropoffGeoText ? _self.customDropoffGeoText : customDropoffGeoText // ignore: cast_nullable_to_non_nullable
as String?,customPickupLat: freezed == customPickupLat ? _self.customPickupLat : customPickupLat // ignore: cast_nullable_to_non_nullable
as double?,customPickupLng: freezed == customPickupLng ? _self.customPickupLng : customPickupLng // ignore: cast_nullable_to_non_nullable
as double?,customDropoffLat: freezed == customDropoffLat ? _self.customDropoffLat : customDropoffLat // ignore: cast_nullable_to_non_nullable
as double?,customDropoffLng: freezed == customDropoffLng ? _self.customDropoffLng : customDropoffLng // ignore: cast_nullable_to_non_nullable
as double?,bookingFlowStep: freezed == bookingFlowStep ? _self.bookingFlowStep : bookingFlowStep // ignore: cast_nullable_to_non_nullable
as String?,totalEstimatedDistanceKm: freezed == totalEstimatedDistanceKm ? _self.totalEstimatedDistanceKm : totalEstimatedDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDurationMinutes: freezed == totalEstimatedDurationMinutes ? _self.totalEstimatedDurationMinutes : totalEstimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,isForParent: null == isForParent ? _self.isForParent : isForParent // ignore: cast_nullable_to_non_nullable
as bool,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhoto: freezed == driverPhoto ? _self.driverPhoto : driverPhoto // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,schoolNameLookup: freezed == schoolNameLookup ? _self.schoolNameLookup : schoolNameLookup // ignore: cast_nullable_to_non_nullable
as String?,schoolAddress: freezed == schoolAddress ? _self.schoolAddress : schoolAddress // ignore: cast_nullable_to_non_nullable
as String?,kidsCount: null == kidsCount ? _self.kidsCount : kidsCount // ignore: cast_nullable_to_non_nullable
as int,childNames: null == childNames ? _self._childNames : childNames // ignore: cast_nullable_to_non_nullable
as List<String>,studentsInfo: null == studentsInfo ? _self._studentsInfo : studentsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on
