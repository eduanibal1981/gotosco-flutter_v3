import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../parent/bookings/data/bookings_repository.dart';

part 'booking_flow_bookings_provider.g.dart';

@riverpod
BookingsRepository bookingFlowBookingsRepository(Ref ref) {
  return ref.watch(bookingsRepositoryProvider);
}

@riverpod
Stream<List<Map<String, dynamic>>> bookingFlowMyBookings(Ref ref) {
  return myBookings(ref);
}
