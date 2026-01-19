import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../bookings/data/bookings_repository.dart';

part 'parent_dashboard_repository.g.dart';

@riverpod
List<Map<String, dynamic>> parentTodayTrips(Ref ref) {
  final bookingsAsync = ref.watch(myBookingsProvider);
  return bookingsAsync.maybeWhen(
    data: _buildTripsFromBookings,
    orElse: () => <Map<String, dynamic>>[],
  );
}

List<Map<String, dynamic>> _buildTripsFromBookings(
  List<Map<String, dynamic>> bookings,
) {
  final trips = <Map<String, dynamic>>[];

  for (final booking in bookings) {
    final status = _mapBookingStatus(booking['status'] as String?);
    final bookingType = booking['booking_type'] as String? ?? '';
    final children =
        (booking['child_names'] as List?)?.cast<String>() ?? <String>[];

    final homeTime = booking['home_pickup_time'] as String?;
    final schoolTime = booking['school_pickup_time'] as String?;

    if (_includesPickup(bookingType) && homeTime != null) {
      trips.add({
        'time': _formatTime(homeTime),
        'status': status,
        'type': 'Pickup',
        'tripName': 'Home Pickup',
        'children': children,
      });
    }

    if (_includesDropoff(bookingType) && schoolTime != null) {
      trips.add({
        'time': _formatTime(schoolTime),
        'status': status,
        'type': 'Dropoff',
        'tripName': 'School Dropoff',
        'children': children,
      });
    }
  }

  trips.sort((a, b) => _timeToMinutes(a['time']).compareTo(
        _timeToMinutes(b['time']),
      ));

  return trips;
}

bool _includesPickup(String bookingType) {
  return bookingType == 'Two Way' || bookingType == 'One Way to School';
}

bool _includesDropoff(String bookingType) {
  return bookingType == 'Two Way' || bookingType == 'One Way Back Home';
}

String _mapBookingStatus(String? status) {
  switch (status) {
    case 'completed':
      return 'Done';
    case 'accepted':
      return 'Scheduled';
    case 'pending':
      return 'Pending';
    case 'cancelled':
      return 'Cancelled';
    default:
      return 'Scheduled';
  }
}

String _formatTime(String raw) {
  final parts = raw.split(':');
  if (parts.length < 2) return raw;
  final hour = parts[0].padLeft(2, '0');
  final minute = parts[1].padLeft(2, '0');
  return '$hour:$minute';
}

int _timeToMinutes(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return 24 * 60;
  final hour = int.tryParse(parts[0]) ?? 24;
  final minute = int.tryParse(parts[1]) ?? 60;
  return hour * 60 + minute;
}
