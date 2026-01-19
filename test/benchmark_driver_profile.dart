
import 'dart:async';

// Mock classes to simulate Supabase behavior
class MockSupabaseClient {
  MockQueryBuilder from(String table) => MockQueryBuilder(table);
}

class MockQueryBuilder {
  final String table;
  MockQueryBuilder(this.table);

  MockFilterBuilder select([String? columns]) {
    return MockFilterBuilder(table);
  }
}

class MockFilterBuilder {
  final String table;
  MockFilterBuilder(this.table);

  MockFilterBuilder eq(String column, String value) {
    return this;
  }

  Future<Map<String, dynamic>?> maybeSingle() async {
    // Simulate network latency
    await Future.delayed(Duration(milliseconds: 100));
    if (table == 'drivers') {
      return {'user_id': '123', 'vehicle_type': 'Car'};
    }
    if (table == 'users') {
      return {'id': '123', 'full_name': 'John Doe'};
    }
    return null;
  }
}

// Original Fallback Logic (Sequential)
Future<void> runSequentialFallback() async {
  final stopwatch = Stopwatch()..start();

  // 1. Fetch driver
  await Future.delayed(Duration(milliseconds: 100)); // Driver query
  final driverData = {'user_id': '123'};

  if (driverData != null) {
    // 2. Fetch user
    await Future.delayed(Duration(milliseconds: 100)); // User query
    final userData = {'id': '123'};
  }

  stopwatch.stop();
  print('Sequential Fallback Time: ${stopwatch.elapsedMilliseconds}ms');
}

// Optimized Fallback Logic (Parallel)
Future<void> runParallelFallback() async {
  final stopwatch = Stopwatch()..start();

  // 1. Fetch both in parallel
  await Future.wait([
    Future.delayed(Duration(milliseconds: 100), () => {'user_id': '123'}), // Driver query
    Future.delayed(Duration(milliseconds: 100), () => {'id': '123'}),      // User query
  ]);

  stopwatch.stop();
  print('Parallel Fallback Time: ${stopwatch.elapsedMilliseconds}ms');
}

void main() async {
  print('Running Benchmark...');
  await runSequentialFallback();
  await runParallelFallback();
}
