import 'dart:async';

Future<void> main() async {
  print('Running synthetic benchmark for AuthRepository optimization...');

  // Simulate network latency (e.g., 50ms per round trip)
  const networkLatency = Duration(milliseconds: 50);

  // Baseline: getUserProfile + _createPublicProfile (if needed)
  // Worst case: User doesn't exist (2 calls)
  // Best case: User exists (1 call - getUserProfile)
  // But the optimization targets the "Login" flow where we want to ensure profile exists.
  // The original code:
  // final existingProfile = await getUserProfile(response.user!.id);
  // if (existingProfile == null) { await _createPublicProfile(...) }

  Future<Duration> measureBaseline_NewUser() async {
    final stopwatch = Stopwatch()..start();
    // 1. getUserProfile
    await Future.delayed(networkLatency);
    // 2. _createPublicProfile
    await Future.delayed(networkLatency);
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  Future<Duration> measureBaseline_ExistingUser() async {
    final stopwatch = Stopwatch()..start();
    // 1. getUserProfile (found)
    await Future.delayed(networkLatency);
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  // Optimized: _createPublicProfile with ignoreDuplicates: true
  // This is 1 call regardless of existence (upsert handles it on server)
  Future<Duration> measureOptimized() async {
    final stopwatch = Stopwatch()..start();
    // 1. upsert
    await Future.delayed(networkLatency);
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  final baselineNew = await measureBaseline_NewUser();
  final baselineExisting = await measureBaseline_ExistingUser();
  final optimized = await measureOptimized();

  print('Baseline (New User - 2 RTT): ${baselineNew.inMilliseconds} ms');
  print('Baseline (Existing User - 1 RTT): ${baselineExisting.inMilliseconds} ms');
  print('Optimized (Any User - 1 RTT): ${optimized.inMilliseconds} ms');

  print('--------------------------------------------------');
  print('Improvement for New Users: ${baselineNew.inMilliseconds - optimized.inMilliseconds} ms (50% reduction)');
  print('Impact for Existing Users: ${baselineExisting.inMilliseconds - optimized.inMilliseconds} ms (Neutral)');
}
