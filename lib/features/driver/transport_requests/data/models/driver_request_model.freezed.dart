// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverRequest {

@JsonKey(name: 'id') String get id;@JsonKey(name: 'parent_id') String get parentId;@JsonKey(name: 'driver_id') String? get driverId;@JsonKey(name: 'status') String? get status;@JsonKey(name: 'booking_type') String? get bookingType;// 'one_time', 'recurring'
@JsonKey(name: 'notes') String? get notes;// Parent info (from join)
@JsonKey(name: 'parent_name') String? get parentName;@JsonKey(name: 'parent_photo') String? get parentPhoto;@JsonKey(name: 'parent_phone') String? get parentPhone;// Locations
@JsonKey(name: 'hometxt_location') String? get homeLocation;@JsonKey(name: 'schooltxt_location') String? get schoolLocation;@JsonKey(name: 'homegeo_location') String? get homeGeoLocation;@JsonKey(name: 'schoolgeo_location') String? get schoolGeoLocation;// Dates/Times
@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'start_date') String? get startDate;@JsonKey(name: 'end_date') String? get endDate;@JsonKey(name: 'home_pickup_time') String? get pickupTime;@JsonKey(name: 'recurring_days') List<String> get recurringDays;@JsonKey(name: 'proposal_price') dynamic get proposalPrice;// Can be int or double
// Arrays from View
@JsonKey(name: 'students_info') List<Map<String, dynamic>> get studentsInfo;@JsonKey(name: 'schools_info') List<Map<String, dynamic>> get schoolsInfo;@JsonKey(name: 'is_monthly_subscription') bool get isMonthlySubscription;@JsonKey(name: 'is_recurring') bool get isRecurring;@JsonKey(name: 'is_multi_school') bool get isMultiSchool;@JsonKey(name: 'school_name') String? get schoolName;
/// Create a copy of DriverRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverRequestCopyWith<DriverRequest> get copyWith => _$DriverRequestCopyWithImpl<DriverRequest>(this as DriverRequest, _$identity);

  /// Serializes this DriverRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.parentPhoto, parentPhoto) || other.parentPhoto == parentPhoto)&&(identical(other.parentPhone, parentPhone) || other.parentPhone == parentPhone)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation)&&(identical(other.homeGeoLocation, homeGeoLocation) || other.homeGeoLocation == homeGeoLocation)&&(identical(other.schoolGeoLocation, schoolGeoLocation) || other.schoolGeoLocation == schoolGeoLocation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.pickupTime, pickupTime) || other.pickupTime == pickupTime)&&const DeepCollectionEquality().equals(other.recurringDays, recurringDays)&&const DeepCollectionEquality().equals(other.proposalPrice, proposalPrice)&&const DeepCollectionEquality().equals(other.studentsInfo, studentsInfo)&&const DeepCollectionEquality().equals(other.schoolsInfo, schoolsInfo)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentId,driverId,status,bookingType,notes,parentName,parentPhoto,parentPhone,homeLocation,schoolLocation,homeGeoLocation,schoolGeoLocation,createdAt,startDate,endDate,pickupTime,const DeepCollectionEquality().hash(recurringDays),const DeepCollectionEquality().hash(proposalPrice),const DeepCollectionEquality().hash(studentsInfo),const DeepCollectionEquality().hash(schoolsInfo),isMonthlySubscription,isRecurring,isMultiSchool,schoolName]);

@override
String toString() {
  return 'DriverRequest(id: $id, parentId: $parentId, driverId: $driverId, status: $status, bookingType: $bookingType, notes: $notes, parentName: $parentName, parentPhoto: $parentPhoto, parentPhone: $parentPhone, homeLocation: $homeLocation, schoolLocation: $schoolLocation, homeGeoLocation: $homeGeoLocation, schoolGeoLocation: $schoolGeoLocation, createdAt: $createdAt, startDate: $startDate, endDate: $endDate, pickupTime: $pickupTime, recurringDays: $recurringDays, proposalPrice: $proposalPrice, studentsInfo: $studentsInfo, schoolsInfo: $schoolsInfo, isMonthlySubscription: $isMonthlySubscription, isRecurring: $isRecurring, isMultiSchool: $isMultiSchool, schoolName: $schoolName)';
}


}

/// @nodoc
abstract mixin class $DriverRequestCopyWith<$Res>  {
  factory $DriverRequestCopyWith(DriverRequest value, $Res Function(DriverRequest) _then) = _$DriverRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'parent_id') String parentId,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'status') String? status,@JsonKey(name: 'booking_type') String? bookingType,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'parent_name') String? parentName,@JsonKey(name: 'parent_photo') String? parentPhoto,@JsonKey(name: 'parent_phone') String? parentPhone,@JsonKey(name: 'hometxt_location') String? homeLocation,@JsonKey(name: 'schooltxt_location') String? schoolLocation,@JsonKey(name: 'homegeo_location') String? homeGeoLocation,@JsonKey(name: 'schoolgeo_location') String? schoolGeoLocation,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'home_pickup_time') String? pickupTime,@JsonKey(name: 'recurring_days') List<String> recurringDays,@JsonKey(name: 'proposal_price') dynamic proposalPrice,@JsonKey(name: 'students_info') List<Map<String, dynamic>> studentsInfo,@JsonKey(name: 'schools_info') List<Map<String, dynamic>> schoolsInfo,@JsonKey(name: 'is_monthly_subscription') bool isMonthlySubscription,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'is_multi_school') bool isMultiSchool,@JsonKey(name: 'school_name') String? schoolName
});




}
/// @nodoc
class _$DriverRequestCopyWithImpl<$Res>
    implements $DriverRequestCopyWith<$Res> {
  _$DriverRequestCopyWithImpl(this._self, this._then);

  final DriverRequest _self;
  final $Res Function(DriverRequest) _then;

/// Create a copy of DriverRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = null,Object? driverId = freezed,Object? status = freezed,Object? bookingType = freezed,Object? notes = freezed,Object? parentName = freezed,Object? parentPhoto = freezed,Object? parentPhone = freezed,Object? homeLocation = freezed,Object? schoolLocation = freezed,Object? homeGeoLocation = freezed,Object? schoolGeoLocation = freezed,Object? createdAt = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? pickupTime = freezed,Object? recurringDays = null,Object? proposalPrice = freezed,Object? studentsInfo = null,Object? schoolsInfo = null,Object? isMonthlySubscription = null,Object? isRecurring = null,Object? isMultiSchool = null,Object? schoolName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,bookingType: freezed == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,parentPhoto: freezed == parentPhoto ? _self.parentPhoto : parentPhoto // ignore: cast_nullable_to_non_nullable
as String?,parentPhone: freezed == parentPhone ? _self.parentPhone : parentPhone // ignore: cast_nullable_to_non_nullable
as String?,homeLocation: freezed == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolLocation: freezed == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String?,homeGeoLocation: freezed == homeGeoLocation ? _self.homeGeoLocation : homeGeoLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolGeoLocation: freezed == schoolGeoLocation ? _self.schoolGeoLocation : schoolGeoLocation // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,pickupTime: freezed == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as String?,recurringDays: null == recurringDays ? _self.recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as dynamic,studentsInfo: null == studentsInfo ? _self.studentsInfo : studentsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,schoolsInfo: null == schoolsInfo ? _self.schoolsInfo : schoolsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverRequest].
extension DriverRequestPatterns on DriverRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverRequest value)  $default,){
final _that = this;
switch (_that) {
case _DriverRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverRequest value)?  $default,){
final _that = this;
switch (_that) {
case _DriverRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'booking_type')  String? bookingType, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'hometxt_location')  String? homeLocation, @JsonKey(name: 'schooltxt_location')  String? schoolLocation, @JsonKey(name: 'homegeo_location')  String? homeGeoLocation, @JsonKey(name: 'schoolgeo_location')  String? schoolGeoLocation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'home_pickup_time')  String? pickupTime, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'proposal_price')  dynamic proposalPrice, @JsonKey(name: 'students_info')  List<Map<String, dynamic>> studentsInfo, @JsonKey(name: 'schools_info')  List<Map<String, dynamic>> schoolsInfo, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'is_multi_school')  bool isMultiSchool, @JsonKey(name: 'school_name')  String? schoolName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverRequest() when $default != null:
return $default(_that.id,_that.parentId,_that.driverId,_that.status,_that.bookingType,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.homeLocation,_that.schoolLocation,_that.homeGeoLocation,_that.schoolGeoLocation,_that.createdAt,_that.startDate,_that.endDate,_that.pickupTime,_that.recurringDays,_that.proposalPrice,_that.studentsInfo,_that.schoolsInfo,_that.isMonthlySubscription,_that.isRecurring,_that.isMultiSchool,_that.schoolName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'booking_type')  String? bookingType, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'hometxt_location')  String? homeLocation, @JsonKey(name: 'schooltxt_location')  String? schoolLocation, @JsonKey(name: 'homegeo_location')  String? homeGeoLocation, @JsonKey(name: 'schoolgeo_location')  String? schoolGeoLocation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'home_pickup_time')  String? pickupTime, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'proposal_price')  dynamic proposalPrice, @JsonKey(name: 'students_info')  List<Map<String, dynamic>> studentsInfo, @JsonKey(name: 'schools_info')  List<Map<String, dynamic>> schoolsInfo, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'is_multi_school')  bool isMultiSchool, @JsonKey(name: 'school_name')  String? schoolName)  $default,) {final _that = this;
switch (_that) {
case _DriverRequest():
return $default(_that.id,_that.parentId,_that.driverId,_that.status,_that.bookingType,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.homeLocation,_that.schoolLocation,_that.homeGeoLocation,_that.schoolGeoLocation,_that.createdAt,_that.startDate,_that.endDate,_that.pickupTime,_that.recurringDays,_that.proposalPrice,_that.studentsInfo,_that.schoolsInfo,_that.isMonthlySubscription,_that.isRecurring,_that.isMultiSchool,_that.schoolName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id, @JsonKey(name: 'parent_id')  String parentId, @JsonKey(name: 'driver_id')  String? driverId, @JsonKey(name: 'status')  String? status, @JsonKey(name: 'booking_type')  String? bookingType, @JsonKey(name: 'notes')  String? notes, @JsonKey(name: 'parent_name')  String? parentName, @JsonKey(name: 'parent_photo')  String? parentPhoto, @JsonKey(name: 'parent_phone')  String? parentPhone, @JsonKey(name: 'hometxt_location')  String? homeLocation, @JsonKey(name: 'schooltxt_location')  String? schoolLocation, @JsonKey(name: 'homegeo_location')  String? homeGeoLocation, @JsonKey(name: 'schoolgeo_location')  String? schoolGeoLocation, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'start_date')  String? startDate, @JsonKey(name: 'end_date')  String? endDate, @JsonKey(name: 'home_pickup_time')  String? pickupTime, @JsonKey(name: 'recurring_days')  List<String> recurringDays, @JsonKey(name: 'proposal_price')  dynamic proposalPrice, @JsonKey(name: 'students_info')  List<Map<String, dynamic>> studentsInfo, @JsonKey(name: 'schools_info')  List<Map<String, dynamic>> schoolsInfo, @JsonKey(name: 'is_monthly_subscription')  bool isMonthlySubscription, @JsonKey(name: 'is_recurring')  bool isRecurring, @JsonKey(name: 'is_multi_school')  bool isMultiSchool, @JsonKey(name: 'school_name')  String? schoolName)?  $default,) {final _that = this;
switch (_that) {
case _DriverRequest() when $default != null:
return $default(_that.id,_that.parentId,_that.driverId,_that.status,_that.bookingType,_that.notes,_that.parentName,_that.parentPhoto,_that.parentPhone,_that.homeLocation,_that.schoolLocation,_that.homeGeoLocation,_that.schoolGeoLocation,_that.createdAt,_that.startDate,_that.endDate,_that.pickupTime,_that.recurringDays,_that.proposalPrice,_that.studentsInfo,_that.schoolsInfo,_that.isMonthlySubscription,_that.isRecurring,_that.isMultiSchool,_that.schoolName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverRequest extends DriverRequest {
  const _DriverRequest({@JsonKey(name: 'id') required this.id, @JsonKey(name: 'parent_id') required this.parentId, @JsonKey(name: 'driver_id') this.driverId, @JsonKey(name: 'status') this.status, @JsonKey(name: 'booking_type') this.bookingType, @JsonKey(name: 'notes') this.notes, @JsonKey(name: 'parent_name') this.parentName, @JsonKey(name: 'parent_photo') this.parentPhoto, @JsonKey(name: 'parent_phone') this.parentPhone, @JsonKey(name: 'hometxt_location') this.homeLocation, @JsonKey(name: 'schooltxt_location') this.schoolLocation, @JsonKey(name: 'homegeo_location') this.homeGeoLocation, @JsonKey(name: 'schoolgeo_location') this.schoolGeoLocation, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'end_date') this.endDate, @JsonKey(name: 'home_pickup_time') this.pickupTime, @JsonKey(name: 'recurring_days') final  List<String> recurringDays = const [], @JsonKey(name: 'proposal_price') this.proposalPrice, @JsonKey(name: 'students_info') final  List<Map<String, dynamic>> studentsInfo = const [], @JsonKey(name: 'schools_info') final  List<Map<String, dynamic>> schoolsInfo = const [], @JsonKey(name: 'is_monthly_subscription') this.isMonthlySubscription = false, @JsonKey(name: 'is_recurring') this.isRecurring = false, @JsonKey(name: 'is_multi_school') this.isMultiSchool = false, @JsonKey(name: 'school_name') this.schoolName}): _recurringDays = recurringDays,_studentsInfo = studentsInfo,_schoolsInfo = schoolsInfo,super._();
  factory _DriverRequest.fromJson(Map<String, dynamic> json) => _$DriverRequestFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override@JsonKey(name: 'parent_id') final  String parentId;
@override@JsonKey(name: 'driver_id') final  String? driverId;
@override@JsonKey(name: 'status') final  String? status;
@override@JsonKey(name: 'booking_type') final  String? bookingType;
// 'one_time', 'recurring'
@override@JsonKey(name: 'notes') final  String? notes;
// Parent info (from join)
@override@JsonKey(name: 'parent_name') final  String? parentName;
@override@JsonKey(name: 'parent_photo') final  String? parentPhoto;
@override@JsonKey(name: 'parent_phone') final  String? parentPhone;
// Locations
@override@JsonKey(name: 'hometxt_location') final  String? homeLocation;
@override@JsonKey(name: 'schooltxt_location') final  String? schoolLocation;
@override@JsonKey(name: 'homegeo_location') final  String? homeGeoLocation;
@override@JsonKey(name: 'schoolgeo_location') final  String? schoolGeoLocation;
// Dates/Times
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'start_date') final  String? startDate;
@override@JsonKey(name: 'end_date') final  String? endDate;
@override@JsonKey(name: 'home_pickup_time') final  String? pickupTime;
 final  List<String> _recurringDays;
@override@JsonKey(name: 'recurring_days') List<String> get recurringDays {
  if (_recurringDays is EqualUnmodifiableListView) return _recurringDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recurringDays);
}

@override@JsonKey(name: 'proposal_price') final  dynamic proposalPrice;
// Can be int or double
// Arrays from View
 final  List<Map<String, dynamic>> _studentsInfo;
// Can be int or double
// Arrays from View
@override@JsonKey(name: 'students_info') List<Map<String, dynamic>> get studentsInfo {
  if (_studentsInfo is EqualUnmodifiableListView) return _studentsInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_studentsInfo);
}

 final  List<Map<String, dynamic>> _schoolsInfo;
@override@JsonKey(name: 'schools_info') List<Map<String, dynamic>> get schoolsInfo {
  if (_schoolsInfo is EqualUnmodifiableListView) return _schoolsInfo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_schoolsInfo);
}

@override@JsonKey(name: 'is_monthly_subscription') final  bool isMonthlySubscription;
@override@JsonKey(name: 'is_recurring') final  bool isRecurring;
@override@JsonKey(name: 'is_multi_school') final  bool isMultiSchool;
@override@JsonKey(name: 'school_name') final  String? schoolName;

/// Create a copy of DriverRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverRequestCopyWith<_DriverRequest> get copyWith => __$DriverRequestCopyWithImpl<_DriverRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.bookingType, bookingType) || other.bookingType == bookingType)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.parentName, parentName) || other.parentName == parentName)&&(identical(other.parentPhoto, parentPhoto) || other.parentPhoto == parentPhoto)&&(identical(other.parentPhone, parentPhone) || other.parentPhone == parentPhone)&&(identical(other.homeLocation, homeLocation) || other.homeLocation == homeLocation)&&(identical(other.schoolLocation, schoolLocation) || other.schoolLocation == schoolLocation)&&(identical(other.homeGeoLocation, homeGeoLocation) || other.homeGeoLocation == homeGeoLocation)&&(identical(other.schoolGeoLocation, schoolGeoLocation) || other.schoolGeoLocation == schoolGeoLocation)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.pickupTime, pickupTime) || other.pickupTime == pickupTime)&&const DeepCollectionEquality().equals(other._recurringDays, _recurringDays)&&const DeepCollectionEquality().equals(other.proposalPrice, proposalPrice)&&const DeepCollectionEquality().equals(other._studentsInfo, _studentsInfo)&&const DeepCollectionEquality().equals(other._schoolsInfo, _schoolsInfo)&&(identical(other.isMonthlySubscription, isMonthlySubscription) || other.isMonthlySubscription == isMonthlySubscription)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.isMultiSchool, isMultiSchool) || other.isMultiSchool == isMultiSchool)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentId,driverId,status,bookingType,notes,parentName,parentPhoto,parentPhone,homeLocation,schoolLocation,homeGeoLocation,schoolGeoLocation,createdAt,startDate,endDate,pickupTime,const DeepCollectionEquality().hash(_recurringDays),const DeepCollectionEquality().hash(proposalPrice),const DeepCollectionEquality().hash(_studentsInfo),const DeepCollectionEquality().hash(_schoolsInfo),isMonthlySubscription,isRecurring,isMultiSchool,schoolName]);

@override
String toString() {
  return 'DriverRequest(id: $id, parentId: $parentId, driverId: $driverId, status: $status, bookingType: $bookingType, notes: $notes, parentName: $parentName, parentPhoto: $parentPhoto, parentPhone: $parentPhone, homeLocation: $homeLocation, schoolLocation: $schoolLocation, homeGeoLocation: $homeGeoLocation, schoolGeoLocation: $schoolGeoLocation, createdAt: $createdAt, startDate: $startDate, endDate: $endDate, pickupTime: $pickupTime, recurringDays: $recurringDays, proposalPrice: $proposalPrice, studentsInfo: $studentsInfo, schoolsInfo: $schoolsInfo, isMonthlySubscription: $isMonthlySubscription, isRecurring: $isRecurring, isMultiSchool: $isMultiSchool, schoolName: $schoolName)';
}


}

/// @nodoc
abstract mixin class _$DriverRequestCopyWith<$Res> implements $DriverRequestCopyWith<$Res> {
  factory _$DriverRequestCopyWith(_DriverRequest value, $Res Function(_DriverRequest) _then) = __$DriverRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id,@JsonKey(name: 'parent_id') String parentId,@JsonKey(name: 'driver_id') String? driverId,@JsonKey(name: 'status') String? status,@JsonKey(name: 'booking_type') String? bookingType,@JsonKey(name: 'notes') String? notes,@JsonKey(name: 'parent_name') String? parentName,@JsonKey(name: 'parent_photo') String? parentPhoto,@JsonKey(name: 'parent_phone') String? parentPhone,@JsonKey(name: 'hometxt_location') String? homeLocation,@JsonKey(name: 'schooltxt_location') String? schoolLocation,@JsonKey(name: 'homegeo_location') String? homeGeoLocation,@JsonKey(name: 'schoolgeo_location') String? schoolGeoLocation,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'start_date') String? startDate,@JsonKey(name: 'end_date') String? endDate,@JsonKey(name: 'home_pickup_time') String? pickupTime,@JsonKey(name: 'recurring_days') List<String> recurringDays,@JsonKey(name: 'proposal_price') dynamic proposalPrice,@JsonKey(name: 'students_info') List<Map<String, dynamic>> studentsInfo,@JsonKey(name: 'schools_info') List<Map<String, dynamic>> schoolsInfo,@JsonKey(name: 'is_monthly_subscription') bool isMonthlySubscription,@JsonKey(name: 'is_recurring') bool isRecurring,@JsonKey(name: 'is_multi_school') bool isMultiSchool,@JsonKey(name: 'school_name') String? schoolName
});




}
/// @nodoc
class __$DriverRequestCopyWithImpl<$Res>
    implements _$DriverRequestCopyWith<$Res> {
  __$DriverRequestCopyWithImpl(this._self, this._then);

  final _DriverRequest _self;
  final $Res Function(_DriverRequest) _then;

/// Create a copy of DriverRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = null,Object? driverId = freezed,Object? status = freezed,Object? bookingType = freezed,Object? notes = freezed,Object? parentName = freezed,Object? parentPhoto = freezed,Object? parentPhone = freezed,Object? homeLocation = freezed,Object? schoolLocation = freezed,Object? homeGeoLocation = freezed,Object? schoolGeoLocation = freezed,Object? createdAt = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? pickupTime = freezed,Object? recurringDays = null,Object? proposalPrice = freezed,Object? studentsInfo = null,Object? schoolsInfo = null,Object? isMonthlySubscription = null,Object? isRecurring = null,Object? isMultiSchool = null,Object? schoolName = freezed,}) {
  return _then(_DriverRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: null == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,bookingType: freezed == bookingType ? _self.bookingType : bookingType // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,parentName: freezed == parentName ? _self.parentName : parentName // ignore: cast_nullable_to_non_nullable
as String?,parentPhoto: freezed == parentPhoto ? _self.parentPhoto : parentPhoto // ignore: cast_nullable_to_non_nullable
as String?,parentPhone: freezed == parentPhone ? _self.parentPhone : parentPhone // ignore: cast_nullable_to_non_nullable
as String?,homeLocation: freezed == homeLocation ? _self.homeLocation : homeLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolLocation: freezed == schoolLocation ? _self.schoolLocation : schoolLocation // ignore: cast_nullable_to_non_nullable
as String?,homeGeoLocation: freezed == homeGeoLocation ? _self.homeGeoLocation : homeGeoLocation // ignore: cast_nullable_to_non_nullable
as String?,schoolGeoLocation: freezed == schoolGeoLocation ? _self.schoolGeoLocation : schoolGeoLocation // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,pickupTime: freezed == pickupTime ? _self.pickupTime : pickupTime // ignore: cast_nullable_to_non_nullable
as String?,recurringDays: null == recurringDays ? _self._recurringDays : recurringDays // ignore: cast_nullable_to_non_nullable
as List<String>,proposalPrice: freezed == proposalPrice ? _self.proposalPrice : proposalPrice // ignore: cast_nullable_to_non_nullable
as dynamic,studentsInfo: null == studentsInfo ? _self._studentsInfo : studentsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,schoolsInfo: null == schoolsInfo ? _self._schoolsInfo : schoolsInfo // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,isMonthlySubscription: null == isMonthlySubscription ? _self.isMonthlySubscription : isMonthlySubscription // ignore: cast_nullable_to_non_nullable
as bool,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,isMultiSchool: null == isMultiSchool ? _self.isMultiSchool : isMultiSchool // ignore: cast_nullable_to_non_nullable
as bool,schoolName: freezed == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
