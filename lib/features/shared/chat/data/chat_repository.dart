import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/message_model.dart';

part 'chat_repository.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(Supabase.instance.client);
}

/// Stream provider to listen to messages for a specific chat
@riverpod
Stream<List<MessageModel>> chatStream(Ref ref, String otherUserId) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(otherUserId);
}

class ChatRepository {
  final SupabaseClient _supabase;
  ChatRepository(this._supabase);

  static bool? _hasConversationIdColumnCache;

  // Get Real-time Stream of Messages
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) async* {
    final myId = _supabase.auth.currentUser!.id;
    final conversationId = _getConversationId(myId, otherUserId);

    final hasConversationId = await _hasConversationIdColumn();

    Stream<List<Map<String, dynamic>>> rawStream;

    if (hasConversationId) {
      // Optimize: Filter server-side if conversation_id exists
      rawStream = _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
    } else {
      // Fallback: Download full table and filter client-side
      rawStream = _supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: true);
    }

    final mappedStream = rawStream.map((data) => data.map((e) => MessageModel.fromMap(e)).toList());

    await for (final messages in mappedStream) {
      if (hasConversationId) {
        yield messages;
      } else {
        final filtered = messages
            .where(
              (m) =>
                  (m.senderId == myId && m.receiverId == otherUserId) ||
                  (m.senderId == otherUserId && m.receiverId == myId),
            )
            .toList();
        yield filtered;
      }
    }
  }

  // Send Message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser!.id;
    final conversationId = _getConversationId(myId, receiverId);

    final hasConversationId = await _hasConversationIdColumn();
    final payload = {
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
      if (hasConversationId) 'conversation_id': conversationId,
    };

    await _supabase.from('messages').insert(payload);
  }

  String _getConversationId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }

  Future<bool> _hasConversationIdColumn() async {
    if (_hasConversationIdColumnCache != null) {
      return _hasConversationIdColumnCache!;
    }
    try {
      await _supabase.from('messages').select('conversation_id').limit(1);
      _hasConversationIdColumnCache = true;
    } catch (_) {
      _hasConversationIdColumnCache = false;
    }
    return _hasConversationIdColumnCache!;
  }
}
