class BadgeItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final String? unlockedDate;
  final int xpReward;

  const BadgeItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedDate,
    this.xpReward = 50,
  });

  BadgeItem copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? isUnlocked,
    String? unlockedDate,
    int? xpReward,
  }) {
    return BadgeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  factory BadgeItem.fromJson(Map<String, dynamic> json) {
    return BadgeItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'Star',
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedDate: json['unlockedDate'] as String?,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate,
      'xpReward': xpReward,
    };
  }
}

class UserRewards {
  factory UserRewards.fromJson(Map<String, dynamic> json) => UserRewards(
    currentXP: (json['currentXP'] as num?)?.toInt() ?? 0,
    streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    badges: (json['badges'] as List? ?? [])
        .map((b) => BadgeItem.fromJson(Map<String, dynamic>.from(b as Map)))
        .toList(),
  );
  Map<String, dynamic> toJson() => {
    'currentXP': currentXP,
    'streakDays': streakDays,
    'bestStreak': bestStreak,
    'badges': badges.map((b) => b.toJson()).toList(),
  };
  final int currentXP;
  final int streakDays;
  final int bestStreak;
  final List<BadgeItem> badges;

  const UserRewards({
    this.currentXP = 0,
    this.streakDays = 1,
    this.bestStreak = 1,
    this.badges = const [],
  });

  int get level {
    if (currentXP < 500) return 1;
    if (currentXP < 1500) return 2;
    if (currentXP < 3000) return 3;
    if (currentXP < 6000) return 4;
    return 5;
  }

  String get levelTitle {
    switch (level) {
      case 1:
        return 'مبتدئ شغوف 🌟';
      case 2:
        return 'باحث مجتهد 🚀';
      case 3:
        return 'متفوق واعد 🎯';
      case 4:
        return 'عبقري ENote 💡';
      case 5:
      default:
        return 'أسطورة دراسية 👑';
    }
  }

  int get levelFloorXP {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 500;
      case 3:
        return 1500;
      case 4:
        return 3000;
      case 5:
      default:
        return 6000;
    }
  }

  int get nextLevelTargetXP {
    switch (level) {
      case 1:
        return 500;
      case 2:
        return 1500;
      case 3:
        return 3000;
      case 4:
        return 6000;
      case 5:
      default:
        return 10000;
    }
  }

  double get levelProgress {
    final floor = levelFloorXP;
    final target = nextLevelTargetXP;
    if (target <= floor) return 1.0;
    return ((currentXP - floor) / (target - floor)).clamp(0.0, 1.0);
  }

  UserRewards copyWith({
    int? currentXP,
    int? streakDays,
    int? bestStreak,
    List<BadgeItem>? badges,
  }) {
    return UserRewards(
      currentXP: currentXP ?? this.currentXP,
      streakDays: streakDays ?? this.streakDays,
      bestStreak: bestStreak ?? this.bestStreak,
      badges: badges ?? this.badges,
    );
  }
}
