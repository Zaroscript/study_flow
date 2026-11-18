import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_item_model.dart';
import 'notification_gateway.dart';

/// The only adapter importing the native notification SDK.
class NativeNotificationGateway implements NotificationGateway {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  @override
  bool get handlesScheduling => true;
  Future<void> init() async {
    tzdata.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  @override
  Future<NotificationPermissionStatus> permission({
    bool request = false,
  }) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final allowed = request
          ? await android.requestNotificationsPermission()
          : await android.areNotificationsEnabled();
      return allowed == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null && request) {
      final allowed = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return allowed == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    if (ios != null) {
      final settings = await ios.checkPermissions();
      return settings?.isEnabled == true
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied;
    }
    return NotificationPermissionStatus.notDetermined;
  }

  int _id(String value) {
    var hash = 2166136261;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 16777619) & 0x7fffffff;
    }
    return hash;
  }

  NotificationDetails _details(NotificationItem item) => NotificationDetails(
    android: AndroidNotificationDetails(
      item.channelId,
      'ENote',
      channelDescription: 'Study reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    ),
    iOS: const DarwinNotificationDetails(),
  );
  @override
  Future<void> show(NotificationItem item) => _plugin.show(
    id: _id(item.id),
    title: item.title,
    body: item.body,
    notificationDetails: _details(item),
    payload: '/notifications',
  );
  @override
  Future<void> reconcile(List<NotificationItem> desired) async {
    final now = DateTime.now();
    final items =
        desired.where((i) => i.scheduledTime?.isAfter(now) == true).toList()
          ..sort((a, b) => a.scheduledTime!.compareTo(b.scheduledTime!));
    final ids = <int, NotificationItem>{
      for (final item in items.take(50))
        _id(
          '${item.id}|${item.scheduledTime!.toUtc().toIso8601String()}|${item.title}|${item.body}',
        ): item,
    };
    final pending = await _plugin.pendingNotificationRequests();
    for (final old in pending) {
      if (!ids.containsKey(old.id)) await _plugin.cancel(id: old.id);
    }
    final existing = pending.map((i) => i.id).toSet();
    for (final entry in ids.entries) {
      if (!existing.contains(entry.key)) {
        await _plugin.zonedSchedule(
          id: entry.key,
          title: entry.value.title,
          body: entry.value.body,
          scheduledDate: tz.TZDateTime.from(
            entry.value.scheduledTime!,
            tz.local,
          ),
          notificationDetails: _details(entry.value),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: entry.value.payload?['repeat'] == 'daily'
              ? DateTimeComponents.time
              : null,
          payload: '/notifications',
        );
      }
    }
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();
}
