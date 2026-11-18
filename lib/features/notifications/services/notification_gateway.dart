import '../models/notification_item_model.dart';

/// Isolates OS permission and scheduling from the notification model.
abstract class NotificationGateway {
  bool get handlesScheduling;
  Future<NotificationPermissionStatus> permission({bool request = false});
  Future<void> show(NotificationItem item);
  Future<void> reconcile(List<NotificationItem> desired);
  Future<void> cancelAll();
}

/// Explicit unsupported-platform behavior, never a pretend permission grant.
class UnavailableNotificationGateway implements NotificationGateway {
  @override
  bool get handlesScheduling => false;
  @override
  Future<NotificationPermissionStatus> permission({
    bool request = false,
  }) async => NotificationPermissionStatus.denied;
  @override
  Future<void> show(NotificationItem item) async {}
  @override
  Future<void> reconcile(List<NotificationItem> desired) async {}
  @override
  Future<void> cancelAll() async {}
}
