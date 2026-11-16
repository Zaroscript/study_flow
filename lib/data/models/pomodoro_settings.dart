class PomodoroSettings {
  final int study; // minutes
  final int breakDuration; // minutes
  final int longBreak; // minutes

  const PomodoroSettings({
    this.study = 25,
    this.breakDuration = 5,
    this.longBreak = 15,
  });

  PomodoroSettings copyWith({int? study, int? breakDuration, int? longBreak}) {
    return PomodoroSettings(
      study: study ?? this.study,
      breakDuration: breakDuration ?? this.breakDuration,
      longBreak: longBreak ?? this.longBreak,
    );
  }

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      study: (json['study'] as num?)?.toInt() ?? 25,
      breakDuration: (json['break'] as num?)?.toInt() ?? 5,
      longBreak: (json['longBreak'] as num?)?.toInt() ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {'study': study, 'break': breakDuration, 'longBreak': longBreak};
  }
}
