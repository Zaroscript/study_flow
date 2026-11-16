import 'package:flutter/services.dart';

class PomodoroAlarmSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final String soundType; // 'chime', 'digital', 'bell'

  const PomodoroAlarmSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.soundType = 'chime',
  });

  PomodoroAlarmSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? soundType,
  }) {
    return PomodoroAlarmSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundType: soundType ?? this.soundType,
    );
  }
}

class PomodoroAlarmService {
  PomodoroAlarmService._();

  static Future<void> triggerAlarm(PomodoroAlarmSettings settings) async {
    // 1. Vibration alert
    if (settings.vibrationEnabled) {
      try {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 200));
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }

    // 2. System Sound alert
    if (settings.soundEnabled) {
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }
}
