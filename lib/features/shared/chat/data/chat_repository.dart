import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'message_model.dart';

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

  // Get Real-time Stream of Messages
  Stream<List<MessageModel>> getMessagesStream(String otherUserId) {
    final myId = _supabase.auth.currentUser!.id;
    final conversationId = _getConversationId(myId, otherUserId);

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true) // Oldest first
        .map((data) {
          return data.map((e) => MessageModel.fromMap(e)).toList();
        });
  }

  // Send Message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser!.id;
    final conversationId = _getConversationId(myId, receiverId);

    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'conversation_id': conversationId,
      'content': content,
    });
  }

  String _getConversationId(String id1, String id2) {
    return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
  }
}
