import '../models/tracking_view_model.dart';
import '../models/booking_location_model.dart';
import '../models/parent_next_stop_info.dart';

abstract class TrackingContract {
  Stream<TrackingViewModel?> getDriverLocationStream(String driverId);

  Future<BookingLocation?> getBookingLocations(String bookingId);
  Stream<Map<String, dynamic>?> streamLatestRideEvent(String bookingId);
  Future<ParentNextStopInfo?> getParentNextStopInfo(String bookingId);
}
