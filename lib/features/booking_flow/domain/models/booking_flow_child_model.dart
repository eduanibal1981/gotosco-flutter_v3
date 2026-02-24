import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_flow_child_model.freezed.dart';
part 'booking_flow_child_model.g.dart';

@freezed
abstract class BookingFlowChildModel with _$BookingFlowChildModel {
  const factory BookingFlowChildModel({
    required String id,
    required String name,
    @Default('') String schoolName,
    @Default('') String grade,
    String? photoUrl,
    String? gender,
    DateTime? dob,
    String? medicalConditions,
    String? notes,
    String? schoolId,
    String? cityName,
  }) = _BookingFlowChildModel;

  factory BookingFlowChildModel.fromJson(Map<String, dynamic> json) =>
      _$BookingFlowChildModelFromJson(json);
}
