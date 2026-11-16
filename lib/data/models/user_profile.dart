class UserProfile {
  final String name;
  final String grade;
  final String? phone;

  const UserProfile({required this.name, required this.grade, this.phone});

  UserProfile copyWith({String? name, String? grade, String? phone}) {
    return UserProfile(
      name: name ?? this.name,
      grade: grade ?? this.grade,
      phone: phone ?? this.phone,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'grade': grade, 'phone': phone};
  }
}
