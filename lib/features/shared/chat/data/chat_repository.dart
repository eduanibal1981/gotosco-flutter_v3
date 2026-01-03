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

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true) // Oldest first
        .map((data) {
          // Filter in Dart because Supabase Stream filtering is limited
          // We want messages between ME and THE OTHER PERSON
          return data
              .where((msg) {
                final sender = msg['sender_id'];
                final receiver = msg['receiver_id'];
                return (sender == myId && receiver == otherUserId) ||
                    (sender == otherUserId && receiver == myId);
              })
              .map((e) => MessageModel.fromMap(e))
              .toList();
        });
  }

  // Send Message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser!.id;

    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
    });
  }
}
