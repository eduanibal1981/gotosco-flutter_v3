import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_flow_school_model.freezed.dart';
part 'booking_flow_school_model.g.dart';

@freezed
abstract class BookingFlowSchoolModel with _$BookingFlowSchoolModel {
  const factory BookingFlowSchoolModel({
    required String id,
    required String name,
    String? address,
    String? cityId,
    double? latitude,
    double? longitude,
  }) = _BookingFlowSchoolModel;

  factory BookingFlowSchoolModel.fromJson(Map<String, dynamic> json) =>
      _$BookingFlowSchoolModelFromJson(json);
}
