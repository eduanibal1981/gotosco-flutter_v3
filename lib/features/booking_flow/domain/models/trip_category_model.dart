import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_category_model.freezed.dart';
part 'trip_category_model.g.dart';

/// Model for trip category options
@freezed
abstract class TripCategoryModel with _$TripCategoryModel {
  const TripCategoryModel._();

  const factory TripCategoryModel({
    required String id,
    required String label,
    required String icon,
    String? description,
  }) = _TripCategoryModel;

  factory TripCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TripCategoryModelFromJson(json);
}
