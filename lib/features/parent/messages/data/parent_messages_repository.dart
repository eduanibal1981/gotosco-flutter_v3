import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'parent_messages_repository.g.dart';

/// Model for a conversation with a driver
class ParentConversationModel {
  final String driverId;
  final String driverName;
  final String? driverPhotoUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ParentConversationModel({
    required this.driverId,
    required this.driverName,
    this.driverPhotoUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}

@riverpod
ParentMessagesRepository parentMessagesRepository(Ref ref) {
  return ParentMessagesRepository(Supabase.instance.client);
}

/// Stream of conversations for the current parent
@riverpod
Stream<List<ParentConversationModel>> parentConversationsStream(Ref ref) {
  return ref.watch(parentMessagesRepositoryProvider).getConversationsStream();
}

class ParentMessagesRepository {
  final SupabaseClient _supabase;

  ParentMessagesRepository(this._supabase);

  String get _parentId => _supabase.auth.currentUser!.id;

  /// Get stream of all conversations with drivers
  /// Groups messages by driver and shows the latest message from each
  Stream<List<ParentConversationModel>> getConversationsStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((messages) {
          // Filter messages involving this parent
          final myMessages = messages.where((msg) {
            return msg['sender_id'] == _parentId ||
                msg['receiver_id'] == _parentId;
          }).toList();

          // Group by the OTHER user (driver)
          final Map<String, Map<String, dynamic>> conversationsMap = {};

          for (var msg in myMessages) {
            final isFromMe = msg['sender_id'] == _parentId;
            final driverId = isFromMe ? msg['receiver_id'] : msg['sender_id'];

            // Only keep the latest message per driver
            if (!conversationsMap.containsKey(driverId)) {
              final isUnread = !isFromMe && !(msg['is_read'] ?? false);
              conversationsMap[driverId] = {
                'driver_id': driverId,
                'last_message': msg['content'],
                'last_message_time': msg['created_at'],
                'unread_count': isUnread ? 1 : 0,
              };
            } else {
              // Count unread messages
              final isUnread = !isFromMe && !(msg['is_read'] ?? false);
              if (isUnread) {
                conversationsMap[driverId]!['unread_count'] =
                    (conversationsMap[driverId]!['unread_count'] ?? 0) + 1;
              }
            }
          }

          return conversationsMap.values.toList();
        })
        .asyncMap((conversationMaps) async {
          // Fetch driver details for each conversation
          final List<ParentConversationModel> conversations = [];

          for (var conv in conversationMaps) {
            try {
              final driverData = await _supabase
                  .from('users')
                  .select('full_name, photo_url')
                  .eq('id', conv['driver_id'])
                  .maybeSingle();

              conversations.add(
                ParentConversationModel(
                  driverId: conv['driver_id'],
                  driverName: driverData?['full_name'] ?? 'Driver',
                  driverPhotoUrl: driverData?['photo_url'],
                  lastMessage: conv['last_message'] ?? '',
                  lastMessageTime: DateTime.parse(conv['last_message_time']),
                  unreadCount: conv['unread_count'] ?? 0,
                ),
              );
            } catch (e) {
              // Add with default name if user fetch fails
              conversations.add(
                ParentConversationModel(
                  driverId: conv['driver_id'],
                  driverName: 'Driver',
                  driverPhotoUrl: null,
                  lastMessage: conv['last_message'] ?? '',
                  lastMessageTime: DateTime.parse(conv['last_message_time']),
                  unreadCount: conv['unread_count'] ?? 0,
                ),
              );
            }
          }

          // Sort by latest message time
          conversations.sort(
            (a, b) => b.lastMessageTime.compareTo(a.lastMessageTime),
          );
          return conversations;
        });
  }

  /// Mark all messages from a driver as read
  Future<void> markConversationAsRead(String driverId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', driverId)
        .eq('receiver_id', _parentId);
  }
}
