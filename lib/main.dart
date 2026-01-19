// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler (must be top-level function)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ixjkvasziamjkeupqvfc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4amt2YXN6aWFtamtldXBxdmZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcxMTMwNTUsImV4cCI6MjA4MjY4OTA1NX0.FsZCUPXl5akkSQKBuZUMaz96G7xcdafrP4da41TsiIc',
  );

  // Initialize notification service
  await NotificationService().initialize();

  // Prompt for location access on web to show the browser permission dialog.
  if (kIsWeb) {
    await _requestWebLocationPermission();
  }

  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _requestWebLocationPermission() async {
  try {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  } catch (_) {
    // Ignore; permission can still be requested on demand later.
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GoToSco',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
