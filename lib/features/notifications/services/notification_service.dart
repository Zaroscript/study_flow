import 'dart:async';
import 'dart:convert';

import '../../../data/models/goal_model.dart';
import '../../../data/models/task_model.dart';
import '../models/notification_item_model.dart';
import 'web_notification_platform.dart';
import 'notification_gateway.dart';

typedef VoidCallback = void Function();

const bool kIsWeb = bool.fromEnvironment('dart.library.js_interop');

/// Abstract storage interface to decouple persistence from platform plugins.
abstract class INotificationStorage {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<void> clear();
}

/// Fast in-memory storage fallback ensuring zero crashes in headless/test environments.
class InMemoryNotificationStorage implements INotificationStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getString(String key) async => _store[key];

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<void> clear() async => _store.clear();
}

/// Comprehensive notification service orchestrating local reminders,
/// web notifications, scheduled alerts, and user preference enforcement.
class NotificationService {
  static const String _keyHistory = 'studyflow_notifications_history';
  static const String _keyPrefs = 'studyflow_notifications_prefs';
  static const String _keyPermission = 'studyflow_notifications_permission';

  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  NotificationService._() : _storage = InMemoryNotificationStorage();

  /// Constructor for dependency injection and testing.
  factory NotificationService({
    INotificationStorage? storage,
    NotificationGateway? gateway,
  }) {
    final service = NotificationService._();
    if (storage != null) {
      service._storage = storage;
    }
    if (gateway != null) service._gateway = gateway;
    return service;
  }

  NotificationGateway _gateway = UnavailableNotificationGateway();
  INotificationStorage _storage;

  final List<NotificationItem> _deliveredHistory = [];
  final List<NotificationItem> _scheduledQueue = [];
  final Map<String, Timer> _activeTimers = {};
  final List<VoidCallback> _listeners = [];

  NotificationPreferences _preferences = const NotificationPreferences();
  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.notDetermined;

  NotificationPreferences get preferences => _preferences;
  NotificationPermissionStatus get permissionStatus => _permissionStatus;
  List<NotificationItem> get deliveredNotifications =>
      List.unmodifiable(_deliveredHistory);
  List<NotificationItem> get scheduledNotifications =>
      List.unmodifiable(_scheduledQueue);

  int get unreadCount => _deliveredHistory.where((item) => !item.isRead).length;

  /// Register change listener for reactive UI components.
  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// Remove registered change listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  /// Set storage engine (e.g. when SharedPreferences is initialized).
  void setStorage(INotificationStorage storage) {
    _storage = storage;
  }

  /// Initialize service, load persisted state & settings.
  Future<void> init() async {
    await _loadPreferences();
    await _loadHistory();
    await _loadPermissionStatus();
    await _loadQueue();
    await syncNotifications();
  }

  Future<void> _loadPreferences() async {
    final raw = await _storage.getString(_keyPrefs);
    if (raw != null && raw.isNotEmpty) {
      _preferences = NotificationPreferences.decode(raw);
    } else {
      _preferences = const NotificationPreferences();
    }
  }

  Future<void> _loadHistory() async {
    final raw = await _storage.getString(_keyHistory);
    _deliveredHistory.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            _deliveredHistory.add(NotificationItem.fromJson(item));
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _loadPermissionStatus() async {
    if (kIsWeb) {
      final webPerm = WebNotificationBridge.permission;
      if (webPerm == 'granted') {
        _permissionStatus = NotificationPermissionStatus.granted;
      } else if (webPerm == 'denied') {
        _permissionStatus = NotificationPermissionStatus.denied;
      } else {
        _permissionStatus = NotificationPermissionStatus.notDetermined;
      }
      return;
    }

    _permissionStatus = await _gateway.permission();
  }

  Future<void> _loadQueue() async {
    final raw = await _storage.getString('studyflow_notifications_queue');
    _scheduledQueue.clear();
    if (raw != null) {
      final items = jsonDecode(raw) as List<dynamic>;
      _scheduledQueue.addAll(
        items.map(
          (i) => NotificationItem.fromJson(Map<String, dynamic>.from(i as Map)),
        ),
      );
    }
  }

  Future<void> _saveQueue() async {
    final success = await _storage.setString(
      'studyflow_notifications_queue',
      jsonEncode(_scheduledQueue.map((i) => i.toJson()).toList()),
    );
    if (!success) throw StateError('Notification queue was not saved');
  }

  Future<void> syncNotifications() async {
    if (!_gateway.handlesScheduling) return;
    final desired = _scheduledQueue
        .where((item) => item.scheduledTime?.isAfter(DateTime.now()) == true)
        .toList();
    if (_preferences.notificationsEnabled &&
        _preferences.dailyBriefingEnabled) {
      final now = DateTime.now();
      var next = DateTime(
        now.year,
        now.month,
        now.day,
        _preferences.dailyBriefingHour,
        _preferences.dailyBriefingMinute,
      );
      if (!next.isAfter(now)) {
        next = DateTime(
          now.year,
          now.month,
          now.day + 1,
          _preferences.dailyBriefingHour,
          _preferences.dailyBriefingMinute,
        );
      }
      desired.add(
        NotificationItem(
          id: 'daily-study',
          title: 'ENote',
          body: 'حان وقت مراجعة خطتك الدراسية / Time to review your study plan',
          type: NotificationType.dailyBriefing,
          channelId: NotificationChannel.dailyBriefing,
          createdAt: now,
          scheduledTime: next,
          payload: const {'repeat': 'daily'},
        ),
      );
    }
    await _gateway.reconcile(_preferences.notificationsEnabled ? desired : []);
  }

  Future<void> clearAllData() async {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _scheduledQueue.clear();
    _deliveredHistory.clear();
    await _gateway.cancelAll();
    await _storage.clear();
    _preferences = const NotificationPreferences();
    _permissionStatus = await _gateway.permission();
    _notifyListeners();
  }

  Future<void> _savePreferences() async {
    final raw = _preferences.encode();
    if (!await _storage.setString(_keyPrefs, raw)) {
      throw StateError('Notification preferences not saved');
    }
    _notifyListeners();
  }

  Future<void> _saveHistory() async {
    final list = _deliveredHistory.map((e) => e.toJson()).toList();
    final raw = jsonEncode(list);
    if (!await _storage.setString(_keyHistory, raw)) {
      throw StateError('Notification history not saved');
    }
    _notifyListeners();
  }

  Future<void> _savePermissionStatus(
    NotificationPermissionStatus status,
  ) async {
    _permissionStatus = status;
    await _storage.setString(_keyPermission, status.name);
    _notifyListeners();
  }

  /// Request notification permission across Web and Native platforms.
  Future<NotificationPermissionStatus> requestPermission() async {
    if (kIsWeb || WebNotificationBridge.isSupported) {
      final webResult = await WebNotificationBridge.requestPermission();
      if (webResult == 'granted') {
        await _savePermissionStatus(NotificationPermissionStatus.granted);
        return NotificationPermissionStatus.granted;
      } else {
        await _savePermissionStatus(NotificationPermissionStatus.denied);
        return NotificationPermissionStatus.denied;
      }
    }

    final status = await _gateway.permission(request: true);
    await _savePermissionStatus(status);
    return status;
  }

  /// Update user notification preferences and persist.
  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    _preferences = newPreferences;
    await _savePreferences();
    await syncNotifications();
  }

  /// Check if a specific notification type is allowed by user preferences.
  bool isNotificationTypeEnabled(NotificationType type) {
    if (!_preferences.notificationsEnabled) return false;
    switch (type) {
      case NotificationType.taskReminder:
        return _preferences.taskRemindersEnabled;
      case NotificationType.pomodoro:
        return _preferences.pomodoroAlertsEnabled;
      case NotificationType.goalDeadline:
        return _preferences.goalAlertsEnabled;
      case NotificationType.dailyBriefing:
        return _preferences.dailyBriefingEnabled;
      case NotificationType.general:
        return true;
    }
  }

  /// Trigger an immediate notification and deliver to Notifications Center.
  Future<NotificationItem?> showNotification({
    String? id,
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String channelId = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? payload,
  }) async {
    if (!isNotificationTypeEnabled(type)) {
      return null;
    }

    final notifId =
        id ??
        'notif_${DateTime.now().millisecondsSinceEpoch}_${_deliveredHistory.length}';
    final item = NotificationItem(
      id: notifId,
      title: title,
      body: body,
      type: type,
      channelId: channelId,
      createdAt: DateTime.now(),
      isDelivered: true,
      isRead: false,
      priority: priority,
      payload: payload,
    );

    // Forward to Web Notifications API if running in browser
    if (kIsWeb || WebNotificationBridge.isSupported) {
      WebNotificationBridge.showNotification(
        title: title,
        body: body,
        tag: notifId,
      );
    }

    if (!kIsWeb && _permissionStatus.isGranted) await _gateway.show(item);
    _deliveredHistory.insert(0, item);

    // Cap history size to 100 items for performance
    if (_deliveredHistory.length > 100) {
      _deliveredHistory.removeRange(100, _deliveredHistory.length);
    }

    await _saveHistory();
    return item;
  }

  /// Schedule a notification to be delivered at a future [scheduledTime].
  Future<NotificationItem?> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotificationType type = NotificationType.general,
    String channelId = NotificationChannel.general,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? payload,
  }) async {
    if (!isNotificationTypeEnabled(type)) {
      return null;
    }

    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) {
      // If time has already passed, deliver immediately
      return showNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        channelId: channelId,
        priority: priority,
        payload: payload,
      );
    }

    // Cancel any existing schedule with the same ID
    await cancelScheduledNotification(id);

    final item = NotificationItem(
      id: id,
      title: title,
      body: body,
      type: type,
      channelId: channelId,
      createdAt: now,
      scheduledTime: scheduledTime,
      isDelivered: false,
      isRead: false,
      priority: priority,
      payload: payload,
    );

    _scheduledQueue.add(item);
    await _saveQueue();
    if (_gateway.handlesScheduling) {
      await syncNotifications();
      _notifyListeners();
      return item;
    }

    final duration = scheduledTime.difference(now);
    final timer = Timer(duration, () async {
      _scheduledQueue.removeWhere((e) => e.id == id);
      _activeTimers.remove(id);
      await showNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        channelId: channelId,
        priority: priority,
        payload: payload,
      );
    });

    _activeTimers[id] = timer;
    _notifyListeners();
    return item;
  }

  /// Cancel a specific scheduled notification.
  Future<void> cancelScheduledNotification(String id) async {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
    _scheduledQueue.removeWhere((e) => e.id == id);
    await _saveQueue();
    await syncNotifications();
    _notifyListeners();
  }

  /// Cancel all currently scheduled notifications.
  void cancelAllScheduled() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    _scheduledQueue.clear();
    _notifyListeners();
  }

  /// Schedule a 15-minute (or customized) advance reminder for a task.
  Future<NotificationItem?> scheduleTaskReminder(
    TaskModel task, {
    int? minutesBefore,
  }) async {
    final minutes = minutesBefore ?? _preferences.taskReminderMinutesBefore;

    DateTime? taskDateTime;
    try {
      final dateParts = task.date.split('-');
      final timeParts = task.startTime.split(':');
      if (dateParts.length == 3 && timeParts.length >= 2) {
        taskDateTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      }
    } catch (_) {
      taskDateTime = null;
    }

    taskDateTime ??= DateTime.now().add(const Duration(hours: 1));
    final reminderTime = taskDateTime.subtract(Duration(minutes: minutes));

    final isUrgent = task.priority.toLowerCase() == 'high';
    final reminderId = 'task_reminder_${task.id}';

    return scheduleNotification(
      id: reminderId,
      title: '⏰ تذكير بمهمة: ${task.title}',
      body:
          'تبدأ المهمة خلال $minutes دقيقة (${task.startTime}). استعد وركز لتحقيق هدفك!',
      scheduledTime: reminderTime,
      type: NotificationType.taskReminder,
      channelId: NotificationChannel.tasks,
      priority: isUrgent
          ? NotificationPriority.urgent
          : NotificationPriority.high,
      payload: {'route': '/planner', 'taskId': task.id, 'taskDate': task.date},
    );
  }

  /// Trigger immediate Pomodoro study or break completion notification.
  Future<NotificationItem?> triggerPomodoroFinishNotification({
    required bool isWorkSession,
    int? sessionCount,
  }) async {
    if (isWorkSession) {
      return showNotification(
        id: 'pomodoro_study_${DateTime.now().millisecondsSinceEpoch}',
        title: '🍅 انتهت جلسة التركيز!',
        body: sessionCount != null
            ? 'عمل بطولي! أتممت الجلسة رقم $sessionCount بنجاح. حان وقت استراحة مستحقة ☕'
            : 'عمل رائع! أنهيت جلسة التركيز بنجاح. خذ استراحة قصيرة واشرب الماء ☕',
        type: NotificationType.pomodoro,
        channelId: NotificationChannel.pomodoro,
        priority: NotificationPriority.urgent,
        payload: {'route': '/pomodoro', 'action': 'break_ready'},
      );
    } else {
      return showNotification(
        id: 'pomodoro_break_${DateTime.now().millisecondsSinceEpoch}',
        title: '⚡ انتهت فترة الاستراحة!',
        body: 'أنت الآن بكامل طاقتك! لنبدأ جلسة تركيز جديدة ونواصل الإنجاز 🎯',
        type: NotificationType.pomodoro,
        channelId: NotificationChannel.pomodoro,
        priority: NotificationPriority.urgent,
        payload: {'route': '/pomodoro', 'action': 'study_ready'},
      );
    }
  }

  /// Analyze goals and trigger urgent warnings or celebratory notifications.
  Future<List<NotificationItem>> checkAndNotifyGoalDeadlines(
    List<GoalModel> goals,
  ) async {
    final dispatched = <NotificationItem>[];
    final now = DateTime.now();

    for (final goal in goals) {
      DateTime? deadlineDate;
      try {
        deadlineDate = DateTime.parse(goal.deadline);
      } catch (_) {
        continue;
      }

      final daysLeft = deadlineDate.difference(now).inDays;
      final percent = goal.progressPercentage.round();

      if (percent >= 100) {
        final notif = await showNotification(
          id: 'goal_completed_${goal.id}',
          title: '🎯 هدف مكتمل بنجاح!',
          body:
              'تهانينا! حققت هدف "${goal.title}" بالكامل بنسبة 100%. استمر في التألق! 🚀',
          type: NotificationType.goalDeadline,
          channelId: NotificationChannel.goals,
          priority: NotificationPriority.high,
          payload: {'route': '/goals', 'goalId': goal.id},
        );
        if (notif != null) dispatched.add(notif);
      } else if (daysLeft <= 0) {
        final notif = await showNotification(
          id: 'goal_overdue_${goal.id}',
          title: '🚨 تنبيه انتهاء موعد الهدف',
          body:
              'انتهت المهلة المحددة لهدف "${goal.title}" ونسبة الإنجاز $percent%. راجع الهدف أو قم بتمديده.',
          type: NotificationType.goalDeadline,
          channelId: NotificationChannel.goals,
          priority: NotificationPriority.urgent,
          payload: {'route': '/goals', 'goalId': goal.id},
        );
        if (notif != null) dispatched.add(notif);
      } else if (daysLeft <= 3 && percent < 75) {
        final notif = await showNotification(
          id: 'goal_urgent_${goal.id}',
          title: '⚠️ تنبيه عاجل لاقتراب موعد الهدف',
          body:
              'متبقي $daysLeft أيام فقط على هدف "${goal.title}" وإنجازك $percent%. كثف جهودك لتداركه!',
          type: NotificationType.goalDeadline,
          channelId: NotificationChannel.goals,
          priority: NotificationPriority.urgent,
          payload: {'route': '/goals', 'goalId': goal.id},
        );
        if (notif != null) dispatched.add(notif);
      }
    }

    return dispatched;
  }

  /// Generate and trigger morning daily briefing notification.
  Future<NotificationItem?> generateDailyBriefing({
    required List<TaskModel> todayTasks,
    required List<GoalModel> activeGoals,
    String? studentName,
  }) async {
    final name = studentName != null && studentName.trim().isNotEmpty
        ? studentName.trim().split(' ').first
        : 'يا بطل';

    final tasksCount = todayTasks.length;
    final goalsCount = activeGoals.length;

    final body = tasksCount > 0
        ? 'لديك اليوم $tasksCount مهام مجدولة و $goalsCount أهداف قيد المتابعة. ابدأ بالمهمة الأولى واجعل يومك مثمراً!'
        : 'يومك فارغ حتى الآن! خطط لمهامك اليوم في المخطط الدراسي لتنظيم وقتك بذكاء.';

    return showNotification(
      id: 'daily_briefing_${DateTime.now().toIso8601String().split('T').first}',
      title: '☀️ صباح الهمة والنشاط، $name!',
      body: body,
      type: NotificationType.dailyBriefing,
      channelId: NotificationChannel.dailyBriefing,
      priority: NotificationPriority.normal,
      payload: {'route': '/dashboard'},
    );
  }

  /// Mark an individual notification as read.
  Future<void> markAsRead(String id) async {
    final index = _deliveredHistory.indexWhere((e) => e.id == id);
    if (index != -1 && !_deliveredHistory[index].isRead) {
      _deliveredHistory[index] = _deliveredHistory[index].copyWith(
        isRead: true,
      );
      await _saveHistory();
    }
  }

  /// Mark all delivered notifications as read.
  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _deliveredHistory.length; i++) {
      if (!_deliveredHistory[i].isRead) {
        _deliveredHistory[i] = _deliveredHistory[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      await _saveHistory();
    }
  }

  /// Delete a single notification from history.
  Future<void> deleteNotification(String id) async {
    _deliveredHistory.removeWhere((e) => e.id == id);
    await _saveHistory();
  }

  /// Clear all notifications from history.
  Future<void> clearAllDelivered() async {
    _deliveredHistory.clear();
    await _saveHistory();
  }

  /// Clear in-memory caches and reset service (for test teardowns).
  void resetForTesting() {
    cancelAllScheduled();
    _deliveredHistory.clear();
    _preferences = const NotificationPreferences();
    _permissionStatus = NotificationPermissionStatus.notDetermined;
    _listeners.clear();
    _storage.clear();
    WebNotificationBridge.resetMock();
  }
}
