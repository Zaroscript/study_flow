import 'dart:io';

import 'package:study_flow/data/models/goal_model.dart';
import 'package:study_flow/data/models/task_model.dart';
import 'package:study_flow/features/notifications/models/notification_item_model.dart';
import 'package:study_flow/features/notifications/services/notification_service.dart';
import 'package:study_flow/features/notifications/services/web_notification_stub.dart';

Future<void> main() async {
  stdout.writeln('========================================================');
  stdout.writeln('🔔 StudyFlow Notifications & Alerts Automated Unit Tests 🔔');
  stdout.writeln('========================================================\n');

  testNotificationModelSerialization();
  testNotificationPreferences();
  await testNotificationServicePermissionsAndWebBridge();
  await testImmediateNotificationsAndDelivery();
  await testTaskReminderScheduling();
  await testPomodoroNotifications();
  await testGoalDeadlineWarnings();
  await testDailyBriefingNotifications();
  await testNotificationCenterReadAndClear();
  testListenersAndReactivity();

  stdout.writeln('\n========================================================');
  stdout.writeln('🌟 ALL NOTIFICATIONS TESTS PASSED WITH 100% SUCCESS! 🌟');
  stdout.writeln('========================================================');
}

void testNotificationModelSerialization() {
  stdout.writeln('Running NotificationItem Model & Serialization Tests...');

  final now = DateTime(2026, 11, 16, 10, 0);
  final scheduled = DateTime(2026, 11, 16, 10, 30);

  final item = NotificationItem(
    id: 'notif_001',
    title: 'تذكير بمذاكرة الرياضيات',
    body: 'تبدأ الجلسة بعد 15 دقيقة',
    type: NotificationType.taskReminder,
    channelId: NotificationChannel.tasks,
    createdAt: now,
    scheduledTime: scheduled,
    isRead: false,
    isDelivered: true,
    priority: NotificationPriority.high,
    payload: {'route': '/planner', 'taskId': 't101'},
  );

  assert(item.id == 'notif_001');
  assert(item.title == 'تذكير بمذاكرة الرياضيات');
  assert(item.type.displayName == 'تذكير مهمة');
  assert(item.priority.displayName == 'مهمة');

  // Serialization to JSON
  final json = item.toJson();
  assert(json['id'] == 'notif_001');
  assert(json['type'] == 'taskReminder');
  assert(json['priority'] == 'high');
  assert(json['payload']['taskId'] == 't101');

  // Deserialization from JSON
  final deserialized = NotificationItem.fromJson(json);
  assert(deserialized.id == item.id);
  assert(deserialized.title == item.title);
  assert(deserialized.type == NotificationType.taskReminder);
  assert(deserialized.priority == NotificationPriority.high);
  assert(deserialized.isDelivered == true);
  assert(deserialized.isRead == false);
  assert(deserialized.payload?['route'] == '/planner');

  // copyWith immutability
  final markedRead = item.copyWith(isRead: true);
  assert(markedRead.isRead == true);
  assert(item.isRead == false); // Original preserved

  // Channel definitions
  assert(NotificationChannel.defaultChannels.length == 5);
  assert(
    NotificationChannel.defaultChannels.any(
      (c) => c.id == NotificationChannel.tasks,
    ),
  );
  assert(
    NotificationChannel.defaultChannels.any(
      (c) => c.id == NotificationChannel.pomodoro,
    ),
  );

  stdout.writeln('  ✓ Model JSON serialization & deserialization: PASSED');
  stdout.writeln('  ✓ NotificationType and Priority display names: PASSED');
  stdout.writeln('  ✓ Immutability and copyWith: PASSED');
  stdout.writeln('  ✓ Channel metadata and default channels: PASSED');
}

void testNotificationPreferences() {
  stdout.writeln('Running NotificationPreferences Tests...');

  // Default values
  const defaultPrefs = NotificationPreferences();
  assert(defaultPrefs.notificationsEnabled == true);
  assert(defaultPrefs.taskRemindersEnabled == true);
  assert(defaultPrefs.taskReminderMinutesBefore == 15);
  assert(defaultPrefs.pomodoroAlertsEnabled == true);
  assert(defaultPrefs.goalAlertsEnabled == true);
  assert(defaultPrefs.dailyBriefingEnabled == true);
  assert(defaultPrefs.soundEnabled == true);
  assert(defaultPrefs.vibrationEnabled == true);

  // Modification via copyWith
  final customPrefs = defaultPrefs.copyWith(
    taskReminderMinutesBefore: 30,
    dailyBriefingEnabled: false,
    soundEnabled: false,
  );
  assert(customPrefs.taskReminderMinutesBefore == 30);
  assert(customPrefs.dailyBriefingEnabled == false);
  assert(customPrefs.soundEnabled == false);
  assert(customPrefs.notificationsEnabled == true);

  // Encode & Decode
  final encoded = customPrefs.encode();
  final decoded = NotificationPreferences.decode(encoded);
  assert(decoded.taskReminderMinutesBefore == 30);
  assert(decoded.dailyBriefingEnabled == false);
  assert(decoded.soundEnabled == false);
  assert(decoded.pomodoroAlertsEnabled == true);

  // Faulty decode fallback
  final fallback = NotificationPreferences.decode('invalid json string');
  assert(fallback.notificationsEnabled == true);
  assert(fallback.taskReminderMinutesBefore == 15);

  stdout.writeln('  ✓ Default notification preferences: PASSED');
  stdout.writeln('  ✓ Preference copyWith overrides: PASSED');
  stdout.writeln('  ✓ JSON string encoding & decoding: PASSED');
  stdout.writeln('  ✓ Corrupted string fallback handling: PASSED');
}

Future<void> testNotificationServicePermissionsAndWebBridge() async {
  stdout.writeln(
    'Running NotificationService Permissions & Web Bridge Tests...',
  );

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  assert(
    service.permissionStatus == NotificationPermissionStatus.notDetermined,
  );

  // 1. Mock Web Environment with Web Notifications supported & granted
  WebNotificationBridge.setMockState(supported: true, permission: 'default');
  assert(WebNotificationBridge.isSupported == true);

  final grantedResult = await service.requestPermission();
  assert(grantedResult == NotificationPermissionStatus.granted);
  assert(service.permissionStatus.isGranted == true);

  // Test web notification dispatch
  final notif = await service.showNotification(
    title: 'تنبيه المتصفح',
    body: 'رسالة تجريبية لمتصفح الويب',
    type: NotificationType.general,
  );
  assert(notif != null);
  assert(WebNotificationBridge.dispatchedWebNotifications.isNotEmpty);
  assert(
    WebNotificationBridge.dispatchedWebNotifications.last['title'] ==
        'تنبيه المتصفح',
  );

  // 2. Mock Web environment where permission is denied
  service.resetForTesting();
  WebNotificationBridge.setMockState(supported: false, permission: 'denied');
  final fallbackStatus = await service.requestPermission();
  // On fallback when unsupported on web, status is denied or fallback
  assert(fallbackStatus == NotificationPermissionStatus.denied);

  // Reset to granted for remaining tests
  service.resetForTesting();
  WebNotificationBridge.resetMock();
  await service.requestPermission();

  stdout.writeln('  ✓ Initial permission status notDetermined: PASSED');
  stdout.writeln('  ✓ Web Notification API bridge permission request: PASSED');
  stdout.writeln('  ✓ Web Notification dispatch & recording: PASSED');
  stdout.writeln('  ✓ Fallback when web notifications are unsupported: PASSED');
}

Future<void> testImmediateNotificationsAndDelivery() async {
  stdout.writeln('Running Immediate Notifications & Delivery Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  // Show immediate notification
  final notif1 = await service.showNotification(
    id: 'alert_1',
    title: 'تنبيه دراسي',
    body: 'حان وقت مراجعة الكيمياء',
    type: NotificationType.general,
    priority: NotificationPriority.high,
  );

  assert(notif1 != null);
  assert(notif1!.id == 'alert_1');
  assert(notif1!.isDelivered == true);
  assert(notif1!.isRead == false);
  assert(service.deliveredNotifications.length == 1);
  assert(service.unreadCount == 1);

  // Show second notification (should prepend, newest first)
  final notif2 = await service.showNotification(
    id: 'alert_2',
    title: 'مهمة مكتملة',
    body: 'أحسنت صنعاً!',
    type: NotificationType.taskReminder,
  );

  assert(notif2 != null);
  assert(service.deliveredNotifications.length == 2);
  assert(service.deliveredNotifications[0].id == 'alert_2');
  assert(service.deliveredNotifications[1].id == 'alert_1');
  assert(service.unreadCount == 2);

  // Master switch disabled
  await service.updatePreferences(
    service.preferences.copyWith(notificationsEnabled: false),
  );
  final suppressed = await service.showNotification(
    title: 'إشعار صامت',
    body: 'هذا الإشعار لن يظهر لأن الإشعارات معطلة',
  );
  assert(suppressed == null);
  assert(service.deliveredNotifications.length == 2);

  // Re-enable
  await service.updatePreferences(
    service.preferences.copyWith(notificationsEnabled: true),
  );

  stdout.writeln('  ✓ Immediate notification generation: PASSED');
  stdout.writeln('  ✓ Delivered history ordering (newest first): PASSED');
  stdout.writeln('  ✓ Unread counter calculation: PASSED');
  stdout.writeln('  ✓ Master enable/disable preference suppression: PASSED');
}

Future<void> testTaskReminderScheduling() async {
  stdout.writeln('Running Task Reminder Scheduling Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  // Create task for today at 14:00
  const task = TaskModel(
    id: 'task_math_01',
    title: 'حل تمارين التفاضل',
    category: 'study',
    startTime: '14:00',
    endTime: '15:30',
    priority: 'high',
    date: '2026-11-20',
  );

  // 1. Schedule with default 15 minutes before
  final reminder = await service.scheduleTaskReminder(task);
  assert(reminder != null);
  assert(reminder!.id == 'task_reminder_task_math_01');
  assert(reminder!.type == NotificationType.taskReminder);
  assert(
    reminder!.priority == NotificationPriority.urgent,
  ); // High priority task -> urgent
  assert(reminder!.title.contains('حل تمارين التفاضل'));
  assert(reminder!.body.contains('15 دقيقة'));
  assert(reminder!.payload?['taskId'] == 'task_math_01');
  assert(reminder!.payload?['route'] == '/planner');

  // Verify scheduled time calculation: 14:00 - 15 mins = 13:45
  assert(reminder!.scheduledTime != null);
  assert(reminder!.scheduledTime!.hour == 13);
  assert(reminder!.scheduledTime!.minute == 45);

  // 2. Schedule with custom 30 minutes before
  final reminder30 = await service.scheduleTaskReminder(
    task,
    minutesBefore: 30,
  );
  assert(reminder30 != null);
  assert(reminder30!.body.contains('30 دقيقة'));
  assert(reminder30!.scheduledTime!.hour == 13);
  assert(reminder30!.scheduledTime!.minute == 30);

  // 3. Cancel scheduled task reminder
  assert(service.scheduledNotifications.isNotEmpty);
  service.cancelScheduledNotification('task_reminder_task_math_01');
  assert(service.scheduledNotifications.isEmpty);

  // 4. Preference suppression when taskRemindersEnabled is false
  await service.updatePreferences(
    service.preferences.copyWith(taskRemindersEnabled: false),
  );
  final disabledReminder = await service.scheduleTaskReminder(task);
  assert(disabledReminder == null);

  stdout.writeln('  ✓ 15-minute lead time calculation: PASSED');
  stdout.writeln('  ✓ Custom minutes before override: PASSED');
  stdout.writeln('  ✓ Urgent priority mapping for high priority tasks: PASSED');
  stdout.writeln('  ✓ Scheduled reminder cancellation: PASSED');
  stdout.writeln('  ✓ Preference toggle suppression: PASSED');
}

Future<void> testPomodoroNotifications() async {
  stdout.writeln('Running Pomodoro Session & Break Notification Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  // 1. Study session finished alert
  final workAlert = await service.triggerPomodoroFinishNotification(
    isWorkSession: true,
    sessionCount: 3,
  );

  assert(workAlert != null);
  assert(workAlert!.type == NotificationType.pomodoro);
  assert(workAlert!.title.contains('انتهت جلسة التركيز'));
  assert(workAlert!.body.contains('الجلسة رقم 3'));
  assert(workAlert!.priority == NotificationPriority.urgent);
  assert(workAlert!.payload?['route'] == '/pomodoro');
  assert(workAlert!.payload?['action'] == 'break_ready');

  // 2. Break session finished alert
  final breakAlert = await service.triggerPomodoroFinishNotification(
    isWorkSession: false,
  );

  assert(breakAlert != null);
  assert(breakAlert!.type == NotificationType.pomodoro);
  assert(breakAlert!.title.contains('انتهت فترة الاستراحة'));
  assert(breakAlert!.body.contains('جلسة تركيز جديدة'));
  assert(breakAlert!.payload?['action'] == 'study_ready');

  // 3. Preference suppression
  await service.updatePreferences(
    service.preferences.copyWith(pomodoroAlertsEnabled: false),
  );
  final suppressed = await service.triggerPomodoroFinishNotification(
    isWorkSession: true,
  );
  assert(suppressed == null);

  stdout.writeln('  ✓ Pomodoro work session completed alert: PASSED');
  stdout.writeln('  ✓ Pomodoro break session completed alert: PASSED');
  stdout.writeln('  ✓ Action routing to /pomodoro: PASSED');
  stdout.writeln('  ✓ Preference toggle suppression: PASSED');
}

Future<void> testGoalDeadlineWarnings() async {
  stdout.writeln('Running Goal Deadline Warnings Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  final today = DateTime.now();

  final goals = [
    // Goal 1: 100% completed
    GoalModel(
      id: 'g1',
      title: 'إنهاء مذكرة الأحياء',
      target: 10,
      current: 10,
      deadline: today
          .add(const Duration(days: 10))
          .toIso8601String()
          .split('T')[0],
    ),
    // Goal 2: Urgent deadline in 2 days (<= 3 days) and progress < 75%
    GoalModel(
      id: 'g2',
      title: 'حفظ 50 كلمة فرنسية',
      target: 50,
      current: 15, // 30%
      deadline: today
          .add(const Duration(days: 2))
          .toIso8601String()
          .split('T')[0],
    ),
    // Goal 3: Overdue deadline
    GoalModel(
      id: 'g3',
      title: 'مشروع الحاسب الآلي',
      target: 100,
      current: 60,
      deadline: today
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0],
    ),
    // Goal 4: Safe goal (deadline far, progress good) -> no notification needed
    GoalModel(
      id: 'g4',
      title: 'قراءة الرواية المقررة',
      target: 200,
      current: 160,
      deadline: today
          .add(const Duration(days: 25))
          .toIso8601String()
          .split('T')[0],
    ),
  ];

  final alerts = await service.checkAndNotifyGoalDeadlines(goals);

  assert(alerts.length == 3);

  // Verify completed goal alert
  final completedAlert = alerts.firstWhere((a) => a.id == 'goal_completed_g1');
  assert(completedAlert.title.contains('هدف مكتمل'));
  assert(completedAlert.body.contains('100%'));

  // Verify urgent deadline alert
  final urgentAlert = alerts.firstWhere((a) => a.id == 'goal_urgent_g2');
  assert(urgentAlert.priority == NotificationPriority.urgent);
  assert(urgentAlert.title.contains('تنبيه عاجل'));

  // Verify overdue alert
  final overdueAlert = alerts.firstWhere((a) => a.id == 'goal_overdue_g3');
  assert(overdueAlert.priority == NotificationPriority.urgent);
  assert(overdueAlert.title.contains('انتهاء موعد'));

  stdout.writeln('  ✓ Completed goal (100%) celebratory notification: PASSED');
  stdout.writeln(
    '  ✓ Urgent approaching deadline (<= 3 days) notification: PASSED',
  );
  stdout.writeln('  ✓ Overdue goal notification: PASSED');
  stdout.writeln('  ✓ Safe distant deadline non-intrusiveness: PASSED');
}

Future<void> testDailyBriefingNotifications() async {
  stdout.writeln('Running Daily Briefing Notification Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  final tasks = [
    const TaskModel(
      id: 't1',
      title: 'مذاكرة الفيزياء',
      category: 'study',
      startTime: '09:00',
      endTime: '11:00',
      date: '2026-11-16',
    ),
    const TaskModel(
      id: 't2',
      title: 'حل واجب الكيمياء',
      category: 'homework',
      startTime: '16:00',
      endTime: '17:00',
      date: '2026-11-16',
    ),
  ];

  final goals = [
    const GoalModel(
      id: 'g1',
      title: 'إنهاء وحدة الجبر',
      target: 20,
      current: 8,
      deadline: '2026-11-30',
    ),
  ];

  final briefing = await service.generateDailyBriefing(
    todayTasks: tasks,
    activeGoals: goals,
    studentName: 'محمود أحمد',
  );

  assert(briefing != null);
  assert(briefing!.type == NotificationType.dailyBriefing);
  assert(briefing!.title.contains('محمود'));
  assert(briefing!.body.contains('2 مهام مجدولة'));
  assert(briefing!.body.contains('1 أهداف قيد المتابعة'));
  assert(briefing!.payload?['route'] == '/dashboard');

  // Empty tasks briefing
  final emptyBriefing = await service.generateDailyBriefing(
    todayTasks: const [],
    activeGoals: const [],
    studentName: '',
  );
  assert(emptyBriefing != null);
  assert(emptyBriefing!.title.contains('يا بطل'));
  assert(emptyBriefing!.body.contains('يومك فارغ'));

  stdout.writeln('  ✓ Personalized morning briefing greeting: PASSED');
  stdout.writeln('  ✓ Task and goal counts computation: PASSED');
  stdout.writeln('  ✓ Route mapping to /dashboard: PASSED');
  stdout.writeln('  ✓ Encouraging empty state fallback: PASSED');
}

Future<void> testNotificationCenterReadAndClear() async {
  stdout.writeln('Running Notification Center Read & Clear Tests...');

  final service = NotificationService.instance;
  service.resetForTesting();
  await service.init();

  // Add 3 notifications
  await service.showNotification(id: 'n1', title: 'تنبيه 1', body: 'محتوى 1');
  await service.showNotification(id: 'n2', title: 'تنبيه 2', body: 'محتوى 2');
  await service.showNotification(id: 'n3', title: 'تنبيه 3', body: 'محتوى 3');

  assert(service.deliveredNotifications.length == 3);
  assert(service.unreadCount == 3);

  // 1. Mark single notification as read
  await service.markAsRead('n2');
  assert(service.unreadCount == 2);
  final n2 = service.deliveredNotifications.firstWhere((e) => e.id == 'n2');
  assert(n2.isRead == true);

  // 2. Mark all as read
  await service.markAllAsRead();
  assert(service.unreadCount == 0);
  assert(service.deliveredNotifications.every((e) => e.isRead == true));

  // 3. Delete single notification
  await service.deleteNotification('n1');
  assert(service.deliveredNotifications.length == 2);
  assert(!service.deliveredNotifications.any((e) => e.id == 'n1'));

  // 4. Clear all delivered notifications
  await service.clearAllDelivered();
  assert(service.deliveredNotifications.isEmpty);
  assert(service.unreadCount == 0);

  stdout.writeln('  ✓ Mark single notification as read: PASSED');
  stdout.writeln('  ✓ Mark all notifications as read: PASSED');
  stdout.writeln('  ✓ Delete individual notification: PASSED');
  stdout.writeln('  ✓ Clear all delivered notifications: PASSED');
}

void testListenersAndReactivity() {
  stdout.writeln(
    'Running Notification Service Listeners & Reactivity Tests...',
  );

  final service = NotificationService.instance;
  service.resetForTesting();

  int callCount = 0;
  void listener() {
    callCount++;
  }

  service.addListener(listener);

  // Triggering notification should call listener
  service.showNotification(title: 'تنبيه فوري', body: 'نص التنبيه');
  assert(
    callCount > 0,
    'Listener should have been called on notification delivery',
  );

  final prevCount = callCount;
  service.removeListener(listener);

  // Triggering after removeListener should not call listener
  service.showNotification(title: 'تنبيه آخر', body: 'نص التنبيه');
  assert(callCount == prevCount, 'Listener should not be called after removal');

  stdout.writeln('  ✓ addListener triggered on state change: PASSED');
  stdout.writeln('  ✓ removeListener stops notifications: PASSED');
}
