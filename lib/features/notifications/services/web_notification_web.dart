// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation of the Web Notifications API.
class WebNotificationBridge {
  static bool get isSupported => html.Notification.supported;

  static Future<String> requestPermission() async {
    if (!isSupported) return 'denied';
    try {
      final status = await html.Notification.requestPermission();
      return status;
    } catch (_) {
      return 'denied';
    }
  }

  static String get permission {
    if (!isSupported) return 'denied';
    return html.Notification.permission ?? 'default';
  }

  static bool showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) {
    if (!isSupported) return false;
    if (html.Notification.permission != 'granted') return false;

    try {
      html.Notification(
        title,
        body: body,
        icon: icon ?? 'assets/public/assets/enote-icon.png',
        tag: tag,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // Stub compatibility
  static void setMockState({bool? supported, String? permission}) {}
  static void resetMock() {}
  static List<Map<String, dynamic>> get dispatchedWebNotifications => const [];
}
