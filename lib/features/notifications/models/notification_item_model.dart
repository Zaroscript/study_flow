import 'dart:convert';

/// Types of notifications supported by StudyFlow.
enum NotificationType {
  taskReminder,
  pomodoro,
  goalDeadline,
  dailyBriefing,
  general;

  String get displayName {
    switch (this) {
      case NotificationType.taskReminder:
        return 'تذكير مهمة';
      case NotificationType.pomodoro:
        return 'مؤقت التركيز';
      case NotificationType.goalDeadline:
        return 'تنبيه الأهداف';
      case NotificationType.dailyBriefing:
        return 'الملخص الصباحي';
      case NotificationType.general:
        return 'إشعار عام';
    }
  }
}

/// Notification priority levels.
enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case NotificationPriority.low:
        return 'منخفضة';
      case NotificationPriority.normal:
        return 'عادية';
      case NotificationPriority.high:
        return 'مهمة';
      case NotificationPriority.urgent:
        return 'عاجلة';
    }
  }
}

/// Permission statuses for notifications.
enum NotificationPermissionStatus {
  granted,
  denied,
  provisional,
  notDetermined;

  bool get isGranted => this == NotificationPermissionStatus.granted;
}

/// Channel definition for grouped notifications.
class NotificationChannel {
  final String id;
  final String name;
  final String description;
  final NotificationPriority importance;
  final bool sound;
  final bool vibration;

  const NotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    this.importance = NotificationPriority.normal,
    this.sound = true,
    this.vibration = true,
  });

  static const String tasks = 'studyflow_tasks_channel';
  static const String pomodoro = 'studyflow_pomodoro_channel';
  static const String goals = 'studyflow_goals_channel';
  static const String dailyBriefing = 'studyflow_briefing_channel';
  static const String general = 'studyflow_general_channel';

  static const List<NotificationChannel> defaultChannels = [
    NotificationChannel(
      id: tasks,
      name: 'تذكير المهام والجدول الدراسي',
      description: 'إشعارات تذكيرية قبل بدء المهام المجدولة في خطتك الدراسية',
      importance: NotificationPriority.high,
    ),
    NotificationChannel(
      id: pomodoro,
      name: 'مؤقت التركيز والاستراحة',
      description: 'تنبيهات فورية عند انتهاء جلسات التركيز أو فترات الاستراحة',
      importance: NotificationPriority.urgent,
    ),
    NotificationChannel(
      id: goals,
      name: 'تنبيهات الأهداف والمواعيد النهائية',
      description:
          'تحذيرات لاقتراب الموعد النهائي للأهداف أو الاحتفال بإنجازها',
      importance: NotificationPriority.high,
    ),
    NotificationChannel(
      id: dailyBriefing,
      name: 'الملخص الصباحي اليومي',
      description: 'نظرة عامة على مهام اليوم وأهدافك كل صباح لبدء اليوم بنشاط',
      importance: NotificationPriority.normal,
    ),
    NotificationChannel(
      id: general,
      name: 'تنبيهات عامة',
      description: 'تحديثات وإشعارات النظام العامة',
      importance: NotificationPriority.low,
    ),
  ];
}

/// Represents an individual notification in StudyFlow.
class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String channelId;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final bool isRead;
  final bool isDelivered;
  final NotificationPriority priority;
  final Map<String, dynamic>? payload;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.channelId = NotificationChannel.general,
    required this.createdAt,
    this.scheduledTime,
    this.isRead = false,
    this.isDelivered = false,
    this.priority = NotificationPriority.normal,
    this.payload,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? channelId,
    DateTime? createdAt,
    DateTime? scheduledTime,
    bool? isRead,
    bool? isDelivered,
    NotificationPriority? priority,
    Map<String, dynamic>? payload,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      channelId: channelId ?? this.channelId,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      priority: priority ?? this.priority,
      payload: payload ?? this.payload,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'channelId': channelId,
      'createdAt': createdAt.toIso8601String(),
      'scheduledTime': scheduledTime?.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'priority': priority.name,
      'payload': payload,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => NotificationType.general,
      ),
      channelId: json['channelId'] as String? ?? NotificationChannel.general,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.tryParse(json['scheduledTime'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      isDelivered: json['isDelivered'] as bool? ?? false,
      priority: NotificationPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String?),
        orElse: () => NotificationPriority.normal,
      ),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }
}

/// User notification preferences model.
class NotificationPreferences {
  final bool notificationsEnabled;
  final bool taskRemindersEnabled;
  final int taskReminderMinutesBefore;
  final bool pomodoroAlertsEnabled;
  final bool goalAlertsEnabled;
  final bool dailyBriefingEnabled;
  final int dailyBriefingHour;
  final int dailyBriefingMinute;
  final bool soundEnabled;
  final bool vibrationEnabled;

  const NotificationPreferences({
    this.notificationsEnabled = true,
    this.taskRemindersEnabled = true,
    this.taskReminderMinutesBefore = 15,
    this.pomodoroAlertsEnabled = true,
    this.goalAlertsEnabled = true,
    this.dailyBriefingEnabled = false,
    this.dailyBriefingHour = 8,
    this.dailyBriefingMinute = 0,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? notificationsEnabled,
    bool? taskRemindersEnabled,
    int? taskReminderMinutesBefore,
    bool? pomodoroAlertsEnabled,
    bool? goalAlertsEnabled,
    bool? dailyBriefingEnabled,
    int? dailyBriefingHour,
    int? dailyBriefingMinute,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      taskRemindersEnabled: taskRemindersEnabled ?? this.taskRemindersEnabled,
      taskReminderMinutesBefore:
          taskReminderMinutesBefore ?? this.taskReminderMinutesBefore,
      pomodoroAlertsEnabled:
          pomodoroAlertsEnabled ?? this.pomodoroAlertsEnabled,
      goalAlertsEnabled: goalAlertsEnabled ?? this.goalAlertsEnabled,
      dailyBriefingEnabled: dailyBriefingEnabled ?? this.dailyBriefingEnabled,
      dailyBriefingHour: dailyBriefingHour ?? this.dailyBriefingHour,
      dailyBriefingMinute: dailyBriefingMinute ?? this.dailyBriefingMinute,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'taskRemindersEnabled': taskRemindersEnabled,
      'taskReminderMinutesBefore': taskReminderMinutesBefore,
      'pomodoroAlertsEnabled': pomodoroAlertsEnabled,
      'goalAlertsEnabled': goalAlertsEnabled,
      'dailyBriefingEnabled': dailyBriefingEnabled,
      'dailyBriefingHour': dailyBriefingHour,
      'dailyBriefingMinute': dailyBriefingMinute,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      taskRemindersEnabled: json['taskRemindersEnabled'] as bool? ?? true,
      taskReminderMinutesBefore:
          (json['taskReminderMinutesBefore'] as num?)?.toInt() ?? 15,
      pomodoroAlertsEnabled: json['pomodoroAlertsEnabled'] as bool? ?? true,
      goalAlertsEnabled: json['goalAlertsEnabled'] as bool? ?? true,
      dailyBriefingEnabled: json['dailyBriefingEnabled'] as bool? ?? false,
      dailyBriefingHour: (json['dailyBriefingHour'] as num?)?.toInt() ?? 8,
      dailyBriefingMinute: (json['dailyBriefingMinute'] as num?)?.toInt() ?? 0,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }

  String encode() => jsonEncode(toJson());

  static NotificationPreferences decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return NotificationPreferences.fromJson(map);
    } catch (_) {
      return const NotificationPreferences();
    }
  }
}
