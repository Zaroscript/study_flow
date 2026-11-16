class TaskModel {
  final String id;
  final String title;
  final String category; // study, school, lesson, homework, etc.
  final String startTime;
  final String endTime;
  final bool completed;
  final String priority; // high, medium, low
  final String date;

  const TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.completed = false,
    this.priority = 'medium',
    required this.date,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? category,
    String? startTime,
    String? endTime,
    bool? completed,
    String? priority,
    String? date,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      date: date ?? this.date,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'study',
      startTime: json['startTime'] as String? ?? '09:00',
      endTime: json['endTime'] as String? ?? '10:00',
      completed: json['completed'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'startTime': startTime,
      'endTime': endTime,
      'completed': completed,
      'priority': priority,
      'date': date,
    };
  }
}
