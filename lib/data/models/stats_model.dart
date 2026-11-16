class StudyStats {
  final int studyTimeMinutes;
  final int tasksCompleted;
  final int focusScore;

  const StudyStats({
    this.studyTimeMinutes = 0,
    this.tasksCompleted = 0,
    this.focusScore = 85,
  });

  String get formattedStudyTime {
    final hours = studyTimeMinutes ~/ 60;
    final mins = studyTimeMinutes % 60;
    return '${hours}h ${mins}m';
  }

  StudyStats copyWith({
    int? studyTimeMinutes,
    int? tasksCompleted,
    int? focusScore,
  }) {
    return StudyStats(
      studyTimeMinutes: studyTimeMinutes ?? this.studyTimeMinutes,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      focusScore: focusScore ?? this.focusScore,
    );
  }

  factory StudyStats.fromJson(Map<String, dynamic> json) {
    return StudyStats(
      studyTimeMinutes: (json['studyTimeMinutes'] as num?)?.toInt() ?? 0,
      tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
      focusScore: (json['focusScore'] as num?)?.toInt() ?? 85,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studyTimeMinutes': studyTimeMinutes,
      'tasksCompleted': tasksCompleted,
      'focusScore': focusScore,
    };
  }
}
