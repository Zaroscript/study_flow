import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/features/notifications/models/notification_item_model.dart';
import 'package:study_flow/features/notifications/services/notification_service.dart';
import 'package:study_flow/features/notifications/services/notification_gateway.dart';

class FakeOsGateway implements NotificationGateway {
  final List<NotificationItem> pending = [];
  @override
  bool get handlesScheduling => true;
  @override
  Future<NotificationPermissionStatus> permission({
    bool request = false,
  }) async => NotificationPermissionStatus.denied;
  @override
  Future<void> show(NotificationItem item) async {}
  @override
  Future<void> reconcile(List<NotificationItem> desired) async {
    pending
      ..clear()
      ..addAll(desired);
  }

  @override
  Future<void> cancelAll() async {
    pending.clear();
  }
}

void main() {
  test('native permission comes from the OS, never a success flag', () async {
    final service = NotificationService(gateway: FakeOsGateway());
    await service.init();
    expect(
      await service.requestPermission(),
      NotificationPermissionStatus.denied,
    );
  });
  test(
    'scheduled queue survives service recreation and reset cancels OS work',
    () async {
      final storage = InMemoryNotificationStorage();
      final os = FakeOsGateway();
      final first = NotificationService(storage: storage, gateway: os);
      await first.init();
      await first.scheduleNotification(
        id: 'reminder',
        title: 'Study',
        body: 'Review',
        type: NotificationType.taskReminder,
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(os.pending, hasLength(1));
      final reopened = NotificationService(storage: storage, gateway: os);
      await reopened.init();
      expect(os.pending, hasLength(1));
      await reopened.clearAllData();
      expect(os.pending, isEmpty);
      final reset = NotificationService(storage: storage, gateway: os);
      await reset.init();
      expect(os.pending, isEmpty);
    },
  );
}
