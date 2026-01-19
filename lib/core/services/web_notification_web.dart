import 'dart:html' as html;

Future<void> showWebNotificationImpl(String title, String body) async {
  if (!html.Notification.supported) return;

  if (html.Notification.permission != 'granted') {
    await html.Notification.requestPermission();
  }

  if (html.Notification.permission == 'granted') {
    html.Notification(title, body: body);
  }
}
