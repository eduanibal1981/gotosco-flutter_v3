// lib/core/services/notification_service.dart
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'web_notification.dart';

/// Top-level function to handle background messages.
/// This must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling background message: ${message.messageId}');
  // You can add logic here to show local notification if needed
}

/// Check if the current platform supports FCM
bool get _isFCMSupported {
  if (kIsWeb) return true; // Web is now supported with Service Worker
  // FCM is only supported on Android, iOS, and macOS
  return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
}

/// Service to manage push notifications using FCM.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android notification channel for high-priority notifications
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'gotosco_high_importance',
    'GoToSco Notifications',
    description: 'Important notifications for driver updates and child status',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the notification service.
  /// Call this after Firebase.initializeApp() in main.dart
  Future<void> initialize() async {
    // Skip unsupported platforms (Windows, Linux, Web)
    if (!_isFCMSupported) {
      log('NotificationService: Platform not supported for FCM, skipping');
      return;
    }

    // Request permission
    await _requestPermission();

    // Initialize local notifications for foreground display (mobile only)
    if (!kIsWeb) {
      await _initializeLocalNotifications();

      // Create the Android notification channel
      await _createAndroidChannel();
    }

    // Get and save FCM token
    await _handleToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    log('NotificationService: Initialized successfully');
  }

  /// Request notification permissions (especially for iOS).
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log(
      'NotificationService: Permission status: ${settings.authorizationStatus}',
    );
  }

  /// Initialize flutter_local_notifications for foreground display.
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log(
          'NotificationService: Local notification tapped: ${response.payload}',
        );
        // Handle local notification tap if needed
      },
    );
  }

  /// Create the Android notification channel.
  Future<void> _createAndroidChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// Get the FCM token and save it to Supabase.
  Future<void> _handleToken() async {
    try {
      // VAPID key for web push (from Firebase Console -> Project Settings -> Cloud Messaging)
      const String vapidKey = kIsWeb
          ? 'BM8cqa_6va6wLZlmGQHh1QoPXDelyMg0P90okz7mzaOhKCm5gOebaVFCaZlzPD9ldtyJWoleQUfXGWHIvNIpfs4'
          : '';

      final token = await _messaging.getToken(
        vapidKey: kIsWeb ? vapidKey : null,
      );
      if (token != null) {
        log('NotificationService: FCM Token: ${token.substring(0, 20)}...');
        await _saveTokenToSupabase(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        log('NotificationService: Token refreshed');
        _saveTokenToSupabase(newToken);
      });
    } catch (e) {
      log('NotificationService: Error getting token: $e');
    }
  }

  /// Save the FCM token to the current user's record in Supabase.
  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        log('NotificationService: No user logged in, token not saved');
        return;
      }

      await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token})
          .eq('id', user.id);

      log('NotificationService: Token saved to Supabase');
    } catch (e) {
      log('NotificationService: Error saving token: $e');
    }
  }

  /// Handle foreground messages by showing a local notification.
  void _handleForegroundMessage(RemoteMessage message) {
    log('NotificationService: Foreground message received');

    final notification = message.notification;
    final android = message.notification?.android;

    if (kIsWeb && notification != null) {
      showWebNotification(
        notification.title ?? 'GoToSco',
        notification.body ?? 'You have a new notification',
      );
      return;
    }

    // Show local notification on Android when in foreground
    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Handle when user taps on a notification.
  void _handleNotificationTap(RemoteMessage message) {
    log('NotificationService: Notification tapped with data: ${message.data}');

    // You can navigate to specific screens based on message.data
    // For example:
    // if (message.data['type'] == 'driver_approaching') {
    //   navigatorKey.currentState?.pushNamed('/tracking');
    // }
  }

  /// Manually show a local notification (for in-app alerts).
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }
}
