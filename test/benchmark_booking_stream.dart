import 'dart:async';

Future<void> main() async {
  print('Running synthetic benchmark for Booking Requests Stream N+1 Optimization...');

  // Configuration
  const int numberOfBookings = 10;
  const Duration networkLatency = Duration(milliseconds: 50);

  // 1. Baseline Measurement (N+1)
  // Logic: For each booking, fetch parent (1 call) + fetch children (1 call)
  Future<Duration> measureBaseline() async {
    final stopwatch = Stopwatch()..start();

    print('Processing $numberOfBookings bookings with N+1 pattern...');
    for (int i = 0; i < numberOfBookings; i++) {
      // Fetch parent
      await Future.delayed(networkLatency);
      // Fetch children
      await Future.delayed(networkLatency);
    }

    stopwatch.stop();
    return stopwatch.elapsed;
  }

  // 2. Optimized Measurement (Batch/Join)
  // Logic: Fetch all parents (1 call) + fetch all children (1 call)
  Future<Duration> measureOptimized() async {
    final stopwatch = Stopwatch()..start();

    print('Processing $numberOfBookings bookings with Batch pattern...');
    // Fetch all parents in one go
    await Future.delayed(networkLatency);
    // Fetch all children in one go
    await Future.delayed(networkLatency);

    stopwatch.stop();
    return stopwatch.elapsed;
  }

  final baselineDuration = await measureBaseline();
  final optimizedDuration = await measureOptimized();

  print('\nResults (assuming ${networkLatency.inMilliseconds}ms latency per DB call):');
  print('--------------------------------------------------');
  print('Baseline (N+1 queries): ${baselineDuration.inMilliseconds} ms');
  print('Optimized (2 queries):  ${optimizedDuration.inMilliseconds} ms');

  final improvement = baselineDuration.inMilliseconds - optimizedDuration.inMilliseconds;
  final speedup = baselineDuration.inMilliseconds / optimizedDuration.inMilliseconds;

  print('--------------------------------------------------');
  print('Improvement: ${improvement} ms saved');
  print('Speedup: ${speedup.toStringAsFixed(1)}x faster');
}
