// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_model.freezed.dart';
part 'school_model.g.dart';

@freezed
abstract class SchoolModel with _$SchoolModel {
  const factory SchoolModel({
    required String id,
    required String name,
    String? address,
    @JsonKey(name: 'city_id') String? cityId,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'createdby') String? createdBy,
  }) = _SchoolModel;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);
}
