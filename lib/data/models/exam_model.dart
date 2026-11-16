class ExamModel {
  final String id;
  final String subject;
  final String date;
  final String time;
  final String location;
  final String priority;

  const ExamModel({
    required this.id,
    required this.subject,
    required this.date,
    required this.time,
    this.location = '',
    this.priority = 'high',
  });

  ExamModel copyWith({
    String? id,
    String? subject,
    String? date,
    String? time,
    String? location,
    String? priority,
  }) {
    return ExamModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      priority: priority ?? this.priority,
    );
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      priority: json['priority'] as String? ?? 'high',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'date': date,
      'time': time,
      'location': location,
      'priority': priority,
    };
  }
}
