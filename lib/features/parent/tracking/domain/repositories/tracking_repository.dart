import 'package:latlong2/latlong.dart';
import '../models/driver_location_model.dart';
import '../models/booking_location_model.dart';
import '../models/parent_next_stop_info.dart';

abstract class TrackingRepository {
  Stream<DriverLocation?> getDriverLocationStream(String driverId);
  Future<DriverLocation?> getDriverLocation(String driverId);
  Future<BookingLocation?> getBookingLocations(String bookingId);
  Stream<Map<String, dynamic>?> streamLatestRideEvent(String bookingId);
  Future<ParentNextStopInfo?> getParentNextStopInfo(String bookingId);
  double? calculateEtaMinutes(DriverLocation driver, LatLng destination);
}
