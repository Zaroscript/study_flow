import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

/// Web implementation of the Web Notifications API.
class WebNotificationBridge {
  static bool get isSupported =>
      globalContext.hasProperty('Notification'.toJS).toDart;

  static Future<String> requestPermission() async {
    if (!isSupported) return 'denied';
    try {
      final status = (await web.Notification.requestPermission().toDart).toDart;
      return status;
    } catch (_) {
      return 'denied';
    }
  }

  static String get permission {
    if (!isSupported) return 'denied';
    return web.Notification.permission;
  }

  static bool showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) {
    if (!isSupported) return false;
    if (web.Notification.permission != 'granted') return false;

    try {
      web.Notification(
        title,
        web.NotificationOptions(
          body: body,
          icon: icon ?? 'assets/public/assets/enote-icon.png',
          tag: tag ?? 'enote',
        ),
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
