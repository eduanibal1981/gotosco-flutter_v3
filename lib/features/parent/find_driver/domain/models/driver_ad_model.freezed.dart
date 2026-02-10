// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_ad_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverAdModel {

@JsonKey(name: 'driver_id') String get driverId; String get name;@JsonKey(name: 'photo_url') String? get photoUrl; String get gender;@JsonKey(name: 'vehicle_type') String get vehicleType; double get rating;@JsonKey(name: 'total_reviews') int get totalReviews;@JsonKey(name: 'price_monthly_two_way') double get priceMonthlyTwoWay;@JsonKey(name: 'is_verified') bool get isVerified; String get bio; String get phone;@JsonKey(name: 'is_online') bool get isOnline;@JsonKey(name: 'distance_km') double? get distanceKm; List<String> get coveredSchools; List<String> get coveredAreas;@JsonKey(name: 'vehicle_capacity') int get vehicleCapacity; Map<String, double> get otherPrices; List<String> get adPhotos;
/// Create a copy of DriverAdModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverAdModelCopyWith<DriverAdModel> get copyWith => _$DriverAdModelCopyWithImpl<DriverAdModel>(this as DriverAdModel, _$identity);

  /// Serializes this DriverAdModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverAdModel&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.priceMonthlyTwoWay, priceMonthlyTwoWay) || other.priceMonthlyTwoWay == priceMonthlyTwoWay)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other.coveredSchools, coveredSchools)&&const DeepCollectionEquality().equals(other.coveredAreas, coveredAreas)&&(identical(other.vehicleCapacity, vehicleCapacity) || other.vehicleCapacity == vehicleCapacity)&&const DeepCollectionEquality().equals(other.otherPrices, otherPrices)&&const DeepCollectionEquality().equals(other.adPhotos, adPhotos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,name,photoUrl,gender,vehicleType,rating,totalReviews,priceMonthlyTwoWay,isVerified,bio,phone,isOnline,distanceKm,const DeepCollectionEquality().hash(coveredSchools),const DeepCollectionEquality().hash(coveredAreas),vehicleCapacity,const DeepCollectionEquality().hash(otherPrices),const DeepCollectionEquality().hash(adPhotos));

@override
String toString() {
  return 'DriverAdModel(driverId: $driverId, name: $name, photoUrl: $photoUrl, gender: $gender, vehicleType: $vehicleType, rating: $rating, totalReviews: $totalReviews, priceMonthlyTwoWay: $priceMonthlyTwoWay, isVerified: $isVerified, bio: $bio, phone: $phone, isOnline: $isOnline, distanceKm: $distanceKm, coveredSchools: $coveredSchools, coveredAreas: $coveredAreas, vehicleCapacity: $vehicleCapacity, otherPrices: $otherPrices, adPhotos: $adPhotos)';
}


}

/// @nodoc
abstract mixin class $DriverAdModelCopyWith<$Res>  {
  factory $DriverAdModelCopyWith(DriverAdModel value, $Res Function(DriverAdModel) _then) = _$DriverAdModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId, String name,@JsonKey(name: 'photo_url') String? photoUrl, String gender,@JsonKey(name: 'vehicle_type') String vehicleType, double rating,@JsonKey(name: 'total_reviews') int totalReviews,@JsonKey(name: 'price_monthly_two_way') double priceMonthlyTwoWay,@JsonKey(name: 'is_verified') bool isVerified, String bio, String phone,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'distance_km') double? distanceKm, List<String> coveredSchools, List<String> coveredAreas,@JsonKey(name: 'vehicle_capacity') int vehicleCapacity, Map<String, double> otherPrices, List<String> adPhotos
});




}
/// @nodoc
class _$DriverAdModelCopyWithImpl<$Res>
    implements $DriverAdModelCopyWith<$Res> {
  _$DriverAdModelCopyWithImpl(this._self, this._then);

  final DriverAdModel _self;
  final $Res Function(DriverAdModel) _then;

/// Create a copy of DriverAdModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? driverId = null,Object? name = null,Object? photoUrl = freezed,Object? gender = null,Object? vehicleType = null,Object? rating = null,Object? totalReviews = null,Object? priceMonthlyTwoWay = null,Object? isVerified = null,Object? bio = null,Object? phone = null,Object? isOnline = null,Object? distanceKm = freezed,Object? coveredSchools = null,Object? coveredAreas = null,Object? vehicleCapacity = null,Object? otherPrices = null,Object? adPhotos = null,}) {
  return _then(_self.copyWith(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,priceMonthlyTwoWay: null == priceMonthlyTwoWay ? _self.priceMonthlyTwoWay : priceMonthlyTwoWay // ignore: cast_nullable_to_non_nullable
as double,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,coveredSchools: null == coveredSchools ? _self.coveredSchools : coveredSchools // ignore: cast_nullable_to_non_nullable
as List<String>,coveredAreas: null == coveredAreas ? _self.coveredAreas : coveredAreas // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleCapacity: null == vehicleCapacity ? _self.vehicleCapacity : vehicleCapacity // ignore: cast_nullable_to_non_nullable
as int,otherPrices: null == otherPrices ? _self.otherPrices : otherPrices // ignore: cast_nullable_to_non_nullable
as Map<String, double>,adPhotos: null == adPhotos ? _self.adPhotos : adPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverAdModel].
extension DriverAdModelPatterns on DriverAdModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverAdModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverAdModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverAdModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverAdModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverAdModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverAdModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId,  String name, @JsonKey(name: 'photo_url')  String? photoUrl,  String gender, @JsonKey(name: 'vehicle_type')  String vehicleType,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'is_verified')  bool isVerified,  String bio,  String phone, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'distance_km')  double? distanceKm,  List<String> coveredSchools,  List<String> coveredAreas, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity,  Map<String, double> otherPrices,  List<String> adPhotos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverAdModel() when $default != null:
return $default(_that.driverId,_that.name,_that.photoUrl,_that.gender,_that.vehicleType,_that.rating,_that.totalReviews,_that.priceMonthlyTwoWay,_that.isVerified,_that.bio,_that.phone,_that.isOnline,_that.distanceKm,_that.coveredSchools,_that.coveredAreas,_that.vehicleCapacity,_that.otherPrices,_that.adPhotos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'driver_id')  String driverId,  String name, @JsonKey(name: 'photo_url')  String? photoUrl,  String gender, @JsonKey(name: 'vehicle_type')  String vehicleType,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'is_verified')  bool isVerified,  String bio,  String phone, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'distance_km')  double? distanceKm,  List<String> coveredSchools,  List<String> coveredAreas, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity,  Map<String, double> otherPrices,  List<String> adPhotos)  $default,) {final _that = this;
switch (_that) {
case _DriverAdModel():
return $default(_that.driverId,_that.name,_that.photoUrl,_that.gender,_that.vehicleType,_that.rating,_that.totalReviews,_that.priceMonthlyTwoWay,_that.isVerified,_that.bio,_that.phone,_that.isOnline,_that.distanceKm,_that.coveredSchools,_that.coveredAreas,_that.vehicleCapacity,_that.otherPrices,_that.adPhotos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'driver_id')  String driverId,  String name, @JsonKey(name: 'photo_url')  String? photoUrl,  String gender, @JsonKey(name: 'vehicle_type')  String vehicleType,  double rating, @JsonKey(name: 'total_reviews')  int totalReviews, @JsonKey(name: 'price_monthly_two_way')  double priceMonthlyTwoWay, @JsonKey(name: 'is_verified')  bool isVerified,  String bio,  String phone, @JsonKey(name: 'is_online')  bool isOnline, @JsonKey(name: 'distance_km')  double? distanceKm,  List<String> coveredSchools,  List<String> coveredAreas, @JsonKey(name: 'vehicle_capacity')  int vehicleCapacity,  Map<String, double> otherPrices,  List<String> adPhotos)?  $default,) {final _that = this;
switch (_that) {
case _DriverAdModel() when $default != null:
return $default(_that.driverId,_that.name,_that.photoUrl,_that.gender,_that.vehicleType,_that.rating,_that.totalReviews,_that.priceMonthlyTwoWay,_that.isVerified,_that.bio,_that.phone,_that.isOnline,_that.distanceKm,_that.coveredSchools,_that.coveredAreas,_that.vehicleCapacity,_that.otherPrices,_that.adPhotos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverAdModel extends DriverAdModel {
  const _DriverAdModel({@JsonKey(name: 'driver_id') required this.driverId, this.name = 'Driver', @JsonKey(name: 'photo_url') this.photoUrl, this.gender = 'male', @JsonKey(name: 'vehicle_type') this.vehicleType = '', this.rating = 0.0, @JsonKey(name: 'total_reviews') this.totalReviews = 0, @JsonKey(name: 'price_monthly_two_way') this.priceMonthlyTwoWay = 0.0, @JsonKey(name: 'is_verified') this.isVerified = false, this.bio = '', this.phone = '', @JsonKey(name: 'is_online') this.isOnline = false, @JsonKey(name: 'distance_km') this.distanceKm, final  List<String> coveredSchools = const [], final  List<String> coveredAreas = const [], @JsonKey(name: 'vehicle_capacity') this.vehicleCapacity = 0, final  Map<String, double> otherPrices = const {}, final  List<String> adPhotos = const []}): _coveredSchools = coveredSchools,_coveredAreas = coveredAreas,_otherPrices = otherPrices,_adPhotos = adPhotos,super._();
  factory _DriverAdModel.fromJson(Map<String, dynamic> json) => _$DriverAdModelFromJson(json);

@override@JsonKey(name: 'driver_id') final  String driverId;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'photo_url') final  String? photoUrl;
@override@JsonKey() final  String gender;
@override@JsonKey(name: 'vehicle_type') final  String vehicleType;
@override@JsonKey() final  double rating;
@override@JsonKey(name: 'total_reviews') final  int totalReviews;
@override@JsonKey(name: 'price_monthly_two_way') final  double priceMonthlyTwoWay;
@override@JsonKey(name: 'is_verified') final  bool isVerified;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String phone;
@override@JsonKey(name: 'is_online') final  bool isOnline;
@override@JsonKey(name: 'distance_km') final  double? distanceKm;
 final  List<String> _coveredSchools;
@override@JsonKey() List<String> get coveredSchools {
  if (_coveredSchools is EqualUnmodifiableListView) return _coveredSchools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coveredSchools);
}

 final  List<String> _coveredAreas;
@override@JsonKey() List<String> get coveredAreas {
  if (_coveredAreas is EqualUnmodifiableListView) return _coveredAreas;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coveredAreas);
}

@override@JsonKey(name: 'vehicle_capacity') final  int vehicleCapacity;
 final  Map<String, double> _otherPrices;
@override@JsonKey() Map<String, double> get otherPrices {
  if (_otherPrices is EqualUnmodifiableMapView) return _otherPrices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_otherPrices);
}

 final  List<String> _adPhotos;
@override@JsonKey() List<String> get adPhotos {
  if (_adPhotos is EqualUnmodifiableListView) return _adPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adPhotos);
}


/// Create a copy of DriverAdModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverAdModelCopyWith<_DriverAdModel> get copyWith => __$DriverAdModelCopyWithImpl<_DriverAdModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverAdModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverAdModel&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.name, name) || other.name == name)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.priceMonthlyTwoWay, priceMonthlyTwoWay) || other.priceMonthlyTwoWay == priceMonthlyTwoWay)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&const DeepCollectionEquality().equals(other._coveredSchools, _coveredSchools)&&const DeepCollectionEquality().equals(other._coveredAreas, _coveredAreas)&&(identical(other.vehicleCapacity, vehicleCapacity) || other.vehicleCapacity == vehicleCapacity)&&const DeepCollectionEquality().equals(other._otherPrices, _otherPrices)&&const DeepCollectionEquality().equals(other._adPhotos, _adPhotos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,driverId,name,photoUrl,gender,vehicleType,rating,totalReviews,priceMonthlyTwoWay,isVerified,bio,phone,isOnline,distanceKm,const DeepCollectionEquality().hash(_coveredSchools),const DeepCollectionEquality().hash(_coveredAreas),vehicleCapacity,const DeepCollectionEquality().hash(_otherPrices),const DeepCollectionEquality().hash(_adPhotos));

@override
String toString() {
  return 'DriverAdModel(driverId: $driverId, name: $name, photoUrl: $photoUrl, gender: $gender, vehicleType: $vehicleType, rating: $rating, totalReviews: $totalReviews, priceMonthlyTwoWay: $priceMonthlyTwoWay, isVerified: $isVerified, bio: $bio, phone: $phone, isOnline: $isOnline, distanceKm: $distanceKm, coveredSchools: $coveredSchools, coveredAreas: $coveredAreas, vehicleCapacity: $vehicleCapacity, otherPrices: $otherPrices, adPhotos: $adPhotos)';
}


}

/// @nodoc
abstract mixin class _$DriverAdModelCopyWith<$Res> implements $DriverAdModelCopyWith<$Res> {
  factory _$DriverAdModelCopyWith(_DriverAdModel value, $Res Function(_DriverAdModel) _then) = __$DriverAdModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'driver_id') String driverId, String name,@JsonKey(name: 'photo_url') String? photoUrl, String gender,@JsonKey(name: 'vehicle_type') String vehicleType, double rating,@JsonKey(name: 'total_reviews') int totalReviews,@JsonKey(name: 'price_monthly_two_way') double priceMonthlyTwoWay,@JsonKey(name: 'is_verified') bool isVerified, String bio, String phone,@JsonKey(name: 'is_online') bool isOnline,@JsonKey(name: 'distance_km') double? distanceKm, List<String> coveredSchools, List<String> coveredAreas,@JsonKey(name: 'vehicle_capacity') int vehicleCapacity, Map<String, double> otherPrices, List<String> adPhotos
});




}
/// @nodoc
class __$DriverAdModelCopyWithImpl<$Res>
    implements _$DriverAdModelCopyWith<$Res> {
  __$DriverAdModelCopyWithImpl(this._self, this._then);

  final _DriverAdModel _self;
  final $Res Function(_DriverAdModel) _then;

/// Create a copy of DriverAdModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? driverId = null,Object? name = null,Object? photoUrl = freezed,Object? gender = null,Object? vehicleType = null,Object? rating = null,Object? totalReviews = null,Object? priceMonthlyTwoWay = null,Object? isVerified = null,Object? bio = null,Object? phone = null,Object? isOnline = null,Object? distanceKm = freezed,Object? coveredSchools = null,Object? coveredAreas = null,Object? vehicleCapacity = null,Object? otherPrices = null,Object? adPhotos = null,}) {
  return _then(_DriverAdModel(
driverId: null == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String,vehicleType: null == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,priceMonthlyTwoWay: null == priceMonthlyTwoWay ? _self.priceMonthlyTwoWay : priceMonthlyTwoWay // ignore: cast_nullable_to_non_nullable
as double,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,coveredSchools: null == coveredSchools ? _self._coveredSchools : coveredSchools // ignore: cast_nullable_to_non_nullable
as List<String>,coveredAreas: null == coveredAreas ? _self._coveredAreas : coveredAreas // ignore: cast_nullable_to_non_nullable
as List<String>,vehicleCapacity: null == vehicleCapacity ? _self.vehicleCapacity : vehicleCapacity // ignore: cast_nullable_to_non_nullable
as int,otherPrices: null == otherPrices ? _self._otherPrices : otherPrices // ignore: cast_nullable_to_non_nullable
as Map<String, double>,adPhotos: null == adPhotos ? _self._adPhotos : adPhotos // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
