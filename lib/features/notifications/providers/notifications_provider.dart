import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item_model.dart';
import '../services/notification_service.dart';

/// Singleton NotificationService Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService.instance;
  return service;
});

/// Delivered Notifications List Notifier
final notificationsListProvider =
    StateNotifierProvider<NotificationsListNotifier, List<NotificationItem>>((
      ref,
    ) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationsListNotifier(service);
    });

class NotificationsListNotifier extends StateNotifier<List<NotificationItem>> {
  final NotificationService _service;

  NotificationsListNotifier(this._service) : super(const []) {
    _init();
  }

  void _init() {
    state = _service.deliveredNotifications;
    _service.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    state = _service.deliveredNotifications;
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    if (!mounted) return;
    state = _service.deliveredNotifications;
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    if (!mounted) return;
    state = _service.deliveredNotifications;
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
    if (!mounted) return;
    state = _service.deliveredNotifications;
  }

  Future<void> clearAll() async {
    await _service.clearAllDelivered();
    if (!mounted) return;
    state = _service.deliveredNotifications;
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}

/// Unread Notifications Count Provider
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsListProvider);
  return list.where((n) => !n.isRead).length;
});

/// User Notification Preferences Notifier
final notificationPreferencesProvider =
    StateNotifierProvider<
      NotificationPreferencesNotifier,
      NotificationPreferences
    >((ref) {
      final service = ref.watch(notificationServiceProvider);
      return NotificationPreferencesNotifier(service);
    });

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  final NotificationService _service;

  NotificationPreferencesNotifier(this._service) : super(_service.preferences) {
    _service.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    state = _service.preferences;
  }

  Future<void> updatePreferences(NotificationPreferences newPrefs) async {
    await _service.updatePreferences(newPrefs);
    if (!mounted) return;
    state = newPrefs;
  }

  Future<void> toggleMaster(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleTaskReminders(bool enabled) async {
    final updated = state.copyWith(taskRemindersEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> togglePomodoroAlerts(bool enabled) async {
    final updated = state.copyWith(pomodoroAlertsEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleGoalAlerts(bool enabled) async {
    final updated = state.copyWith(goalAlertsEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleDailyBriefing(bool enabled) async {
    final updated = state.copyWith(dailyBriefingEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleSound(bool enabled) async {
    final updated = state.copyWith(soundEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleVibration(bool enabled) async {
    final updated = state.copyWith(vibrationEnabled: enabled);
    await updatePreferences(updated);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
