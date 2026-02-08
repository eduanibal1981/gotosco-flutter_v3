// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverBooking {

// Core identifiers
@JsonKey(name: 'id') String get id;@JsonKey(name: 'driver_id') String get driverId;@JsonKey(name: 'parent_id') String get parentId;@JsonKey(name: 'status') String get status;@JsonKey(name: 'booking_type') String get bookingType;// Pricing
@JsonKey(name: 'price') double get price;@JsonKey(name: 'proposal_price') double? get proposalPrice;// Location text
@JsonKey(name: 'hometxt_location') String get homeLocation;@JsonKey(name: 'schooltxt_location') String get schoolLocation;// Location coordinates
@JsonKey(name: 'home_lat') double? get homeLat;@JsonKey(name: 'home_lng') double? get homeLng;@JsonKey(name: 'school_lat') double? get schoolLat;@JsonKey(name: 'school_lng') double? get schoolLng;// School references
@JsonKey(name: 'school_id') String? get schoolId;@JsonKey(name: 'school_ids') List<String>? get schoolIds;@JsonKey(name: 'school_name') String? get schoolName;// Time fields
@JsonKey(name: 'home_pickup_time') String? get homePickupTime;@JsonKey(name: 'school_pickup_time') String? get schoolPickupTime;// Date fields
@JsonKey(name: 'start_date') String? get startDate;@JsonKey(name: 'end_date') String? get endDate;@JsonKey(name: 'created_at') String get createdAt;// Recurring booking fields
@JsonKey(name: 'is_recurring') bool get isRecurring;@JsonKey(name: 'recurring_days') List<String> get recurringDays;@JsonKey(name: 'is_monthly_subscription') bool get isMonthlySubscription;// Subscription & Contract
@JsonKey(name: 'subscription_status') String? get subscriptionStatus;@JsonKey(name: 'contract_start_date') String? get contractStartDate;@JsonKey(name: 'contract_end_date') String? get contractEndDate;// Pause dates
@JsonKey(name: 'pause_start_date') String? get pauseStartDate;@JsonKey(name: 'pause_end_date') String? get pauseEndDate;// Cancellation
@JsonKey(name: 'cancellation_type') String? get cancellationType;@JsonKey(name: 'cancellation_reason') String? get cancellationReason;@JsonKey(name: 'cancel_requested_at') String? get cancelRequestedAt;@JsonKey(name: 'cancelled_at') String? get cancelledAt;// Route ordering
@JsonKey(name: 'routego_order') int? get routegoOrder;@JsonKey(name: 'routeret_order') int? get routeretOrder;// Notes
@JsonKey(name: 'notes') String? get notes;// === ENRICHED FROM VIEW (JOINs) ===
// Parent info
@JsonKey(name: 'parent_name') String? get parentName;@JsonKey(name: 'parent_photo') String? get parentPhoto;@JsonKey(name: 'parent_phone') String? get parentPhone;// Children info (from booking_children junction)
@JsonKey(name: 'children') List<BookingChild> get children;
/// Create a copy of DriverBooking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverBookingCopyWith<DriverBooking> get copyWith => _$DriverBookingCopyWithImpl<DriverBooking>(this as DriverBooking, _$identity);

  /// Serializes this DriverBooking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.price, price) || other.price == price)&&(identical(other.proposalPrice, proposalPrice) || other.proposalPrice == proposalPrice)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&const DeepCollectionEquality().equals(other.schoolIds, schoolIds)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&(identical(other.pauseStartDate, pauseStartDate) || other.pauseStartDate == pauseStartDate)&&(identical(other.pauseEndDate, pauseEndDate) || other.pauseEndDate == pauseEndDate)&&(identical(other.cancellationType, cancellationType) || other.cancellationType == cancellationType)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.cancelRequestedAt, cancelRequestedAt) || other.cancelRequestedAt == cancelRequestedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.routegoOrder, routegoOrder) || other.routegoOrder == routegoOrder)&&(identical(other.routeretOrder, routeretOrder) || other.routeretOrder == routeretOrder)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.parentPhoto, parentPhoto) || other.parentPhoto == parentPhoto)&&(identical(other.parentPhone, parentPhone) || other.parentPhone == parentPhone)&&const DeepCollectionEquality().equals(other.children, children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,parentId,status,bookingType,price,proposalPrice,homeLocation,schoolLocation,homeLat,homeLng,schoolLat,schoolLng,schoolId,const DeepCollectionEquality().hash(schoolIds),schoolName,homePickupTime,schoolPickupTime,startDate,endDate,createdAt,isRecurring,const DeepCollectionEquality().hash(recurringDays),isMonthlySubscription,subscriptionStatus,contractStartDate,contractEndDate,pauseStartDate,pauseEndDate,cancellationType,cancellationReason,cancelRequestedAt,cancelledAt,routegoOrder,routeretOrder,notes,parentName,parentPhoto,parentPhone,const DeepCollectionEquality().hash(children)]);

@override
String toString() {
  return 'DriverBooking(id: $id, driverId: $driverId, parentId: $parentId, status: $status, bookingType: $bookingType, price: $price, proposalPrice: $proposalPrice, homeLocation: $homeLocation, schoolLocation: $schoolLocation, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, schoolId: $schoolId, schoolIds: $schoolIds, schoolName: $schoolName, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, isRecurring: $isRecurring, recurringDays: $recurringDays, isMonthlySubscription: $isMonthlySubscription, subscriptionStatus: $subscriptionStatus, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, pauseStartDate: $pauseStartDate, pauseEndDate: $pauseEndDate, cancellationType: $cancellationType, cancellationReason: $cancellationReason, cancelRequestedAt: $cancelRequestedAt, cancelledAt: $cancelledAt, routegoOrder: $routegoOrder, routeretOrder: $routeretOrder, notes: $notes, parentName: $parentName, parentPhoto: $parentPhoto, parentPhone: $parentPhone, children: $children)';
}


}

/// @nodoc
abstract mixin class $DriverBookingCopyWith<$Res>  {
  factory $DriverBookingCopyWith(DriverBooking value, $Res Function(DriverBooking) _then) = _$DriverBookingCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'parent_id') String parentId,@JsonKey(name: 'status') String status,@JsonKey(name: 'booking_type') String bookingType,@JsonKey(name: 'price') double price,@JsonKey(name: 'proposal_price') double? proposalPrice,@JsonKey(name: 'hometxt_location') String homeLocation,@JsonKey(name: 'schooltxt_location') String schoolLocation,@JsonKey(name: 'home_lat') double? homeLat,@JsonKey(name: 'home_lng') double? homeLng,@JsonKey(name: 'school_lat') double? schoolLat,@JsonKey(name: 'school_lng') double? schoolLng,@JsonKey(name: 'school_id') String? schoolId,@JsonKey(name: 'school_ids') List<String>? schoolIds,@JsonKey(name: 'school_name') String? schoolName,@JsonKey(name: 'home_pickup_time') String? homePickupTime,@JsonKey(name: 'school_pickup_time') String? schoolPickupTime,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurring_days') List<String> recurringDays,@JsonKey(name: 'is_monthly_subscription') bool isMonthlySubscription,@JsonKey(name: 'subscription_status') String? subscriptionStatus,@JsonKey(name: 'contract_start_date') String? contractStartDate,@JsonKey(name: 'contract_end_date') String? contractEndDate,@JsonKey(name: 'pause_start_date') String? pauseStartDate,@JsonKey(name: 'pause_end_date') String? pauseEndDate,@JsonKey(name: 'cancellation_type') String? cancellationType,@JsonKey(name: 'cancellation_reason') String? cancellationReason,@JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,@JsonKey(name: 'cancelled_at') String? cancelledAt,@JsonKey(name: 'routego_order') int? routegoOrder,@JsonKey(name: 'routeret_order') int? routeretOrder,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'parent_name') String? parentName,@JsonKey(name: 'parent_photo') String? parentPhoto,@JsonKey(name: 'parent_phone') String? parentPhone,@JsonKey(name: 'children') List<BookingChild> children
});




}
/// @nodoc
class _$DriverBookingCopyWithImpl<$Res>
    implements $DriverBookingCopyWith<$Res> {
  _$DriverBookingCopyWithImpl(this._self, this._then);

  final DriverBooking _self;
  final $Res Function(DriverBooking) _then;

/// Create a copy of DriverBooking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driverId = null,Object? parentId = null,Object? status = null,Object? bookingType = null,Object? price = null,Object? proposalPrice = freezed,Object? homeLocation = null,Object? schoolLocation = null,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? schoolId = freezed,Object? schoolIds = freezed,Object? schoolName = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? createdAt = null,Object? isRecurring = null,Object? recurringDays = null,Object? isMonthlySubscription = null,Object? subscriptionStatus = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? pauseStartDate = freezed,Object? pauseEndDate = freezed,Object? cancellationType = freezed,Object? cancellationReason = freezed,Object? cancelRequestedAt = freezed,Object? cancelledAt = freezed,Object? routegoOrder = freezed,Object? routeretOrder = freezed,Object? notes = freezed,Object? parentName = freezed,Object? parentPhoto = freezed,Object? parentPhone = freezed,Object? children = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as double?,homeLocation: null == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String,schoolLocation: null == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,schoolIds: freezed == schoolIds ? _self.schoolIds : schoolIds // ignore: cast_nullable_to_non_nullable
as List<String>?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as String?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as String?,pauseStartDate: freezed == pauseStartDate ? _self.pauseStartDate : pauseStartDate // ignore: cast_nullable_to_non_nullable
as String?,pauseEndDate: freezed == pauseEndDate ? _self.pauseEndDate : pauseEndDate // ignore: cast_nullable_to_non_nullable
as String?,cancellationType: freezed == cancellationType ? _self.cancellationType : cancellationType // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,cancelRequestedAt: freezed == cancelRequestedAt ? _self.cancelRequestedAt : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as String?,routegoOrder: freezed == routegoOrder ? _self.routegoOrder : routegoOrder // ignore: cast_nullable_to_non_nullable
as int?,routeretOrder: freezed == routeretOrder ? _self.routeretOrder : routeretOrder // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,parentPhoto: freezed == parentPhoto ? _self.parentPhoto : parentPhoto // ignore: cast_nullable_to_non_nullable
as String?,parentPhone: freezed == parentPhone ? _self.parentPhone : parentPhone // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as List<BookingChild>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverBooking].
extension DriverBookingPatterns on DriverBooking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverBooking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverBooking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverBooking value)  $default,){
final _that = this;
switch (_that) {
case _DriverBooking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverBooking value)?  $default,){
final _that = this;
switch (_that) {
case _DriverBooking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'booking_type')  String bookingType, @JsonKey(name: 'price')  double price, @JsonKey(name: 'proposal_price')  double? proposalPrice, @JsonKey(name: 'hometxt_location')  String homeLocation, @JsonKey(name: 'schooltxt_location')  String schoolLocation, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'school_ids')  List<String>? schoolIds, @JsonKey(name: 'school_name')  String? schoolName, @JsonKey(name: 'home_pickup_time')  String? homePickupTime, @JsonKey(name: 'school_pickup_time')  String? schoolPickupTime, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'contract_start_date')  String? contractStartDate, @JsonKey(name: 'contract_end_date')  String? contractEndDate, @JsonKey(name: 'pause_start_date')  String? pauseStartDate, @JsonKey(name: 'pause_end_date')  String? pauseEndDate, @JsonKey(name: 'cancellation_type')  String? cancellationType, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'cancel_requested_at')  String? cancelRequestedAt, @JsonKey(name: 'cancelled_at')  String? cancelledAt, @JsonKey(name: 'routego_order')  int? routegoOrder, @JsonKey(name: 'routeret_order')  int? routeretOrder, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'children')  List<BookingChild> children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverBooking() when $default != null:
return $default(_that.id,_that.driverId,_that.parentId,_that.status,_that.bookingType,_that.price,_that.proposalPrice,_that.homeLocation,_that.schoolLocation,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.schoolId,_that.schoolIds,_that.schoolName,_that.homePickupTime,_that.schoolPickupTime,_that.startDate,_that.endDate,_that.createdAt,_that.isRecurring,_that.recurringDays,_that.isMonthlySubscription,_that.subscriptionStatus,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.cancellationType,_that.cancellationReason,_that.cancelRequestedAt,_that.cancelledAt,_that.routegoOrder,_that.routeretOrder,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'booking_type')  String bookingType, @JsonKey(name: 'price')  double price, @JsonKey(name: 'proposal_price')  double? proposalPrice, @JsonKey(name: 'hometxt_location')  String homeLocation, @JsonKey(name: 'schooltxt_location')  String schoolLocation, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'school_ids')  List<String>? schoolIds, @JsonKey(name: 'school_name')  String? schoolName, @JsonKey(name: 'home_pickup_time')  String? homePickupTime, @JsonKey(name: 'school_pickup_time')  String? schoolPickupTime, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'contract_start_date')  String? contractStartDate, @JsonKey(name: 'contract_end_date')  String? contractEndDate, @JsonKey(name: 'pause_start_date')  String? pauseStartDate, @JsonKey(name: 'pause_end_date')  String? pauseEndDate, @JsonKey(name: 'cancellation_type')  String? cancellationType, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'cancel_requested_at')  String? cancelRequestedAt, @JsonKey(name: 'cancelled_at')  String? cancelledAt, @JsonKey(name: 'routego_order')  int? routegoOrder, @JsonKey(name: 'routeret_order')  int? routeretOrder, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'children')  List<BookingChild> children)  $default,) {final _that = this;
switch (_that) {
case _DriverBooking():
return $default(_that.id,_that.driverId,_that.parentId,_that.status,_that.bookingType,_that.price,_that.proposalPrice,_that.homeLocation,_that.schoolLocation,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.schoolId,_that.schoolIds,_that.schoolName,_that.homePickupTime,_that.schoolPickupTime,_that.startDate,_that.endDate,_that.createdAt,_that.isRecurring,_that.recurringDays,_that.isMonthlySubscription,_that.subscriptionStatus,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.cancellationType,_that.cancellationReason,_that.cancelRequestedAt,_that.cancelledAt,_that.routegoOrder,_that.routeretOrder,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'driver_id')  String driverId, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'status')  String status, @JsonKey(name: 'booking_type')  String bookingType, @JsonKey(name: 'price')  double price, @JsonKey(name: 'proposal_price')  double? proposalPrice, @JsonKey(name: 'hometxt_location')  String homeLocation, @JsonKey(name: 'schooltxt_location')  String schoolLocation, @JsonKey(name: 'home_lat')  double? homeLat, @JsonKey(name: 'home_lng')  double? homeLng, @JsonKey(name: 'school_lat')  double? schoolLat, @JsonKey(name: 'school_lng')  double? schoolLng, @JsonKey(name: 'school_id')  String? schoolId, @JsonKey(name: 'school_ids')  List<String>? schoolIds, @JsonKey(name: 'school_name')  String? schoolName, @JsonKey(name: 'home_pickup_time')  String? homePickupTime, @JsonKey(name: 'school_pickup_time')  String? schoolPickupTime, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'created_at')  String createdAt, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'subscription_status')  String? subscriptionStatus, @JsonKey(name: 'contract_start_date')  String? contractStartDate, @JsonKey(name: 'contract_end_date')  String? contractEndDate, @JsonKey(name: 'pause_start_date')  String? pauseStartDate, @JsonKey(name: 'pause_end_date')  String? pauseEndDate, @JsonKey(name: 'cancellation_type')  String? cancellationType, @JsonKey(name: 'cancellation_reason')  String? cancellationReason, @JsonKey(name: 'cancel_requested_at')  String? cancelRequestedAt, @JsonKey(name: 'cancelled_at')  String? cancelledAt, @JsonKey(name: 'routego_order')  int? routegoOrder, @JsonKey(name: 'routeret_order')  int? routeretOrder, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'children')  List<BookingChild> children)?  $default,) {final _that = this;
switch (_that) {
case _DriverBooking() when $default != null:
return $default(_that.id,_that.driverId,_that.parentId,_that.status,_that.bookingType,_that.price,_that.proposalPrice,_that.homeLocation,_that.schoolLocation,_that.homeLat,_that.homeLng,_that.schoolLat,_that.schoolLng,_that.schoolId,_that.schoolIds,_that.schoolName,_that.homePickupTime,_that.schoolPickupTime,_that.startDate,_that.endDate,_that.createdAt,_that.isRecurring,_that.recurringDays,_that.isMonthlySubscription,_that.subscriptionStatus,_that.contractStartDate,_that.contractEndDate,_that.pauseStartDate,_that.pauseEndDate,_that.cancellationType,_that.cancellationReason,_that.cancelRequestedAt,_that.cancelledAt,_that.routegoOrder,_that.routeretOrder,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverBooking extends DriverBooking {
  const _DriverBooking({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'driver_id') required this.driverId, @JsonKey(name: 'parent_id') required this.parentId, @JsonKey(name: 'status') this.status = 'pending', @JsonKey(name: 'booking_type') this.bookingType = '', @JsonKey(name: 'price') this.price = 0.0, @JsonKey(name: 'proposal_price') this.proposalPrice, @JsonKey(name: 'hometxt_location') this.homeLocation = '', @JsonKey(name: 'schooltxt_location') this.schoolLocation = '', @JsonKey(name: 'home_lat') this.homeLat, @JsonKey(name: 'home_lng') this.homeLng, @JsonKey(name: 'school_lat') this.schoolLat, @JsonKey(name: 'school_lng') this.schoolLng, @JsonKey(name: 'school_id') this.schoolId, @JsonKey(name: 'school_ids') final  List<String>? schoolIds, @JsonKey(name: 'school_name') this.schoolName, @JsonKey(name: 'home_pickup_time') this.homePickupTime, @JsonKey(name: 'school_pickup_time') this.schoolPickupTime, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'end_date') this.endDate, @JsonKey(name: 'created_at') this.createdAt = '', @JsonKey(name: 'is_recurring') this.isRecurring = false, @JsonKey(name: 'recurring_days') final  List<String> recurringDays = const [], @JsonKey(name: 'is_monthly_subscription') this.isMonthlySubscription = false, @JsonKey(name: 'subscription_status') this.subscriptionStatus, @JsonKey(name: 'contract_start_date') this.contractStartDate, @JsonKey(name: 'contract_end_date') this.contractEndDate, @JsonKey(name: 'pause_start_date') this.pauseStartDate, @JsonKey(name: 'pause_end_date') this.pauseEndDate, @JsonKey(name: 'cancellation_type') this.cancellationType, @JsonKey(name: 'cancellation_reason') this.cancellationReason, @JsonKey(name: 'cancel_requested_at') this.cancelRequestedAt, @JsonKey(name: 'cancelled_at') this.cancelledAt, @JsonKey(name: 'routego_order') this.routegoOrder, @JsonKey(name: 'routeret_order') this.routeretOrder, @JsonKey(name: 'notes') this.notes, @JsonKey(name: 'parent_name') this.parentName, @JsonKey(name: 'parent_photo') this.parentPhoto, @JsonKey(name: 'parent_phone') this.parentPhone, @JsonKey(name: 'children') final  List<BookingChild> children = const []}): _schoolIds = schoolIds,_recurringDays = recurringDays,_children = children,super._();
  factory _DriverBooking.fromJson(Map<String, dynamic> json) => _$DriverBookingFromJson(json);

// Core identifiers
@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'driver_id') final  String driverId;
@override@JsonKey(name: 'parent_id') final  String parentId;
@override@JsonKey(name: 'status') final  String status;
@override@JsonKey(name: 'booking_type') final  String bookingType;
// Pricing
@override@JsonKey(name: 'price') final  double price;
@override@JsonKey(name: 'proposal_price') final  double? proposalPrice;
// Location text
@override@JsonKey(name: 'hometxt_location') final  String homeLocation;
@override@JsonKey(name: 'schooltxt_location') final  String schoolLocation;
// Location coordinates
@override@JsonKey(name: 'home_lat') final  double? homeLat;
@override@JsonKey(name: 'home_lng') final  double? homeLng;
@override@JsonKey(name: 'school_lat') final  double? schoolLat;
@override@JsonKey(name: 'school_lng') final  double? schoolLng;
// School references
@override@JsonKey(name: 'school_id') final  String? schoolId;
 final  List<String>? _schoolIds;
@override@JsonKey(name: 'school_ids') List<String>? get schoolIds {
  final value = _schoolIds;
  if (value == null) return null;
  if (_schoolIds is EqualUnmodifiableListView) return _schoolIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'school_name') final  String? schoolName;
// Time fields
@override@JsonKey(name: 'home_pickup_time') final  String? homePickupTime;
@override@JsonKey(name: 'school_pickup_time') final  String? schoolPickupTime;
// Date fields
@override@JsonKey(name: 'start_date') final  String? startDate;
@override@JsonKey(name: 'end_date') final  String? endDate;
@override@JsonKey(name: 'created_at') final  String createdAt;
// Recurring booking fields
@override@JsonKey(name: 'is_recurring') final  bool isRecurring;
 final  List<String> _recurringDays;
@override@JsonKey(name: 'recurring_days') List<String> get recurringDays {
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recurringDays);
}

@override@JsonKey(name: 'is_monthly_subscription') final  bool isMonthlySubscription;
// Subscription & Contract
@override@JsonKey(name: 'subscription_status') final  String? subscriptionStatus;
@override@JsonKey(name: 'contract_start_date') final  String? contractStartDate;
@override@JsonKey(name: 'contract_end_date') final  String? contractEndDate;
// Pause dates
@override@JsonKey(name: 'pause_start_date') final  String? pauseStartDate;
@override@JsonKey(name: 'pause_end_date') final  String? pauseEndDate;
// Cancellation
@override@JsonKey(name: 'cancellation_type') final  String? cancellationType;
@override@JsonKey(name: 'cancellation_reason') final  String? cancellationReason;
@override@JsonKey(name: 'cancel_requested_at') final  String? cancelRequestedAt;
@override@JsonKey(name: 'cancelled_at') final  String? cancelledAt;
// Route ordering
@override@JsonKey(name: 'routego_order') final  int? routegoOrder;
@override@JsonKey(name: 'routeret_order') final  int? routeretOrder;
// Notes
@override@JsonKey(name: 'notes') final  String? notes;
// === ENRICHED FROM VIEW (JOINs) ===
// Parent info
@override@JsonKey(name: 'parent_name') final  String? parentName;
@override@JsonKey(name: 'parent_photo') final  String? parentPhoto;
@override@JsonKey(name: 'parent_phone') final  String? parentPhone;
// Children info (from booking_children junction)
 final  List<BookingChild> _children;
// Children info (from booking_children junction)
@override@JsonKey(name: 'children') List<BookingChild> get children {
  if (_children is EqualUnmodifiableListView) return _children;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_children);
}


/// Create a copy of DriverBooking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverBookingCopyWith<_DriverBooking> get copyWith => __$DriverBookingCopyWithImpl<_DriverBooking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverBookingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverBooking&&(identical(other.id, id) || other.id == id)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.price, price) || other.price == price)&&(identical(other.proposalPrice, proposalPrice) || other.proposalPrice == proposalPrice)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation)&&(identical(other.homeLat, homeLat) || other.homeLat == homeLat)&&(identical(other.homeLng, homeLng) || other.homeLng == homeLng)&&(identical(other.schoolLat, schoolLat) || other.schoolLat == schoolLat)&&(identical(other.schoolLng, schoolLng) || other.schoolLng == schoolLng)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&const DeepCollectionEquality().equals(other._schoolIds, _schoolIds)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.subscriptionStatus, subscriptionStatus) || other.subscriptionStatus == subscriptionStatus)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&(identical(other.pauseStartDate, pauseStartDate) || other.pauseStartDate == pauseStartDate)&&(identical(other.pauseEndDate, pauseEndDate) || other.pauseEndDate == pauseEndDate)&&(identical(other.cancellationType, cancellationType) || other.cancellationType == cancellationType)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.cancelRequestedAt, cancelRequestedAt) || other.cancelRequestedAt == cancelRequestedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.routegoOrder, routegoOrder) || other.routegoOrder == routegoOrder)&&(identical(other.routeretOrder, routeretOrder) || other.routeretOrder == routeretOrder)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.parentPhoto, parentPhoto) || other.parentPhoto == parentPhoto)&&(identical(other.parentPhone, parentPhone) || other.parentPhone == parentPhone)&&const DeepCollectionEquality().equals(other._children, _children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,driverId,parentId,status,bookingType,price,proposalPrice,homeLocation,schoolLocation,homeLat,homeLng,schoolLat,schoolLng,schoolId,const DeepCollectionEquality().hash(_schoolIds),schoolName,homePickupTime,schoolPickupTime,startDate,endDate,createdAt,isRecurring,const DeepCollectionEquality().hash(_recurringDays),isMonthlySubscription,subscriptionStatus,contractStartDate,contractEndDate,pauseStartDate,pauseEndDate,cancellationType,cancellationReason,cancelRequestedAt,cancelledAt,routegoOrder,routeretOrder,notes,parentName,parentPhoto,parentPhone,const DeepCollectionEquality().hash(_children)]);

@override
String toString() {
  return 'DriverBooking(id: $id, driverId: $driverId, parentId: $parentId, status: $status, bookingType: $bookingType, price: $price, proposalPrice: $proposalPrice, homeLocation: $homeLocation, schoolLocation: $schoolLocation, homeLat: $homeLat, homeLng: $homeLng, schoolLat: $schoolLat, schoolLng: $schoolLng, schoolId: $schoolId, schoolIds: $schoolIds, schoolName: $schoolName, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, isRecurring: $isRecurring, recurringDays: $recurringDays, isMonthlySubscription: $isMonthlySubscription, subscriptionStatus: $subscriptionStatus, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, pauseStartDate: $pauseStartDate, pauseEndDate: $pauseEndDate, cancellationType: $cancellationType, cancellationReason: $cancellationReason, cancelRequestedAt: $cancelRequestedAt, cancelledAt: $cancelledAt, routegoOrder: $routegoOrder, routeretOrder: $routeretOrder, notes: $notes, parentName: $parentName, parentPhoto: $parentPhoto, parentPhone: $parentPhone, children: $children)';
}


}

/// @nodoc
abstract mixin class _$DriverBookingCopyWith<$Res> implements $DriverBookingCopyWith<$Res> {
  factory _$DriverBookingCopyWith(_DriverBooking value, $Res Function(_DriverBooking) _then) = __$DriverBookingCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'driver_id') String driverId,@JsonKey(name: 'parent_id') String parentId,@JsonKey(name: 'status') String status,@JsonKey(name: 'booking_type') String bookingType,@JsonKey(name: 'price') double price,@JsonKey(name: 'proposal_price') double? proposalPrice,@JsonKey(name: 'hometxt_location') String homeLocation,@JsonKey(name: 'schooltxt_location') String schoolLocation,@JsonKey(name: 'home_lat') double? homeLat,@JsonKey(name: 'home_lng') double? homeLng,@JsonKey(name: 'school_lat') double? schoolLat,@JsonKey(name: 'school_lng') double? schoolLng,@JsonKey(name: 'school_id') String? schoolId,@JsonKey(name: 'school_ids') List<String>? schoolIds,@JsonKey(name: 'school_name') String? schoolName,@JsonKey(name: 'home_pickup_time') String? homePickupTime,@JsonKey(name: 'school_pickup_time') String? schoolPickupTime,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'created_at') String createdAt,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'recurring_days') List<String> recurringDays,@JsonKey(name: 'is_monthly_subscription') bool isMonthlySubscription,@JsonKey(name: 'subscription_status') String? subscriptionStatus,@JsonKey(name: 'contract_start_date') String? contractStartDate,@JsonKey(name: 'contract_end_date') String? contractEndDate,@JsonKey(name: 'pause_start_date') String? pauseStartDate,@JsonKey(name: 'pause_end_date') String? pauseEndDate,@JsonKey(name: 'cancellation_type') String? cancellationType,@JsonKey(name: 'cancellation_reason') String? cancellationReason,@JsonKey(name: 'cancel_requested_at') String? cancelRequestedAt,@JsonKey(name: 'cancelled_at') String? cancelledAt,@JsonKey(name: 'routego_order') int? routegoOrder,@JsonKey(name: 'routeret_order') int? routeretOrder,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'parent_name') String? parentName,@JsonKey(name: 'parent_photo') String? parentPhoto,@JsonKey(name: 'parent_phone') String? parentPhone,@JsonKey(name: 'children') List<BookingChild> children
});




}
/// @nodoc
class __$DriverBookingCopyWithImpl<$Res>
    implements _$DriverBookingCopyWith<$Res> {
  __$DriverBookingCopyWithImpl(this._self, this._then);

  final _DriverBooking _self;
  final $Res Function(_DriverBooking) _then;

/// Create a copy of DriverBooking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driverId = null,Object? parentId = null,Object? status = null,Object? bookingType = null,Object? price = null,Object? proposalPrice = freezed,Object? homeLocation = null,Object? schoolLocation = null,Object? homeLat = freezed,Object? homeLng = freezed,Object? schoolLat = freezed,Object? schoolLng = freezed,Object? schoolId = freezed,Object? schoolIds = freezed,Object? schoolName = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? createdAt = null,Object? isRecurring = null,Object? recurringDays = null,Object? isMonthlySubscription = null,Object? subscriptionStatus = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? pauseStartDate = freezed,Object? pauseEndDate = freezed,Object? cancellationType = freezed,Object? cancellationReason = freezed,Object? cancelRequestedAt = freezed,Object? cancelledAt = freezed,Object? routegoOrder = freezed,Object? routeretOrder = freezed,Object? notes = freezed,Object? parentName = freezed,Object? parentPhoto = freezed,Object? parentPhone = freezed,Object? children = null,}) {
  return _then(_DriverBooking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,bookingType: null == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as double?,homeLocation: null == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String,schoolLocation: null == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String,homeLat: freezed == homeLat ? _self.homeLat : homeLat // ignore: cast_nullable_to_non_nullable
as double?,homeLng: freezed == homeLng ? _self.homeLng : homeLng // ignore: cast_nullable_to_non_nullable
as double?,schoolLat: freezed == schoolLat ? _self.schoolLat : schoolLat // ignore: cast_nullable_to_non_nullable
as double?,schoolLng: freezed == schoolLng ? _self.schoolLng : schoolLng // ignore: cast_nullable_to_non_nullable
as double?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,schoolIds: freezed == schoolIds ? _self._schoolIds : schoolIds // ignore: cast_nullable_to_non_nullable
as List<String>?,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringDays: null == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,subscriptionStatus: freezed == subscriptionStatus ? _self.subscriptionStatus : subscriptionStatus // ignore: cast_nullable_to_non_nullable
as String?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as String?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as String?,pauseStartDate: freezed == pauseStartDate ? _self.pauseStartDate : pauseStartDate // ignore: cast_nullable_to_non_nullable
as String?,pauseEndDate: freezed == pauseEndDate ? _self.pauseEndDate : pauseEndDate // ignore: cast_nullable_to_non_nullable
as String?,cancellationType: freezed == cancellationType ? _self.cancellationType : cancellationType // ignore: cast_nullable_to_non_nullable
as String?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,cancelRequestedAt: freezed == cancelRequestedAt ? _self.cancelRequestedAt : cancelRequestedAt // ignore: cast_nullable_to_non_nullable
as String?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as String?,routegoOrder: freezed == routegoOrder ? _self.routegoOrder : routegoOrder // ignore: cast_nullable_to_non_nullable
as int?,routeretOrder: freezed == routeretOrder ? _self.routeretOrder : routeretOrder // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,parentPhoto: freezed == parentPhoto ? _self.parentPhoto : parentPhoto // ignore: cast_nullable_to_non_nullable
as String?,parentPhone: freezed == parentPhone ? _self.parentPhone : parentPhone // ignore: cast_nullable_to_non_nullable
as String?,children: null == children ? _self._children : children // ignore: cast_nullable_to_non_nullable
as List<BookingChild>,
  ));
}


}


/// @nodoc
mixin _$BookingChild {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'name') String get name;@JsonKey(name: 'school_name') String get schoolName;@JsonKey(name: 'grade') String get grade;@JsonKey(name: 'age') int? get age;@JsonKey(name: 'gender') String? get gender;
/// Create a copy of BookingChild
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingChildCopyWith<BookingChild> get copyWith => _$BookingChildCopyWithImpl<BookingChild>(this as BookingChild, _$identity);

  /// Serializes this BookingChild to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingChild&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,schoolName,grade,age,gender);

@override
String toString() {
  return 'BookingChild(id: $id, name: $name, schoolName: $schoolName, grade: $grade, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $BookingChildCopyWith<$Res>  {
  factory $BookingChildCopyWith(BookingChild value, $Res Function(BookingChild) _then) = _$BookingChildCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'school_name') String schoolName,@JsonKey(name: 'grade') String grade,@JsonKey(name: 'age') int? age,@JsonKey(name: 'gender') String? gender
});




}
/// @nodoc
class _$BookingChildCopyWithImpl<$Res>
    implements $BookingChildCopyWith<$Res> {
  _$BookingChildCopyWithImpl(this._self, this._then);

  final BookingChild _self;
  final $Res Function(BookingChild) _then;

/// Create a copy of BookingChild
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? schoolName = null,Object? grade = null,Object? age = freezed,Object? gender = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingChild].
extension BookingChildPatterns on BookingChild {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingChild value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingChild() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingChild value)  $default,){
final _that = this;
switch (_that) {
case _BookingChild():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingChild value)?  $default,){
final _that = this;
switch (_that) {
case _BookingChild() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'grade')  String grade, @JsonKey(name: 'age')  int? age, @JsonKey(name: 'gender')  String? gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingChild() when $default != null:
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.age,_that.gender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'grade')  String grade, @JsonKey(name: 'age')  int? age, @JsonKey(name: 'gender')  String? gender)  $default,) {final _that = this;
switch (_that) {
case _BookingChild():
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.age,_that.gender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'name')  String name, @JsonKey(name: 'school_name')  String schoolName, @JsonKey(name: 'grade')  String grade, @JsonKey(name: 'age')  int? age, @JsonKey(name: 'gender')  String? gender)?  $default,) {final _that = this;
switch (_that) {
case _BookingChild() when $default != null:
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.age,_that.gender);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingChild extends BookingChild {
  const _BookingChild({@JsonKey(name: 'id') this.id = '', @JsonKey(name: 'name') this.name = '', @JsonKey(name: 'school_name') this.schoolName = '', @JsonKey(name: 'grade') this.grade = '', @JsonKey(name: 'age') this.age, @JsonKey(name: 'gender') this.gender}): super._();
  factory _BookingChild.fromJson(Map<String, dynamic> json) => _$BookingChildFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'name') final  String name;
@override@JsonKey(name: 'school_name') final  String schoolName;
@override@JsonKey(name: 'grade') final  String grade;
@override@JsonKey(name: 'age') final  int? age;
@override@JsonKey(name: 'gender') final  String? gender;

/// Create a copy of BookingChild
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingChildCopyWith<_BookingChild> get copyWith => __$BookingChildCopyWithImpl<_BookingChild>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingChildToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingChild&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,schoolName,grade,age,gender);

@override
String toString() {
  return 'BookingChild(id: $id, name: $name, schoolName: $schoolName, grade: $grade, age: $age, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$BookingChildCopyWith<$Res> implements $BookingChildCopyWith<$Res> {
  factory _$BookingChildCopyWith(_BookingChild value, $Res Function(_BookingChild) _then) = __$BookingChildCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'name') String name,@JsonKey(name: 'school_name') String schoolName,@JsonKey(name: 'grade') String grade,@JsonKey(name: 'age') int? age,@JsonKey(name: 'gender') String? gender
});




}
/// @nodoc
class __$BookingChildCopyWithImpl<$Res>
    implements _$BookingChildCopyWith<$Res> {
  __$BookingChildCopyWithImpl(this._self, this._then);

  final _BookingChild _self;
  final $Res Function(_BookingChild) _then;

/// Create a copy of BookingChild
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? schoolName = null,Object? grade = null,Object? age = freezed,Object? gender = freezed,}) {
  return _then(_BookingChild(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
