import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bookingsRepositoryProvider = Provider(
  (ref) => BookingsRepository(Supabase.instance.client),
);

// Provider for Booking History
final myBookingsProvider = StreamProvider(
  (ref) => ref.watch(bookingsRepositoryProvider).getBookingsStream(),
);

class BookingsRepository {
  final SupabaseClient _supabase;
  BookingsRepository(this._supabase);

  // 1. Create a New Booking Request
  Future<void> createBooking({
    required String driverId,
    required List<String> childIds, // Support multiple children
    String? notes,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // Use a Database Transaction (creating booking + linking children)
    // Since Supabase generic client doesn't expose strict transaction blocks easily in Dart yet,
    // we chain the calls. If 'bookings' insert fails, nothing happens.

    // A. Insert Booking
    final bookingData = await _supabase
        .from('bookings')
        .insert({
          'parent_id': userId,
          'driver_id': driverId,
          'status': 'pending',
          'notes': notes,
        })
        .select()
        .single();

    final bookingId = bookingData['id'] as String;

    // B. Insert Children Links
    final childrenMap = childIds
        .map((childId) => {'booking_id': bookingId, 'child_id': childId})
        .toList();

    if (childrenMap.isNotEmpty) {
      await _supabase.from('booking_children').insert(childrenMap);
    }
  }

  // 2. Stream Booking History (Live Updates)
  Stream<List<Map<String, dynamic>>> getBookingsStream() {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((bookings) async {
          // Enrich data with Driver Info (Manual Join for Stream)
          // Note: In production, a View is better, but this works for MVPs
          final enriched = <Map<String, dynamic>>[];

          for (var booking in bookings) {
            // Fetch Driver Name
            final driver = await _supabase
                .from('users')
                .select('full_name, photo_url')
                .eq('id', booking['driver_id'])
                .single();

            // Fetch Involved Children Count
            final kidsCount = await _supabase
                .from('booking_children')
                .count(CountOption.exact)
                .eq('booking_id', booking['id']);

            enriched.add({
              ...booking,
              'driver_name': driver['full_name'],
              'driver_photo': driver['photo_url'],
              'kids_count': kidsCount,
            });
          }
          return enriched;
        });
  }
}
