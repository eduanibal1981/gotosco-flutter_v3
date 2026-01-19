import 'web_notification_stub.dart'
    if (dart.library.html) 'web_notification_web.dart';

Future<void> showWebNotification(String title, String body) {
  return showWebNotificationImpl(title, body);
}
