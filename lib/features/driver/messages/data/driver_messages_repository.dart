// lib/features/driver/messages/data/driver_messages_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'driver_messages_repository.g.dart';

/// Model for a conversation with a parent
class ConversationModel {
  final String parentId;
  final String parentName;
  final String? parentPhotoUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.parentId,
    required this.parentName,
    this.parentPhotoUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      parentId: map['parent_id'] ?? '',
      parentName: map['parent_name'] ?? 'Parent',
      parentPhotoUrl: map['parent_photo_url'],
      lastMessage: map['last_message'] ?? '',
      lastMessageTime: DateTime.parse(map['last_message_time']),
      unreadCount: map['unread_count'] ?? 0,
    );
  }
}

@riverpod
DriverMessagesRepository driverMessagesRepository(Ref ref) {
  return DriverMessagesRepository(Supabase.instance.client);
}

/// Stream of conversations for the current driver
@riverpod
Stream<List<ConversationModel>> driverConversationsStream(Ref ref) {
  return ref.watch(driverMessagesRepositoryProvider).getConversationsStream();
}

class DriverMessagesRepository {
  final SupabaseClient _supabase;

  DriverMessagesRepository(this._supabase);

  String get _driverId => _supabase.auth.currentUser!.id;

  /// Get stream of all conversations with parents
  /// Groups messages by parent and shows the latest message from each
  Stream<List<ConversationModel>> getConversationsStream() {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((messages) {
          // Filter messages involving this driver
          final myMessages = messages.where((msg) {
            return msg['sender_id'] == _driverId ||
                msg['receiver_id'] == _driverId;
          }).toList();

          // Group by the OTHER user (parent)
          final Map<String, Map<String, dynamic>> conversationsMap = {};

          for (var msg in myMessages) {
            final isFromMe = msg['sender_id'] == _driverId;
            final parentId = isFromMe ? msg['receiver_id'] : msg['sender_id'];

            // Only keep the latest message per parent
            if (!conversationsMap.containsKey(parentId)) {
              final isUnread = !isFromMe && !(msg['is_read'] ?? false);
              conversationsMap[parentId] = {
                'parent_id': parentId,
                'last_message': msg['content'],
                'last_message_time': msg['created_at'],
                'unread_count': isUnread ? 1 : 0,
              };
            } else {
              // Count unread messages
              final isUnread = !isFromMe && !(msg['is_read'] ?? false);
              if (isUnread) {
                conversationsMap[parentId]!['unread_count'] =
                    (conversationsMap[parentId]!['unread_count'] ?? 0) + 1;
              }
            }
          }

          return conversationsMap.values.toList();
        })
        .asyncMap((conversationMaps) async {
          // Fetch parent details for each conversation
          final List<ConversationModel> conversations = [];

          for (var conv in conversationMaps) {
            try {
              final parentData = await _supabase
                  .from('users')
                  .select('full_name, photo_url')
                  .eq('id', conv['parent_id'])
                  .maybeSingle();

              conversations.add(
                ConversationModel(
                  parentId: conv['parent_id'],
                  parentName: parentData?['full_name'] ?? 'Parent',
                  parentPhotoUrl: parentData?['photo_url'],
                  lastMessage: conv['last_message'] ?? '',
                  lastMessageTime: DateTime.parse(conv['last_message_time']),
                  unreadCount: conv['unread_count'] ?? 0,
                ),
              );
            } catch (e) {
              // Add with default name if user fetch fails
              conversations.add(
                ConversationModel(
                  parentId: conv['parent_id'],
                  parentName: 'Parent',
                  parentPhotoUrl: null,
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

  /// Mark all messages from a parent as read
  Future<void> markConversationAsRead(String parentId) async {
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', parentId)
        .eq('receiver_id', _driverId);
  }
}
