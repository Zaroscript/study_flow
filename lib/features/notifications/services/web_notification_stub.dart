/// Stub implementation for non-web environments (Android, iOS, Windows, macOS, Linux, VM tests).
class WebNotificationBridge {
  static bool _mockSupported = false;
  static String _mockPermission = 'default';
  static final List<Map<String, dynamic>> _dispatchedWebNotifications = [];

  /// Enable mock mode for testing web notification flow on native/headless VM
  static void setMockState({bool? supported, String? permission}) {
    if (supported != null) _mockSupported = supported;
    if (permission != null) _mockPermission = permission;
  }

  static void resetMock() {
    _mockSupported = false;
    _mockPermission = 'default';
    _dispatchedWebNotifications.clear();
  }

  static List<Map<String, dynamic>> get dispatchedWebNotifications =>
      List.unmodifiable(_dispatchedWebNotifications);

  static bool get isSupported => _mockSupported;

  static Future<String> requestPermission() async {
    if (!_mockSupported) return 'denied';
    _mockPermission = 'granted';
    return _mockPermission;
  }

  static String get permission => _mockPermission;

  static bool showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
  }) {
    if (!_mockSupported || _mockPermission != 'granted') {
      return false;
    }
    _dispatchedWebNotifications.add({
      'title': title,
      'body': body,
      'icon': icon,
      'tag': tag,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
