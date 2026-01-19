import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/dashboard_controller.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart';

// Mock the tracking provider or just test the interaction
// Since we can't fully mock everything here without more setup,
// we focus on the logic that tapping 'View All' sets the index.

void main() {
  testWidgets('DriverStatusMonitor View All button navigates to My Bookings tab (index 3)', (WidgetTester tester) async {
    // 1. Setup the container
    final container = ProviderContainer();

    // 2. Define the booking data
    final booking = {
      'id': '123',
      'driver_id': 'driver_1',
      'driver_name': 'Test Driver',
      'driver_photo': null,
    };

    // 3. Pump the widget wrapped in ProviderScope
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: DriverStatusMonitor(booking: booking),
          ),
        ),
      ),
    );

    // 4. Find the "View All" text button
    final viewAllFinder = find.text('View All');
    expect(viewAllFinder, findsOneWidget);

    // 5. Tap it
    await tester.tap(viewAllFinder);
    await tester.pump();

    // 6. Verify the provider state
    // The default index is 1. After tapping, it should be 3.
    expect(container.read(parentDashboardIndexProvider), 3);
  });
}
