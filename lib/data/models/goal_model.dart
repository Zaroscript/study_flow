class GoalModel {
  final String id;
  final String title;
  final int target;
  final int current;
  final String deadline;
  final String color; // e.g. 'green', 'indigo', 'blue', 'yellow', 'pink', 'red'

  const GoalModel({
    required this.id,
    required this.title,
    required this.target,
    this.current = 0,
    required this.deadline,
    this.color = 'green',
  });

  double get progressPercentage {
    if (target <= 0) return 0.0;
    return ((current / target) * 100).clamp(0.0, 100.0);
  }

  GoalModel copyWith({
    String? id,
    String? title,
    int? target,
    int? current,
    String? deadline,
    String? color,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      target: target ?? this.target,
      current: current ?? this.current,
      deadline: deadline ?? this.deadline,
      color: color ?? this.color,
    );
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      target: (json['target'] as num?)?.toInt() ?? 10,
      current: (json['current'] as num?)?.toInt() ?? 0,
      deadline: json['deadline'] as String? ?? '',
      color: json['color'] as String? ?? 'green',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target': target,
      'current': current,
      'deadline': deadline,
      'color': color,
    };
  }
}
