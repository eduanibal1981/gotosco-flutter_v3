import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/parent_notification_model.dart';

part 'notifications_repository.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(Supabase.instance.client);
}

@riverpod
Stream<List<Map<String, dynamic>>> parentNotificationsStream(Ref ref) {
  return ref.watch(notificationsRepositoryProvider).streamNotifications();
}

@riverpod
Future<List<Map<String, dynamic>>> parentNotificationsOnce(Ref ref) {
  return ref.watch(notificationsRepositoryProvider).fetchNotifications();
}

@riverpod
Stream<int> parentUnreadNotificationsCount(Ref ref) {
  return ref
      .watch(notificationsRepositoryProvider)
      .streamNotifications()
      .map((items) => items.where((e) => e['read_at'] == null).length);
}

class NotificationsRepository {
  final SupabaseClient _supabase;

  NotificationsRepository(this._supabase);

  /// ✅ HYBRID: Stream typed notifications
  /// Fetches from view on change.
  Stream<List<ParentNotification>> streamParentNotifications() async* {
    // 1. Initial fetch
    yield await getParentNotifications();

    // 2. Subscribe to changes on base table
    final userId = _supabase.auth.currentUser!.id;
    final stream = _supabase
        .from('ride_events')
        .stream(primaryKey: ['id'])
        .eq('parent_id', userId)
        .order('created_at', ascending: false);

    // 3. Re-fetch on change
    // Note: This ignores the data in the stream event and re-fetches from view.
    // This ensures we always have the joined data.
    await for (final _ in stream) {
      yield await getParentNotifications();
    }
  }

  Stream<List<Map<String, dynamic>>> streamNotifications() {
    return streamParentNotifications().map(
      (list) => list.map((e) => e.toLegacyMap()).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final notifications = await getParentNotifications();
    return notifications.map((e) => e.toLegacyMap()).toList();
  }

  /// ✅ HYBRID: Fetch typed notifications from View
  Future<List<ParentNotification>> getParentNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('parent_notifications_view')
        .select()
        .eq('parent_id', userId)
        .order(
          'created_at',
          ascending: false,
        ); // View should support ordering if columns match

    return (data as List).map((e) => ParentNotification.fromJson(e)).toList();
  }

  Future<void> markAsRead(String eventId) async {
    await _supabase
        .from('ride_events')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', eventId);
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('ride_events')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('parent_id', userId)
        .isFilter('read_at', null);
  }
}
