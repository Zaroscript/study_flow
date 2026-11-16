import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_haptics.dart';
import '../../../data/models/user_rewards_model.dart';

final rewardsProvider = StateNotifierProvider<RewardsNotifier, UserRewards>((
  ref,
) {
  return RewardsNotifier();
});

class RewardsNotifier extends StateNotifier<UserRewards> {
  RewardsNotifier()
    : super(
        const UserRewards(
          currentXP: 350,
          streakDays: 3,
          bestStreak: 5,
          badges: [
            BadgeItem(
              id: 'b1',
              title: 'شعلة البداية',
              description: 'أكملت أول مهمة دراسية في المخطط اليومي',
              icon: '🔥',
              isUnlocked: true,
              unlockedDate: '2026-11-14',
              xpReward: 50,
            ),
            BadgeItem(
              id: 'b2',
              title: 'سيد التركيز',
              description: 'أكملت أول جلسة بومودورو بنجاح دون انقطاع',
              icon: '⏱️',
              isUnlocked: true,
              unlockedDate: '2026-11-14',
              xpReward: 100,
            ),
            BadgeItem(
              id: 'b3',
              title: 'المتفوق الملتزم',
              description: 'أنجزت 5 مهام دراسية في أسبوع واحد',
              icon: '🏆',
              isUnlocked: true,
              unlockedDate: '2026-11-15',
              xpReward: 150,
            ),
            BadgeItem(
              id: 'b4',
              title: 'صائد الأهداف',
              description: 'حققت هدفاً دراسياً كاملاً بنسبة 100%',
              icon: '🎯',
              isUnlocked: false,
              xpReward: 300,
            ),
            BadgeItem(
              id: 'b5',
              title: 'منظم المكتبة',
              description: 'أضفت أول كتاب أو مذكرة لمكتبة المواد الدراسية',
              icon: '📚',
              isUnlocked: false,
              xpReward: 75,
            ),
            BadgeItem(
              id: 'b6',
              title: 'سلسلة الإصرار',
              description: 'حافظت على عاداتك والمذاكرة لمدة 7 أيام متتالية',
              icon: '⚡',
              isUnlocked: false,
              xpReward: 250,
            ),
          ],
        ),
      );

  void addXP(int amount, {String? reason}) {
    final oldLevel = state.level;
    final newXP = state.currentXP + amount;
    final updated = state.copyWith(currentXP: newXP);
    if (updated.level > oldLevel) {
      AppHaptics.milestone();
    } else {
      AppHaptics.medium();
    }
    state = updated;
  }

  void unlockBadge(String badgeId) {
    final nowStr = DateTime.now().toIso8601String().split('T').first;
    final updatedBadges = state.badges.map((b) {
      if (b.id == badgeId && !b.isUnlocked) {
        AppHaptics.milestone();
        addXP(b.xpReward);
        return b.copyWith(isUnlocked: true, unlockedDate: nowStr);
      }
      return b;
    }).toList();

    state = state.copyWith(badges: updatedBadges);
  }

  void incrementStreak() {
    final newStreak = state.streakDays + 1;
    final best = newStreak > state.bestStreak ? newStreak : state.bestStreak;
    state = state.copyWith(streakDays: newStreak, bestStreak: best);
    addXP(30); // streak bonus
  }
}
