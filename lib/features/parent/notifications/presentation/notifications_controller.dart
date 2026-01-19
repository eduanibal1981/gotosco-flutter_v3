import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/notifications_repository.dart';

part 'notifications_controller.g.dart';

@riverpod
class NotificationsController extends _$NotificationsController {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String eventId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAsRead(eventId);
    });
  }

  Future<void> markAllAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationsRepositoryProvider).markAllAsRead();
    });
  }
}
