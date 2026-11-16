class HomeworkModel {
  final String id;
  final String subject;
  final String description;
  final String deadline;
  final String priority; // high, medium, low
  final String status; // 'pending' | 'completed'

  const HomeworkModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.deadline,
    this.priority = 'medium',
    this.status = 'pending',
  });

  bool get isCompleted => status == 'completed';

  HomeworkModel copyWith({
    String? id,
    String? subject,
    String? description,
    String? deadline,
    String? priority,
    String? status,
  }) {
    return HomeworkModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'deadline': deadline,
      'priority': priority,
      'status': status,
    };
  }
}
