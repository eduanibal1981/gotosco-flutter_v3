import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_flow_user_location_model.freezed.dart';
part 'booking_flow_user_location_model.g.dart';

@freezed
abstract class BookingFlowUserLocationModel
    with _$BookingFlowUserLocationModel {
  const factory BookingFlowUserLocationModel({
    String? locationText,
    double? locationLat,
    double? locationLng,
  }) = _BookingFlowUserLocationModel;

  factory BookingFlowUserLocationModel.fromJson(Map<String, dynamic> json) =>
      _$BookingFlowUserLocationModelFromJson(json);
}
