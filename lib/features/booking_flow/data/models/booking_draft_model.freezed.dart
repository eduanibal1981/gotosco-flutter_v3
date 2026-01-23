// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_draft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingDraftModel {

// Step 1: Child Selection
// Single student (backward compatibility)
 String? get studentId;// Multiple students support
 List<String> get studentIds;// Multi-School Support
 bool get isMultiSchool; List<SchoolLocationModel> get schoolLocations;// Using dynamic to avoid circular dep issues during gen, maps to SchoolLocationModel
// Step 2: Trip Category
 String get tripCategory;// 'school', 'Journey', 'Other'
// Step 3: Direction
 String? get bookingType;// 'Two Way', 'One Way to School', 'One Way Back Home'
// Step 4: Locations
 String? get pickupLocationText; double? get pickupLat; double? get pickupLng; String? get dropoffLocationText; double? get dropoffLat; double? get dropoffLng;// Step 5: Schedule
 bool get isOneTime; bool get isRecurring; bool get isMonthlySubscription;// Default to monthly
 DateTime? get scheduledPickupDatetime; DateTime? get scheduledDropoffDatetime; DateTime? get contractStartDate; DateTime? get contractEndDate; List<String>? get recurringDays;// ['monday', 'tuesday', etc.]
 String? get homePickupTime;// Go pickup time (morning)
 String? get schoolPickupTime;// Return pickup time (afternoon)
// Step 6: Review / Metadata
 String? get driverId; double? get estimatedPrice; double? get totalEstimatedDistanceKm; int? get totalEstimatedDurationMinutes; String? get notes;// Current flow state
 int get currentStep; String get flowStep;
/// Create a copy of BookingDraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingDraftModelCopyWith<BookingDraftModel> get copyWith => _$BookingDraftModelCopyWithImpl<BookingDraftModel>(this as BookingDraftModel, _$identity);

  /// Serializes this BookingDraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingDraftModel&&(identical(other.studentId, studentId) || other.studentId == studentId)&&const DeepCollectionEquality().equals(other.studentIds, studentIds)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&const DeepCollectionEquality().equals(other.schoolLocations, schoolLocations)&&(identical(other.tripCategory, tripCategory) || other.tripCategory == tripCategory)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.pickupLocationText, pickupLocationText) || other.pickupLocationText == pickupLocationText)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.dropoffLocationText, dropoffLocationText) || other.dropoffLocationText == dropoffLocationText)&&(identical(other.dropoffLat, dropoffLat) || other.dropoffLat == dropoffLat)&&(identical(other.dropoffLng, dropoffLng) || other.dropoffLng == dropoffLng)&&(identical(other.isOneTime, isOneTime) || other.isOneTime == isOneTime)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.scheduledPickupDatetime, scheduledPickupDatetime) || other.scheduledPickupDatetime == scheduledPickupDatetime)&&(identical(other.scheduledDropoffDatetime, scheduledDropoffDatetime) || other.scheduledDropoffDatetime == scheduledDropoffDatetime)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.estimatedPrice, estimatedPrice) || other.estimatedPrice == estimatedPrice)&&(identical(other.totalEstimatedDistanceKm, totalEstimatedDistanceKm) || other.totalEstimatedDistanceKm == totalEstimatedDistanceKm)&&(identical(other.totalEstimatedDurationMinutes, totalEstimatedDurationMinutes) || other.totalEstimatedDurationMinutes == totalEstimatedDurationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.flowStep, flowStep) || other.flowStep == flowStep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,studentId,const DeepCollectionEquality().hash(studentIds),isMultiSchool,const DeepCollectionEquality().hash(schoolLocations),tripCategory,bookingType,pickupLocationText,pickupLat,pickupLng,dropoffLocationText,dropoffLat,dropoffLng,isOneTime,isRecurring,isMonthlySubscription,scheduledPickupDatetime,scheduledDropoffDatetime,contractStartDate,contractEndDate,const DeepCollectionEquality().hash(recurringDays),homePickupTime,schoolPickupTime,driverId,estimatedPrice,totalEstimatedDistanceKm,totalEstimatedDurationMinutes,notes,currentStep,flowStep]);

@override
String toString() {
  return 'BookingDraftModel(studentId: $studentId, studentIds: $studentIds, isMultiSchool: $isMultiSchool, schoolLocations: $schoolLocations, tripCategory: $tripCategory, bookingType: $bookingType, pickupLocationText: $pickupLocationText, pickupLat: $pickupLat, pickupLng: $pickupLng, dropoffLocationText: $dropoffLocationText, dropoffLat: $dropoffLat, dropoffLng: $dropoffLng, isOneTime: $isOneTime, isRecurring: $isRecurring, isMonthlySubscription: $isMonthlySubscription, scheduledPickupDatetime: $scheduledPickupDatetime, scheduledDropoffDatetime: $scheduledDropoffDatetime, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, recurringDays: $recurringDays, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, driverId: $driverId, estimatedPrice: $estimatedPrice, totalEstimatedDistanceKm: $totalEstimatedDistanceKm, totalEstimatedDurationMinutes: $totalEstimatedDurationMinutes, notes: $notes, currentStep: $currentStep, flowStep: $flowStep)';
}


}

/// @nodoc
abstract mixin class $BookingDraftModelCopyWith<$Res>  {
  factory $BookingDraftModelCopyWith(BookingDraftModel value, $Res Function(BookingDraftModel) _then) = _$BookingDraftModelCopyWithImpl;
@useResult
$Res call({
 String? studentId, List<String> studentIds, bool isMultiSchool, List<SchoolLocationModel> schoolLocations, String tripCategory, String? bookingType, String? pickupLocationText, double? pickupLat, double? pickupLng, String? dropoffLocationText, double? dropoffLat, double? dropoffLng, bool isOneTime, bool isRecurring, bool isMonthlySubscription, DateTime? scheduledPickupDatetime, DateTime? scheduledDropoffDatetime, DateTime? contractStartDate, DateTime? contractEndDate, List<String>? recurringDays, String? homePickupTime, String? schoolPickupTime, String? driverId, double? estimatedPrice, double? totalEstimatedDistanceKm, int? totalEstimatedDurationMinutes, String? notes, int currentStep, String flowStep
});




}
/// @nodoc
class _$BookingDraftModelCopyWithImpl<$Res>
    implements $BookingDraftModelCopyWith<$Res> {
  _$BookingDraftModelCopyWithImpl(this._self, this._then);

  final BookingDraftModel _self;
  final $Res Function(BookingDraftModel) _then;

/// Create a copy of BookingDraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? studentId = freezed,Object? studentIds = null,Object? isMultiSchool = null,Object? schoolLocations = null,Object? tripCategory = null,Object? bookingType = freezed,Object? pickupLocationText = freezed,Object? pickupLat = freezed,Object? pickupLng = freezed,Object? dropoffLocationText = freezed,Object? dropoffLat = freezed,Object? dropoffLng = freezed,Object? isOneTime = null,Object? isRecurring = null,Object? isMonthlySubscription = null,Object? scheduledPickupDatetime = freezed,Object? scheduledDropoffDatetime = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? recurringDays = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? driverId = freezed,Object? estimatedPrice = freezed,Object? totalEstimatedDistanceKm = freezed,Object? totalEstimatedDurationMinutes = freezed,Object? notes = freezed,Object? currentStep = null,Object? flowStep = null,}) {
  return _then(_self.copyWith(
studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentIds: null == studentIds ? _self.studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,schoolLocations: null == schoolLocations ? _self.schoolLocations : schoolLocations // ignore: cast_nullable_to_non_nullable
as List<SchoolLocationModel>,tripCategory: null == tripCategory ? _self.tripCategory : tripCategory // ignore: cast_nullable_to_non_nullable
as String,bookingType: freezed == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String?,pickupLocationText: freezed == pickupLocationText ? _self.pickupLocationText : pickupLocationText // ignore: cast_nullable_to_non_nullable
as String?,pickupLat: freezed == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double?,pickupLng: freezed == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double?,dropoffLocationText: freezed == dropoffLocationText ? _self.dropoffLocationText : dropoffLocationText // ignore: cast_nullable_to_non_nullable
as String?,dropoffLat: freezed == dropoffLat ? _self.dropoffLat : dropoffLat // ignore: cast_nullable_to_non_nullable
as double?,dropoffLng: freezed == dropoffLng ? _self.dropoffLng : dropoffLng // ignore: cast_nullable_to_non_nullable
as double?,isOneTime: null == isOneTime ? _self.isOneTime : isOneTime // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,scheduledPickupDatetime: freezed == scheduledPickupDatetime ? _self.scheduledPickupDatetime : scheduledPickupDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledDropoffDatetime: freezed == scheduledDropoffDatetime ? _self.scheduledDropoffDatetime : scheduledDropoffDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringDays: freezed == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDistanceKm: freezed == totalEstimatedDistanceKm ? _self.totalEstimatedDistanceKm : totalEstimatedDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDurationMinutes: freezed == totalEstimatedDurationMinutes ? _self.totalEstimatedDurationMinutes : totalEstimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,flowStep: null == flowStep ? _self.flowStep : flowStep // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingDraftModel].
extension BookingDraftModelPatterns on BookingDraftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingDraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingDraftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingDraftModel value)  $default,){
final _that = this;
switch (_that) {
case _BookingDraftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingDraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookingDraftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? studentId,  List<String> studentIds,  bool isMultiSchool,  List<SchoolLocationModel> schoolLocations,  String tripCategory,  String? bookingType,  String? pickupLocationText,  double? pickupLat,  double? pickupLng,  String? dropoffLocationText,  double? dropoffLat,  double? dropoffLng,  bool isOneTime,  bool isRecurring,  bool isMonthlySubscription,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  DateTime? contractStartDate,  DateTime? contractEndDate,  List<String>? recurringDays,  String? homePickupTime,  String? schoolPickupTime,  String? driverId,  double? estimatedPrice,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  String? notes,  int currentStep,  String flowStep)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingDraftModel() when $default != null:
return $default(_that.studentId,_that.studentIds,_that.isMultiSchool,_that.schoolLocations,_that.tripCategory,_that.bookingType,_that.pickupLocationText,_that.pickupLat,_that.pickupLng,_that.dropoffLocationText,_that.dropoffLat,_that.dropoffLng,_that.isOneTime,_that.isRecurring,_that.isMonthlySubscription,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.contractStartDate,_that.contractEndDate,_that.recurringDays,_that.homePickupTime,_that.schoolPickupTime,_that.driverId,_that.estimatedPrice,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.notes,_that.currentStep,_that.flowStep);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? studentId,  List<String> studentIds,  bool isMultiSchool,  List<SchoolLocationModel> schoolLocations,  String tripCategory,  String? bookingType,  String? pickupLocationText,  double? pickupLat,  double? pickupLng,  String? dropoffLocationText,  double? dropoffLat,  double? dropoffLng,  bool isOneTime,  bool isRecurring,  bool isMonthlySubscription,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  DateTime? contractStartDate,  DateTime? contractEndDate,  List<String>? recurringDays,  String? homePickupTime,  String? schoolPickupTime,  String? driverId,  double? estimatedPrice,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  String? notes,  int currentStep,  String flowStep)  $default,) {final _that = this;
switch (_that) {
case _BookingDraftModel():
return $default(_that.studentId,_that.studentIds,_that.isMultiSchool,_that.schoolLocations,_that.tripCategory,_that.bookingType,_that.pickupLocationText,_that.pickupLat,_that.pickupLng,_that.dropoffLocationText,_that.dropoffLat,_that.dropoffLng,_that.isOneTime,_that.isRecurring,_that.isMonthlySubscription,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.contractStartDate,_that.contractEndDate,_that.recurringDays,_that.homePickupTime,_that.schoolPickupTime,_that.driverId,_that.estimatedPrice,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.notes,_that.currentStep,_that.flowStep);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? studentId,  List<String> studentIds,  bool isMultiSchool,  List<SchoolLocationModel> schoolLocations,  String tripCategory,  String? bookingType,  String? pickupLocationText,  double? pickupLat,  double? pickupLng,  String? dropoffLocationText,  double? dropoffLat,  double? dropoffLng,  bool isOneTime,  bool isRecurring,  bool isMonthlySubscription,  DateTime? scheduledPickupDatetime,  DateTime? scheduledDropoffDatetime,  DateTime? contractStartDate,  DateTime? contractEndDate,  List<String>? recurringDays,  String? homePickupTime,  String? schoolPickupTime,  String? driverId,  double? estimatedPrice,  double? totalEstimatedDistanceKm,  int? totalEstimatedDurationMinutes,  String? notes,  int currentStep,  String flowStep)?  $default,) {final _that = this;
switch (_that) {
case _BookingDraftModel() when $default != null:
return $default(_that.studentId,_that.studentIds,_that.isMultiSchool,_that.schoolLocations,_that.tripCategory,_that.bookingType,_that.pickupLocationText,_that.pickupLat,_that.pickupLng,_that.dropoffLocationText,_that.dropoffLat,_that.dropoffLng,_that.isOneTime,_that.isRecurring,_that.isMonthlySubscription,_that.scheduledPickupDatetime,_that.scheduledDropoffDatetime,_that.contractStartDate,_that.contractEndDate,_that.recurringDays,_that.homePickupTime,_that.schoolPickupTime,_that.driverId,_that.estimatedPrice,_that.totalEstimatedDistanceKm,_that.totalEstimatedDurationMinutes,_that.notes,_that.currentStep,_that.flowStep);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingDraftModel implements BookingDraftModel {
  const _BookingDraftModel({this.studentId, final  List<String> studentIds = const [], this.isMultiSchool = false, final  List<SchoolLocationModel> schoolLocations = const [], this.tripCategory = 'school', this.bookingType, this.pickupLocationText, this.pickupLat, this.pickupLng, this.dropoffLocationText, this.dropoffLat, this.dropoffLng, this.isOneTime = false, this.isRecurring = false, this.isMonthlySubscription = true, this.scheduledPickupDatetime, this.scheduledDropoffDatetime, this.contractStartDate, this.contractEndDate, final  List<String>? recurringDays, this.homePickupTime, this.schoolPickupTime, this.driverId, this.estimatedPrice, this.totalEstimatedDistanceKm, this.totalEstimatedDurationMinutes, this.notes, this.currentStep = 1, this.flowStep = 'draft'}): _studentIds = studentIds,_schoolLocations = schoolLocations,_recurringDays = recurringDays;
  factory _BookingDraftModel.fromJson(Map<String, dynamic> json) => _$BookingDraftModelFromJson(json);

// Step 1: Child Selection
// Single student (backward compatibility)
@override final  String? studentId;
// Multiple students support
 final  List<String> _studentIds;
// Multiple students support
@override@JsonKey() List<String> get studentIds {
  if (_studentIds is EqualUnmodifiableListView) return _studentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_studentIds);
}

// Multi-School Support
@override@JsonKey() final  bool isMultiSchool;
 final  List<SchoolLocationModel> _schoolLocations;
@override@JsonKey() List<SchoolLocationModel> get schoolLocations {
  if (_schoolLocations is EqualUnmodifiableListView) return _schoolLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schoolLocations);
}

// Using dynamic to avoid circular dep issues during gen, maps to SchoolLocationModel
// Step 2: Trip Category
@override@JsonKey() final  String tripCategory;
// 'school', 'Journey', 'Other'
// Step 3: Direction
@override final  String? bookingType;
// 'Two Way', 'One Way to School', 'One Way Back Home'
// Step 4: Locations
@override final  String? pickupLocationText;
@override final  double? pickupLat;
@override final  double? pickupLng;
@override final  String? dropoffLocationText;
@override final  double? dropoffLat;
@override final  double? dropoffLng;
// Step 5: Schedule
@override@JsonKey() final  bool isOneTime;
@override@JsonKey() final  bool isRecurring;
@override@JsonKey() final  bool isMonthlySubscription;
// Default to monthly
@override final  DateTime? scheduledPickupDatetime;
@override final  DateTime? scheduledDropoffDatetime;
@override final  DateTime? contractStartDate;
@override final  DateTime? contractEndDate;
 final  List<String>? _recurringDays;
@override List<String>? get recurringDays {
  final value = _recurringDays;
  if (value == null) return null;
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// ['monday', 'tuesday', etc.]
@override final  String? homePickupTime;
// Go pickup time (morning)
@override final  String? schoolPickupTime;
// Return pickup time (afternoon)
// Step 6: Review / Metadata
@override final  String? driverId;
@override final  double? estimatedPrice;
@override final  double? totalEstimatedDistanceKm;
@override final  int? totalEstimatedDurationMinutes;
@override final  String? notes;
// Current flow state
@override@JsonKey() final  int currentStep;
@override@JsonKey() final  String flowStep;

/// Create a copy of BookingDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingDraftModelCopyWith<_BookingDraftModel> get copyWith => __$BookingDraftModelCopyWithImpl<_BookingDraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingDraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingDraftModel&&(identical(other.studentId, studentId) || other.studentId == studentId)&&const DeepCollectionEquality().equals(other._studentIds, _studentIds)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&const DeepCollectionEquality().equals(other._schoolLocations, _schoolLocations)&&(identical(other.tripCategory, tripCategory) || other.tripCategory == tripCategory)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.pickupLocationText, pickupLocationText) || other.pickupLocationText == pickupLocationText)&&(identical(other.pickupLat, pickupLat) || other.pickupLat == pickupLat)&&(identical(other.pickupLng, pickupLng) || other.pickupLng == pickupLng)&&(identical(other.dropoffLocationText, dropoffLocationText) || other.dropoffLocationText == dropoffLocationText)&&(identical(other.dropoffLat, dropoffLat) || other.dropoffLat == dropoffLat)&&(identical(other.dropoffLng, dropoffLng) || other.dropoffLng == dropoffLng)&&(identical(other.isOneTime, isOneTime) || other.isOneTime == isOneTime)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.scheduledPickupDatetime, scheduledPickupDatetime) || other.scheduledPickupDatetime == scheduledPickupDatetime)&&(identical(other.scheduledDropoffDatetime, scheduledDropoffDatetime) || other.scheduledDropoffDatetime == scheduledDropoffDatetime)&&(identical(other.contractStartDate, contractStartDate) || other.contractStartDate == contractStartDate)&&(identical(other.contractEndDate, contractEndDate) || other.contractEndDate == contractEndDate)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&(identical(other.homePickupTime, homePickupTime) || other.homePickupTime == homePickupTime)&&(identical(other.schoolPickupTime, schoolPickupTime) || other.schoolPickupTime == schoolPickupTime)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.estimatedPrice, estimatedPrice) || other.estimatedPrice == estimatedPrice)&&(identical(other.totalEstimatedDistanceKm, totalEstimatedDistanceKm) || other.totalEstimatedDistanceKm == totalEstimatedDistanceKm)&&(identical(other.totalEstimatedDurationMinutes, totalEstimatedDurationMinutes) || other.totalEstimatedDurationMinutes == totalEstimatedDurationMinutes)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.flowStep, flowStep) || other.flowStep == flowStep));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,studentId,const DeepCollectionEquality().hash(_studentIds),isMultiSchool,const DeepCollectionEquality().hash(_schoolLocations),tripCategory,bookingType,pickupLocationText,pickupLat,pickupLng,dropoffLocationText,dropoffLat,dropoffLng,isOneTime,isRecurring,isMonthlySubscription,scheduledPickupDatetime,scheduledDropoffDatetime,contractStartDate,contractEndDate,const DeepCollectionEquality().hash(_recurringDays),homePickupTime,schoolPickupTime,driverId,estimatedPrice,totalEstimatedDistanceKm,totalEstimatedDurationMinutes,notes,currentStep,flowStep]);

@override
String toString() {
  return 'BookingDraftModel(studentId: $studentId, studentIds: $studentIds, isMultiSchool: $isMultiSchool, schoolLocations: $schoolLocations, tripCategory: $tripCategory, bookingType: $bookingType, pickupLocationText: $pickupLocationText, pickupLat: $pickupLat, pickupLng: $pickupLng, dropoffLocationText: $dropoffLocationText, dropoffLat: $dropoffLat, dropoffLng: $dropoffLng, isOneTime: $isOneTime, isRecurring: $isRecurring, isMonthlySubscription: $isMonthlySubscription, scheduledPickupDatetime: $scheduledPickupDatetime, scheduledDropoffDatetime: $scheduledDropoffDatetime, contractStartDate: $contractStartDate, contractEndDate: $contractEndDate, recurringDays: $recurringDays, homePickupTime: $homePickupTime, schoolPickupTime: $schoolPickupTime, driverId: $driverId, estimatedPrice: $estimatedPrice, totalEstimatedDistanceKm: $totalEstimatedDistanceKm, totalEstimatedDurationMinutes: $totalEstimatedDurationMinutes, notes: $notes, currentStep: $currentStep, flowStep: $flowStep)';
}


}

/// @nodoc
abstract mixin class _$BookingDraftModelCopyWith<$Res> implements $BookingDraftModelCopyWith<$Res> {
  factory _$BookingDraftModelCopyWith(_BookingDraftModel value, $Res Function(_BookingDraftModel) _then) = __$BookingDraftModelCopyWithImpl;
@override @useResult
$Res call({
 String? studentId, List<String> studentIds, bool isMultiSchool, List<SchoolLocationModel> schoolLocations, String tripCategory, String? bookingType, String? pickupLocationText, double? pickupLat, double? pickupLng, String? dropoffLocationText, double? dropoffLat, double? dropoffLng, bool isOneTime, bool isRecurring, bool isMonthlySubscription, DateTime? scheduledPickupDatetime, DateTime? scheduledDropoffDatetime, DateTime? contractStartDate, DateTime? contractEndDate, List<String>? recurringDays, String? homePickupTime, String? schoolPickupTime, String? driverId, double? estimatedPrice, double? totalEstimatedDistanceKm, int? totalEstimatedDurationMinutes, String? notes, int currentStep, String flowStep
});




}
/// @nodoc
class __$BookingDraftModelCopyWithImpl<$Res>
    implements _$BookingDraftModelCopyWith<$Res> {
  __$BookingDraftModelCopyWithImpl(this._self, this._then);

  final _BookingDraftModel _self;
  final $Res Function(_BookingDraftModel) _then;

/// Create a copy of BookingDraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? studentId = freezed,Object? studentIds = null,Object? isMultiSchool = null,Object? schoolLocations = null,Object? tripCategory = null,Object? bookingType = freezed,Object? pickupLocationText = freezed,Object? pickupLat = freezed,Object? pickupLng = freezed,Object? dropoffLocationText = freezed,Object? dropoffLat = freezed,Object? dropoffLng = freezed,Object? isOneTime = null,Object? isRecurring = null,Object? isMonthlySubscription = null,Object? scheduledPickupDatetime = freezed,Object? scheduledDropoffDatetime = freezed,Object? contractStartDate = freezed,Object? contractEndDate = freezed,Object? recurringDays = freezed,Object? homePickupTime = freezed,Object? schoolPickupTime = freezed,Object? driverId = freezed,Object? estimatedPrice = freezed,Object? totalEstimatedDistanceKm = freezed,Object? totalEstimatedDurationMinutes = freezed,Object? notes = freezed,Object? currentStep = null,Object? flowStep = null,}) {
  return _then(_BookingDraftModel(
studentId: freezed == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String?,studentIds: null == studentIds ? _self._studentIds : studentIds // ignore: cast_nullable_to_non_nullable
as List<String>,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,schoolLocations: null == schoolLocations ? _self._schoolLocations : schoolLocations // ignore: cast_nullable_to_non_nullable
as List<SchoolLocationModel>,tripCategory: null == tripCategory ? _self.tripCategory : tripCategory // ignore: cast_nullable_to_non_nullable
as String,bookingType: freezed == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String?,pickupLocationText: freezed == pickupLocationText ? _self.pickupLocationText : pickupLocationText // ignore: cast_nullable_to_non_nullable
as String?,pickupLat: freezed == pickupLat ? _self.pickupLat : pickupLat // ignore: cast_nullable_to_non_nullable
as double?,pickupLng: freezed == pickupLng ? _self.pickupLng : pickupLng // ignore: cast_nullable_to_non_nullable
as double?,dropoffLocationText: freezed == dropoffLocationText ? _self.dropoffLocationText : dropoffLocationText // ignore: cast_nullable_to_non_nullable
as String?,dropoffLat: freezed == dropoffLat ? _self.dropoffLat : dropoffLat // ignore: cast_nullable_to_non_nullable
as double?,dropoffLng: freezed == dropoffLng ? _self.dropoffLng : dropoffLng // ignore: cast_nullable_to_non_nullable
as double?,isOneTime: null == isOneTime ? _self.isOneTime : isOneTime // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,scheduledPickupDatetime: freezed == scheduledPickupDatetime ? _self.scheduledPickupDatetime : scheduledPickupDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledDropoffDatetime: freezed == scheduledDropoffDatetime ? _self.scheduledDropoffDatetime : scheduledDropoffDatetime // ignore: cast_nullable_to_non_nullable
as DateTime?,contractStartDate: freezed == contractStartDate ? _self.contractStartDate : contractStartDate // ignore: cast_nullable_to_non_nullable
as DateTime?,contractEndDate: freezed == contractEndDate ? _self.contractEndDate : contractEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,recurringDays: freezed == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>?,homePickupTime: freezed == homePickupTime ? _self.homePickupTime : homePickupTime // ignore: cast_nullable_to_non_nullable
as String?,schoolPickupTime: freezed == schoolPickupTime ? _self.schoolPickupTime : schoolPickupTime // ignore: cast_nullable_to_non_nullable
as String?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,estimatedPrice: freezed == estimatedPrice ? _self.estimatedPrice : estimatedPrice // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDistanceKm: freezed == totalEstimatedDistanceKm ? _self.totalEstimatedDistanceKm : totalEstimatedDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,totalEstimatedDurationMinutes: freezed == totalEstimatedDurationMinutes ? _self.totalEstimatedDurationMinutes : totalEstimatedDurationMinutes // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,flowStep: null == flowStep ? _self.flowStep : flowStep // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
