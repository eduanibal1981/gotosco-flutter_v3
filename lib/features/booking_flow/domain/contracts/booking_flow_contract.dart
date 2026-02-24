import '../models/booking_flow_child_model.dart';
import '../models/booking_flow_school_model.dart';
import '../models/booking_flow_user_location_model.dart';

abstract class BookingFlowContract {
  Future<List<BookingFlowChildModel>> getMyChildren();

  Future<BookingFlowUserLocationModel?> getCurrentUserLocation();

  Future<List<BookingFlowSchoolModel>> getSchoolsByIds(List<String> schoolIds);

  Future<List<BookingFlowSchoolModel>> searchSchools(
    String query, {
    String? cityId,
  });
}
