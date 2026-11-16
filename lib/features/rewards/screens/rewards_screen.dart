import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/page_header.dart';
import '../providers/rewards_provider.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'المكافآت والأوسمة',
            description: 'نظام التحفيز والنقاط لمكافأة إنجازك الدراسي المستمر',
          ),
          const SizedBox(height: 8),

          // 1. Level & XP Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'المستوى ${rewards.level}',
                        style: AppTextStyles.cairo(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${rewards.currentXP} XP',
                      style: AppTextStyles.cairo(
                        color: const Color(0xFFFDE047), // Gold
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  rewards.levelTitle,
                  style: AppTextStyles.cairo(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'متبقي ${rewards.nextLevelTargetXP - rewards.currentXP} XP للوصول إلى المستوى ${rewards.level + 1}',
                  style: AppTextStyles.cairo(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // XP Progress bar
                AppProgressBar(
                  progress: rewards.levelProgress,
                  color: const Color(0xFFFDE047), // Yellow gold
                  backgroundColor: Colors.white.withOpacity(0.2),
                  height: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Streaks Card
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السلسلة الحالية',
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${rewards.streakDays} أيام',
                            style: AppTextStyles.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text('⭐', style: TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أفضل إنجاز',
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${rewards.bestStreak} أيام',
                            style: AppTextStyles.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Badges Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أوسمة وشارات الإنجاز',
                style: AppTextStyles.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${rewards.badges.where((b) => b.isUnlocked).length}/${rewards.badges.length} مفتوح',
                style: AppTextStyles.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rewards.badges.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisExtent:
                  320 * (MediaQuery.textScalerOf(context).scale(16) / 16),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (ctx, i) {
              final badge = rewards.badges[i];
              return AppCard(
                padding: const EdgeInsets.all(16),
                color: badge.isUnlocked
                    ? (isDark ? AppColors.cardDark : Colors.white)
                    : (isDark
                          ? const Color(0xFF131C2E)
                          : const Color(0xFFF1F5F9)),
                border: Border.all(
                  color: badge.isUnlocked
                      ? const Color(0xFFF59E0B).withOpacity(0.4)
                      : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                  width: badge.isUnlocked ? 1.5 : 1,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: badge.isUnlocked
                                ? const Color(0xFFFEF3C7) // Light gold
                                : (isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            badge.icon,
                            style: TextStyle(
                              fontSize: 26,
                              color: badge.isUnlocked ? null : Colors.grey,
                            ),
                          ),
                        ),
                        if (!badge.isUnlocked)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.lock_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      badge.title,
                      style: AppTextStyles.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked ? null : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge.description,
                      style: AppTextStyles.cairo(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+${badge.xpReward} XP',
                        style: AppTextStyles.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 4. How to earn XP Guide
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'كيف تكسب نقاط الخبرة (XP)؟',
                      style: AppTextStyles.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _XPRuleTile(
                  label: 'إنجاز مهمة دراسية في المخطط اليومي',
                  points: '+50 XP',
                ),
                const _XPRuleTile(
                  label: 'إكمال جلسة بومودورو تركيز (25 دقيقة)',
                  points: '+100 XP',
                ),
                const _XPRuleTile(
                  label: 'إنهاء واجب مدرسي وتسليمه في موعده',
                  points: '+150 XP',
                ),
                const _XPRuleTile(
                  label: 'تحقيق هدف دراسي كامل بنسبة 100%',
                  points: '+300 XP',
                ),
                const _XPRuleTile(
                  label: 'الحفاظ على سلسلة المذاكرة اليومية',
                  points: '+30 XP',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _XPRuleTile extends StatelessWidget {
  final String label;
  final String points;

  const _XPRuleTile({required this.label, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.cairo(fontSize: 13)),
          Text(
            points,
            style: AppTextStyles.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
