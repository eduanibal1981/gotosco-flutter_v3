import 'dart:async';

void main() async {
  print('Running synthetic benchmark for Chat Stream Filtering Optimization...');

  // Configuration
  // Scenario: A chat app with 10,000 total messages in the 'messages' table.
  // We want to fetch the 50 messages for a specific conversation.
  const int totalMessagesInTable = 10000;
  const int messagesInConversation = 50;

  // Average message size in JSON (ID, content, timestamps, UUIDs)
  const int messageSizeBytes = 300;

  // Network simulation (e.g., 4G or decent WiFi)
  // 5 MB/s = 5,000,000 bytes/s -> 0.0002 ms per byte
  const double networkMsPerByte = 0.0002;
  const int networkLatencyMs = 50; // RTT

  // 1. Baseline: Client-side filtering
  // The current implementation downloads the ENTIRE table stream (or a large chunk)
  // and filters it in memory.
  Future<int> measureBaseline() async {
    final stopwatch = Stopwatch()..start();

    print('  [Baseline] Downloading $totalMessagesInTable messages and filtering client-side...');

    // Simulate Network Download of ALL messages
    final totalBytes = totalMessagesInTable * messageSizeBytes;
    final downloadTimeMs = (totalBytes * networkMsPerByte).round();

    // Simulate async network delay
    await Future.delayed(Duration(milliseconds: networkLatencyMs + downloadTimeMs));

    // Simulate CPU Filtering Cost
    // Generating dummy data to filter
    final List<Map<String, dynamic>> data = List.generate(totalMessagesInTable, (i) {
      return {
        'id': 'msg_$i',
        'sender_id': i % 2 == 0 ? 'me' : 'other',
        'receiver_id': i % 2 == 0 ? 'other' : 'me',
        'content': 'Message content $i',
      };
    });

    // Actual filtering logic used in current code
    final myId = 'me';
    final otherUserId = 'other';

    // Note: In the real bad case, we might be iterating over messages from OTHER conversations too.
    // Let's assume only 1% of total messages are for THIS conversation to make it realistic.
    // So if total is 10,000, and 50 are ours, we iterate 10,000 and keep 50.

    final filtered = data.where((msg) {
        // Simulating logic: return (sender == myId && receiver == otherUserId) ...
        // To verify cost, we do some string comparisons
        final sender = msg['sender_id'];
        final receiver = msg['receiver_id'];
        return (sender == myId && receiver == otherUserId) ||
            (sender == otherUserId && receiver == myId);
    }).toList();

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  // 2. Optimized: Source-side filtering
  // The optimized implementation asks Supabase to filter by `conversation_id`.
  // It only downloads the relevant messages.
  Future<int> measureOptimized() async {
    final stopwatch = Stopwatch()..start();

    print('  [Optimized] Downloading $messagesInConversation messages (filtered at source)...');

    // Simulate Network Download of ONLY relevant messages
    final totalBytes = messagesInConversation * messageSizeBytes;
    final downloadTimeMs = (totalBytes * networkMsPerByte).round();

    // Simulate async network delay
    await Future.delayed(Duration(milliseconds: networkLatencyMs + downloadTimeMs));

    // No CPU filtering overhead (or negligible)

    stopwatch.stop();
    return stopwatch.elapsedMilliseconds;
  }

  final baselineMs = await measureBaseline();
  final optimizedMs = await measureOptimized();

  print('\nResults:');
  print('--------------------------------------------------');
  print('Baseline (Client-side): ${baselineMs} ms');
  print('Optimized (Source-side): ${optimizedMs} ms');

  final safeOptimizedMs = optimizedMs == 0 ? 1 : optimizedMs;
  final speedup = baselineMs / safeOptimizedMs;

  print('--------------------------------------------------');
  print('Improvement: ${baselineMs - optimizedMs} ms saved');
  print('Speedup: ${speedup.toStringAsFixed(1)}x faster');
}
