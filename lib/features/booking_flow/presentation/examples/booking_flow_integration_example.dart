import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../booking_flow/presentation/screens/booking_flow_screen.dart';

/// Example: How to add the booking flow to your router configuration
///
/// Add this route to your GoRouter configuration in lib/core/router/router.dart

class BookingFlowRouteExample {
  // Add this to your routes list
  static GoRoute bookingFlowRoute() {
    return GoRoute(
      path: 'booking-flow',
      name: 'booking-flow',
      builder: (context, state) => const BookingFlowScreen(),
    );
  }

  // Example: Add a button to parent dashboard to start booking flow
  static Widget buildBookNowButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to booking flow
        context.push('/booking-flow');
        // Or if using Navigator
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => const BookingFlowScreen()),
        // );
      },
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Book Now'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Example: Add a FloatingActionButton to parent dashboard
  static Widget buildBookingFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/booking-flow'),
      icon: const Icon(Icons.add),
      label: const Text('New Booking'),
      backgroundColor: Colors.indigo.shade600,
    );
  }
}

/// Example: Integration in ParentDashboardScreen
/// 
/// class ParentDashboardScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return Scaffold(
///       appBar: AppBar(title: const Text('Parent Dashboard')),
///       body: Column(
///         children: [
///           // Your existing dashboard content
///           const SizedBox(height: 20),
///           
///           // Add booking button
///           BookingFlowRouteExample.buildBookNowButton(context),
///         ],
///       ),
///       // Or as a FAB
///       floatingActionButton: BookingFlowRouteExample.buildBookingFAB(context),
///     );
///   }
/// }
