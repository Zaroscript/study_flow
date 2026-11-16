class HabitModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final Map<String, bool> history; // key: 'YYYY-MM-DD', value: completed

  const HabitModel({
    required this.id,
    required this.name,
    this.icon = 'Star',
    this.color = 'indigo',
    this.history = const {},
  });

  bool isCompletedOn(String dateKey) {
    return history[dateKey] ?? false;
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    Map<String, bool>? history,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      history: history ?? this.history,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as Map<String, dynamic>? ?? {};
    final parsedHistory = rawHistory.map(
      (key, value) => MapEntry(key, value as bool? ?? false),
    );

    return HabitModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'Star',
      color: json['color'] as String? ?? 'indigo',
      history: parsedHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'history': history,
    };
  }
}
