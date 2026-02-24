import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_model.freezed.dart';
part 'school_model.g.dart';

@freezed
abstract class SchoolModel with _$SchoolModel {
  const factory SchoolModel({
    required String id,
    required String cityId,
    required String name,
    String? address,
    double? latitude,
    double? longitude,
  }) = _SchoolModel;

  factory SchoolModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolModelFromJson(json);
}
