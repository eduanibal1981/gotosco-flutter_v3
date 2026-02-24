import 'package:freezed_annotation/freezed_annotation.dart';

part 'school_location_model.freezed.dart';
part 'school_location_model.g.dart';

@freezed
abstract class SchoolLocationModel with _$SchoolLocationModel {
  const factory SchoolLocationModel({
    required String schoolId,
    required String schoolName,
    String? schoolAddress,
    double? latitude,
    double? longitude,
    @Default([]) List<String> studentIds,
    int? sequenceOrder,
  }) = _SchoolLocationModel;

  factory SchoolLocationModel.fromJson(Map<String, dynamic> json) =>
      _$SchoolLocationModelFromJson(json);
}
