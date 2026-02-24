import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/dashboard_controller.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/widgets/driver_status_monitor.dart';
import 'package:gotosco_v3/features/parent/tracking/application/tracking_providers.dart';
import 'package:gotosco_v3/features/parent/tracking/domain/models/tracking_view_model.dart';

void main() {
  testWidgets(
    'DriverStatusMonitor View All button navigates to My Bookings tab (index 3)',
    (WidgetTester tester) async {
      // 1. Define the booking data
      final booking = {
        'id': '123',
        'driver_id': 'driver_1',
        'driver_name': 'Test Driver',
        'driver_photo': null,
      };

      // 2. Create a mock tracking view model for immediate data
      final mockLocation = TrackingViewModel(
        driverId: 'driver_1',
        latitude: 23.5,
        longitude: 58.3,
        heading: 0,
        speed: 0,
        updatedAt: DateTime.now(),
        isAppOnline: false, // Offline triggers _buildScheduledCard
      );

      // 3. Create container with provider overrides that return data immediately
      final container = ProviderContainer(
        overrides: [
          driverLocationProvider(
            'driver_1',
          ).overrideWith((ref) => Stream.value(mockLocation)),
          latestRideEventProvider(
            '123',
          ).overrideWith((ref) => Stream.value(null)),
          parentNextStopInfoProvider(
            '123',
            'driver_1',
          ).overrideWith((ref) async => null),
        ],
      );

      // Keep the index provider alive so it doesn't dispose and reset
      final subscription = container.listen(
        parentDashboardIndexProvider,
        (prev, next) {},
      );

      // 4. Create a GoRouter for test context
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                Scaffold(body: DriverStatusMonitor(booking: booking)),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const Scaffold(body: Text('Tracking')),
          ),
        ],
      );

      // 5. Pump the widget with Router and ProviderScope
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // 6. Allow widget to receive stream data and settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 7. Debug: Print the widget tree to understand what's rendered
      // debugDumpApp();

      // 8. Find the "View All" text
      final viewAllFinder = find.text('View All');
      expect(
        viewAllFinder,
        findsOneWidget,
        reason: 'View All text should be visible in the card',
      );

      // 9. Tap the parent button (the ancestor of View All that is tappable)
      await tester.tap(viewAllFinder);
      await tester.pumpAndSettle();

      // 10. Verify the provider state changed from 2 (Home) to 3 (Bookings)
      expect(container.read(parentDashboardIndexProvider), 3);

      // Cleanup
      subscription.close();
      router.dispose();
      container.dispose();
    },
  );
}
