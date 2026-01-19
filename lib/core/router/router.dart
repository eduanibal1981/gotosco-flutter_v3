// lib/core/router/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/booking_screen.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/presentation/add_child_screen.dart';
import 'package:gotosco_v3/features/parent/children/presentation/edit_child_screen.dart';
import 'package:gotosco_v3/features/parent/children/presentation/attendance_history_screen.dart';
import 'package:gotosco_v3/features/shared/chat/presentation/chat_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screen Imports
import 'package:gotosco_v3/features/auth/presentation/login_screen.dart';
import 'package:gotosco_v3/features/auth/presentation/splash_screen.dart';
import 'package:gotosco_v3/features/auth/presentation/role_selection_screen.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/parent_dashboard_screen.dart';
import 'package:gotosco_v3/features/parent/tracking/presentation/live_tracking_screen.dart';
import 'package:gotosco_v3/features/driver/dashboard/presentation/driver_dashboard_screen.dart';
import 'package:gotosco_v3/features/driver/bookings/presentation/driver_bookings_screen.dart';
import 'package:gotosco_v3/features/driver/messages/presentation/driver_messages_screen.dart';
import 'package:gotosco_v3/features/parent/messages/presentation/parent_messages_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/find_drivers_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/driver_detail_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/data/driver_ad_model.dart';
import 'package:gotosco_v3/features/parent/profile/presentation/edit_profile_screen.dart';
import 'package:gotosco_v3/features/parent/transport_requests/presentation/transport_request_screen.dart';
import 'package:gotosco_v3/features/parent/notifications/presentation/notifications_screen.dart';
import 'package:gotosco_v3/core/models/user_model.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // PARENT ROUTES
      GoRoute(
        path: '/parent-home',
        builder: (context, state) => const ParentDashboardScreen(),
      ),
      GoRoute(
        path: '/find-driver',
        builder: (context, state) => const FindDriversScreen(),
      ),
      GoRoute(
        path: '/driver-detail',
        builder: (context, state) {
          final driver = state.extra as DriverAdModel;
          return DriverDetailScreen(driver: driver);
        },
      ),
      GoRoute(
        path: '/parent-chats',
        builder: (context, state) => const ParentMessagesScreen(),
      ),
      GoRoute(
        path: '/transport-request',
        builder: (context, state) => const TransportRequestScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final user = state.extra as UserModel;
          return EditProfileScreen(user: user);
        },
      ),

      // DRIVER ROUTES
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
      GoRoute(
        path: '/add-student', // Matches the context.push('/add-student')
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/driver-bookings',
        builder: (context, state) => const DriverBookingsScreen(),
      ),
      GoRoute(
        path: '/driver-messages',
        builder: (context, state) => const DriverMessagesScreen(),
      ),

      // ... inside routes list
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          // Get args from the "extra" map
          final args = state.extra as Map<String, dynamic>? ?? {};

          return ChatScreen(
            otherUserId:
                args['userId'] ??
                '', // Ensure these keys match what DriverAdCard sends
            otherUserName: args['userName'] ?? 'Driver',
          );
        },
      ),
      // ... inside routes list:
      GoRoute(
        path: '/edit-student',
        builder: (context, state) {
          // Retrieve the passed object
          final child = state.extra as ChildModel;
          return EditChildScreen(child: child);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return BookingScreen(
            driverId: args['driverId'],
            driverName: args['driverName'],
            initialData: args['initialData'],
          );
        },
      ),
      GoRoute(
        path: '/add-child',
        builder: (context, state) => const AddChildScreen(),
      ),
      GoRoute(
        path: '/edit-child/:childId',
        builder: (context, state) {
          final child = state.extra as ChildModel;
          return EditChildScreen(child: child);
        },
      ),
      // LIVE TRACKING ROUTE
      GoRoute(
        path: '/tracking',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return LiveTrackingScreen(
            bookingId: args['bookingId'] ?? '',
            driverId: args['driverId'] ?? '',
          );
        },
      ),
      // ATTENDANCE HISTORY ROUTE
      GoRoute(
        path: '/child-attendance',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return AttendanceHistoryScreen(
            childId: args['childId'],
            childName: args['childName'],
          );
        },
      ),
      // ROLE SELECTION ROUTE
      GoRoute(
        path: '/role-selection',
        builder: (context, state) {
          // Lazy import to avoid circular dependencies
          return const RoleSelectionScreen();
        },
      ),
    ],

    // REDIRECT LOGIC
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/';
      final isRoleSelection = state.uri.toString() == '/role-selection';

      // 1. No Session? Go to Login
      if (session == null) {
        return isLoggingIn || isSplash ? null : '/login';
      }

      // 2. Has Session but on Login/Splash? Check roles in database
      if (isLoggingIn || isSplash) {
        try {
          final userData = await Supabase.instance.client
              .from('users')
              .select('role')
              .eq('id', session.user.id)
              .single();

          final roles = List<String>.from(userData['role'] ?? []);

          // No roles? Go to role selection
          if (roles.isEmpty) {
            return '/role-selection';
          }

          // Has roles? Go to first role's dashboard
          if (roles.contains('driver')) {
            return '/driver-home';
          } else {
            return '/parent-home';
          }
        } catch (e) {
          // If user not in DB, go to role selection
          return '/role-selection';
        }
      }

      return null;
    },
  );
}


