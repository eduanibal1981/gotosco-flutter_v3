// lib/core/router/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/core/constants/dev_config.dart';
import 'package:gotosco_v3/features/parent/bookings/presentation/booking_screen.dart';
import 'package:gotosco_v3/features/parent/children/data/child_model.dart';
import 'package:gotosco_v3/features/parent/children/presentation/add_child_screen.dart';
import 'package:gotosco_v3/features/parent/children/presentation/edit_child_screen.dart';
import 'package:gotosco_v3/features/shared/chat/presentation/chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screen Imports
import 'package:gotosco_v3/features/auth/presentation/login_screen.dart';
import 'package:gotosco_v3/features/auth/presentation/splash_screen.dart';
import 'package:gotosco_v3/features/parent/dashboard/presentation/parent_dashboard_screen.dart';
// import '../../features/driver/dashboard/presentation/driver_dashboard.dart';

final routerProvider = Provider<GoRouter>((ref) {
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
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("Search Filter Placeholder")),
        ),
      ),

      // DRIVER ROUTES
      GoRoute(
        path: '/driver-home',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Driver Dashboard')),
          body: const Center(child: Text("Driver Dashboard Placeholder")),
        ),
        // Replace with DriverDashboardScreen()
      ),
      GoRoute(
        path: '/add-student', // Matches the context.push('/add-student')
        builder: (context, state) => const AddChildScreen(),
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
          );
        },
      ),
    ],

    // REDIRECT LOGIC
    redirect: (context, state) {
      // ⚠️ DEV BYPASS - Skip all auth checks
      if (DevConfig.bypassAuth) {
        return null; // No redirects in dev mode
      }

      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSplash = state.uri.toString() == '/';

      // 1. No Session? Go to Login
      if (session == null) {
        return isLoggingIn || isSplash ? null : '/login';
      }

      // 2. Has Session but on Login/Splash? Go to correct Home
      if (isLoggingIn || isSplash) {
        final userRoleStr = session.user.userMetadata?['role'];
        if (userRoleStr == 'driver') return '/driver-home';
        return '/parent-home';
      }

      return null;
    },
  );
});
