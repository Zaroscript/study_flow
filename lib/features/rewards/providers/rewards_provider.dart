import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/study_flow_repository.dart';
import '../../common/providers/study_flow_state_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/app_haptics.dart';
import '../../../data/models/user_rewards_model.dart';

final rewardsProvider = StateNotifierProvider<RewardsNotifier, UserRewards>((
  ref,
) {
  return RewardsNotifier(ref.watch(studyFlowRepositoryProvider));
});

class RewardsNotifier extends StateNotifier<UserRewards> {
  final IStudyFlowRepository _repository;
  late final Future<void> _ready;
  Future<void> _writes = Future.value();
  RewardsNotifier(this._repository)
    : super(
        const UserRewards(
          currentXP: 0,
          streakDays: 0,
          bestStreak: 0,
          badges: [
            BadgeItem(
              id: 'b1',
              title: 'شعلة البداية',
              description: 'أكملت أول مهمة دراسية في المخطط اليومي',
              icon: '🔥',
              isUnlocked: false,
              xpReward: 50,
            ),
            BadgeItem(
              id: 'b2',
              title: 'سيد التركيز',
              description: 'أكملت أول جلسة بومودورو بنجاح دون انقطاع',
              icon: '⏱️',
              isUnlocked: false,
              xpReward: 100,
            ),
            BadgeItem(
              id: 'b3',
              title: 'المتفوق الملتزم',
              description: 'أنجزت 5 مهام دراسية في أسبوع واحد',
              icon: '🏆',
              isUnlocked: false,
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
      ) {
    _ready = _load();
    unawaited(_ready.catchError(_report));
  }

  Future<void> _load() async {
    final json = await _repository.getFeatureState('rewards');
    if (mounted && json != null) state = UserRewards.fromJson(json);
  }

  void _report(Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'ENote storage',
      ),
    );
  }

  Future<void> flush() => _writes;
  void _commit(UserRewards Function(UserRewards) change) {
    final write = _writes.then((_) async {
      await _ready;
      if (!mounted) return;
      final next = change(state);
      await _repository.saveFeatureState('rewards', next.toJson());
      if (mounted) state = next;
    });
    _writes = write.catchError(_report);
  }

  void addXP(int amount, {String? reason}) {
    if (amount <= 0) return;
    _commit(
      (current) => current.copyWith(currentXP: current.currentXP + amount),
    );
    AppHaptics.medium();
  }

  void unlockBadge(String badgeId) {
    _commit((current) {
      final index = current.badges.indexWhere(
        (b) => b.id == badgeId && !b.isUnlocked,
      );
      if (index < 0) return current;
      final badge = current.badges[index];
      final badges = [...current.badges];
      badges[index] = badge.copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now().toIso8601String().split('T').first,
      );
      return current.copyWith(
        badges: badges,
        currentXP: current.currentXP + badge.xpReward,
      );
    });
  }

  void incrementStreak() {
    _commit((current) {
      final next = current.streakDays + 1;
      return current.copyWith(
        streakDays: next,
        bestStreak: next > current.bestStreak ? next : current.bestStreak,
      );
    });
  }
}
