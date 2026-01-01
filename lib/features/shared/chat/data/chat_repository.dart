import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'message_model.dart';

final chatRepositoryProvider = Provider((ref) {
  return ChatRepository(Supabase.instance.client);
});

// Stream provider to listen to messages for a specific chat
final chatStreamProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  otherUserId,
) {
  return ref.watch(chatRepositoryProvider).getMessagesStream(otherUserId);
});

class ChatRepository {
  final SupabaseClient _supabase;
  ChatRepository(this._supabase);

  // 1. Get Real-time Stream of Messages
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

  // 2. Send Message
  Future<void> sendMessage(String receiverId, String content) async {
    final myId = _supabase.auth.currentUser!.id;

    await _supabase.from('messages').insert({
      'sender_id': myId,
      'receiver_id': receiverId,
      'content': content,
    });
  }
}
