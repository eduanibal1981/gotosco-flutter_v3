// lib/core/router/router.dart

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
import 'package:gotosco_v3/features/driver/transport_requests/presentation/driver_transport_requests_screen.dart';
import 'package:gotosco_v3/features/driver/profile/presentation/driver_profile_tab.dart';
import 'package:gotosco_v3/features/driver/profile/presentation/driver_coverage_screen.dart';
import 'package:gotosco_v3/features/driver/profile/presentation/vehicle_details_screen.dart';
import 'package:gotosco_v3/features/driver/profile/data/driver_profile_model.dart';
import 'package:gotosco_v3/features/parent/messages/presentation/parent_messages_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/find_drivers_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/presentation/driver_detail_screen.dart';
import 'package:gotosco_v3/features/parent/find_driver/data/driver_ad_model.dart';
import 'package:gotosco_v3/features/parent/profile/presentation/edit_profile_screen.dart';

import 'package:gotosco_v3/features/parent/notifications/presentation/notifications_screen.dart';
import 'package:gotosco_v3/features/parent/support/presentation/help_support_screen.dart';
import 'package:gotosco_v3/features/parent/support/presentation/terms_conditions_screen.dart';
import 'package:gotosco_v3/features/parent/support/presentation/privacy_policy_screen.dart';
import 'package:gotosco_v3/core/models/user_model.dart';
import 'package:gotosco_v3/core/providers/user_session_provider.dart';
import 'package:gotosco_v3/features/booking_flow/presentation/screens/booking_flow_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  // Watch the user session state.
  // This ensures the router rebuilds and re-evaluates redirects whenever
  // the session state changes (login, logout, role switch, etc.).
  final userSessionState = ref.watch(userSessionProvider);

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
        builder: (context, state) =>
            const BookingFlowScreen(isPublicRequest: true),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/terms',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
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
      GoRoute(
        path: '/driver-profile-create',
        builder: (context, state) => const DriverCreateProfileScreen(),
      ),
      GoRoute(
        path: '/driver-profile-edit',
        builder: (context, state) {
          final profile = state.extra as DriverProfileModel;
          return DriverEditProfileScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/driver-coverage',
        builder: (context, state) => const DriverCoverageScreen(),
      ),
      GoRoute(
        path: '/vehicle-details',
        builder: (context, state) {
          final profile = state.extra as DriverProfileModel;
          return VehicleDetailsScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/driver-transport-requests',
        builder: (context, state) => const DriverTransportRequestsScreen(),
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
      // NEW 6-STEP BOOKING FLOW
      GoRoute(
        path: '/booking-flow',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return BookingFlowScreen(
            driverId: args['driverId'],
            driverName: args['driverName'],
            // Edit mode parameters
            editBookingId: args['editBookingId'],
            editBookingData: args['editBookingData'],
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
    redirect: (context, state) {
      final authSession = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/';
      final isRoleSelection = state.uri.toString() == '/role-selection';

      // 1. No Auth Session? Go to Login
      if (authSession == null) {
        return isLoggingIn || isSplash ? null : '/login';
      }

      // 2. Auth Session Exists

      // If we are still loading user data, stay put (or show splash if on root)
      // This prevents premature redirection before we know the roles
      if (userSessionState.isLoading) {
        if (isSplash) return null; // Show splash while loading
        return null; // Don't interrupt other flows?
      }

      // If we have an error or null value after loading, it likely means
      // user profile is missing or has no roles.
      final userSession = userSessionState.asData?.value;

      if (userSession == null) {
        // Required: Select a role
        if (isRoleSelection) return null;
        return '/role-selection';
      }

      // 3. User is Fully Authenticated with Roles

      // If user is trying to access login, splash, or role selection (when they already have one),
      // redirect them to their active dashboard.
      if (isLoggingIn || isSplash || isRoleSelection) {
        if (userSession.activeRole == 'driver') {
          return '/driver-home';
        } else {
          return '/parent-home';
        }
      }

      // Otherwise, let them go where they are going
      return null;
    },
  );
}
