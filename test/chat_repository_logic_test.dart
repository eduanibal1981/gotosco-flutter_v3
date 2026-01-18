// Note: This test verifies the logic of conversation ID generation.
// It is intended to be run in an environment with the Dart SDK available.

import 'package:test/test.dart';

// Copy of the logic from ChatRepository for isolated testing
String getConversationId(String id1, String id2) {
  return id1.compareTo(id2) < 0 ? '${id1}_$id2' : '${id2}_$id1';
}

void main() {
  group('ChatRepository Conversation ID Logic', () {
    test('should generate consistent ID regardless of user order', () {
      final id1 = 'user_123';
      final id2 = 'user_456';

      final result1 = getConversationId(id1, id2);
      final result2 = getConversationId(id2, id1);

      // user_123 < user_456
      expect(result1, 'user_123_user_456');
      expect(result2, 'user_123_user_456');
    });

    test('should handle UUIDs correctly', () {
      final uuid1 = '11111111-1111-1111-1111-111111111111';
      final uuid2 = '22222222-2222-2222-2222-222222222222';

      final result = getConversationId(uuid2, uuid1);
      expect(result, '$uuid1\_$uuid2');
    });

    test('should handle identical IDs (self-chat)', () {
      final id = 'user_same';
      final result = getConversationId(id, id);
      expect(result, 'user_same_user_same');
    });
  });
}
