// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_flow_child_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookingFlowChildModel {

 String get id; String get name; String get schoolName; String get grade; String? get photoUrl; String? get gender; DateTime? get dob; String? get medicalConditions; String? get notes; String? get schoolId; String? get cityName;
/// Create a copy of BookingFlowChildModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingFlowChildModelCopyWith<BookingFlowChildModel> get copyWith => _$BookingFlowChildModelCopyWithImpl<BookingFlowChildModel>(this as BookingFlowChildModel, _$identity);

  /// Serializes this BookingFlowChildModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookingFlowChildModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.medicalConditions, medicalConditions) || other.medicalConditions == medicalConditions)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.cityName, cityName) || other.cityName == cityName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,schoolName,grade,photoUrl,gender,dob,medicalConditions,notes,schoolId,cityName);

@override
String toString() {
  return 'BookingFlowChildModel(id: $id, name: $name, schoolName: $schoolName, grade: $grade, photoUrl: $photoUrl, gender: $gender, dob: $dob, medicalConditions: $medicalConditions, notes: $notes, schoolId: $schoolId, cityName: $cityName)';
}


}

/// @nodoc
abstract mixin class $BookingFlowChildModelCopyWith<$Res>  {
  factory $BookingFlowChildModelCopyWith(BookingFlowChildModel value, $Res Function(BookingFlowChildModel) _then) = _$BookingFlowChildModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String schoolName, String grade, String? photoUrl, String? gender, DateTime? dob, String? medicalConditions, String? notes, String? schoolId, String? cityName
});




}
/// @nodoc
class _$BookingFlowChildModelCopyWithImpl<$Res>
    implements $BookingFlowChildModelCopyWith<$Res> {
  _$BookingFlowChildModelCopyWithImpl(this._self, this._then);

  final BookingFlowChildModel _self;
  final $Res Function(BookingFlowChildModel) _then;

/// Create a copy of BookingFlowChildModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? schoolName = null,Object? grade = null,Object? photoUrl = freezed,Object? gender = freezed,Object? dob = freezed,Object? medicalConditions = freezed,Object? notes = freezed,Object? schoolId = freezed,Object? cityName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BookingFlowChildModel].
extension BookingFlowChildModelPatterns on BookingFlowChildModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookingFlowChildModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookingFlowChildModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookingFlowChildModel value)  $default,){
final _that = this;
switch (_that) {
case _BookingFlowChildModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookingFlowChildModel value)?  $default,){
final _that = this;
switch (_that) {
case _BookingFlowChildModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String schoolName,  String grade,  String? photoUrl,  String? gender,  DateTime? dob,  String? medicalConditions,  String? notes,  String? schoolId,  String? cityName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookingFlowChildModel() when $default != null:
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.photoUrl,_that.gender,_that.dob,_that.medicalConditions,_that.notes,_that.schoolId,_that.cityName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String schoolName,  String grade,  String? photoUrl,  String? gender,  DateTime? dob,  String? medicalConditions,  String? notes,  String? schoolId,  String? cityName)  $default,) {final _that = this;
switch (_that) {
case _BookingFlowChildModel():
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.photoUrl,_that.gender,_that.dob,_that.medicalConditions,_that.notes,_that.schoolId,_that.cityName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String schoolName,  String grade,  String? photoUrl,  String? gender,  DateTime? dob,  String? medicalConditions,  String? notes,  String? schoolId,  String? cityName)?  $default,) {final _that = this;
switch (_that) {
case _BookingFlowChildModel() when $default != null:
return $default(_that.id,_that.name,_that.schoolName,_that.grade,_that.photoUrl,_that.gender,_that.dob,_that.medicalConditions,_that.notes,_that.schoolId,_that.cityName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookingFlowChildModel implements BookingFlowChildModel {
  const _BookingFlowChildModel({required this.id, required this.name, this.schoolName = '', this.grade = '', this.photoUrl, this.gender, this.dob, this.medicalConditions, this.notes, this.schoolId, this.cityName});
  factory _BookingFlowChildModel.fromJson(Map<String, dynamic> json) => _$BookingFlowChildModelFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String schoolName;
@override@JsonKey() final  String grade;
@override final  String? photoUrl;
@override final  String? gender;
@override final  DateTime? dob;
@override final  String? medicalConditions;
@override final  String? notes;
@override final  String? schoolId;
@override final  String? cityName;

/// Create a copy of BookingFlowChildModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingFlowChildModelCopyWith<_BookingFlowChildModel> get copyWith => __$BookingFlowChildModelCopyWithImpl<_BookingFlowChildModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookingFlowChildModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookingFlowChildModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dob, dob) || other.dob == dob)&&(identical(other.medicalConditions, medicalConditions) || other.medicalConditions == medicalConditions)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.cityName, cityName) || other.cityName == cityName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,schoolName,grade,photoUrl,gender,dob,medicalConditions,notes,schoolId,cityName);

@override
String toString() {
  return 'BookingFlowChildModel(id: $id, name: $name, schoolName: $schoolName, grade: $grade, photoUrl: $photoUrl, gender: $gender, dob: $dob, medicalConditions: $medicalConditions, notes: $notes, schoolId: $schoolId, cityName: $cityName)';
}


}

/// @nodoc
abstract mixin class _$BookingFlowChildModelCopyWith<$Res> implements $BookingFlowChildModelCopyWith<$Res> {
  factory _$BookingFlowChildModelCopyWith(_BookingFlowChildModel value, $Res Function(_BookingFlowChildModel) _then) = __$BookingFlowChildModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String schoolName, String grade, String? photoUrl, String? gender, DateTime? dob, String? medicalConditions, String? notes, String? schoolId, String? cityName
});




}
/// @nodoc
class __$BookingFlowChildModelCopyWithImpl<$Res>
    implements _$BookingFlowChildModelCopyWith<$Res> {
  __$BookingFlowChildModelCopyWithImpl(this._self, this._then);

  final _BookingFlowChildModel _self;
  final $Res Function(_BookingFlowChildModel) _then;

/// Create a copy of BookingFlowChildModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? schoolName = null,Object? grade = null,Object? photoUrl = freezed,Object? gender = freezed,Object? dob = freezed,Object? medicalConditions = freezed,Object? notes = freezed,Object? schoolId = freezed,Object? cityName = freezed,}) {
  return _then(_BookingFlowChildModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dob: freezed == dob ? _self.dob : dob // ignore: cast_nullable_to_non_nullable
as DateTime?,medicalConditions: freezed == medicalConditions ? _self.medicalConditions : medicalConditions // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,schoolId: freezed == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String?,cityName: freezed == cityName ? _self.cityName : cityName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
