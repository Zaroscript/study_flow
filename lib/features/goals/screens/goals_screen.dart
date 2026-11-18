import 'package:study_flow/core/utils/app_validators.dart';
import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/goal_notification_model.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../services/goals_smart_service.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Color _resolveColor(String colorKey) {
    switch (colorKey) {
      case 'green':
      case 'bg-green-500':
        return AppColors.success;
      case 'indigo':
      case 'bg-indigo-500':
        return AppColors.primary;
      case 'blue':
      case 'bg-blue-500':
        return AppColors.info;
      case 'yellow':
      case 'bg-yellow-500':
        return AppColors.warning;
      case 'pink':
      case 'bg-pink-500':
        return AppColors.secondary;
      case 'red':
      case 'bg-red-500':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '10');
    final currentCtrl = TextEditingController(text: '0');
    final deadlineCtrl = TextEditingController(
      text: DateTime.now()
          .add(const Duration(days: 30))
          .toIso8601String()
          .split('T')[0],
    );
    String selectedColor = 'green';

    final colorOptions = [
      const DropdownOption(value: 'green', label: 'أخضر'),
      const DropdownOption(value: 'indigo', label: 'بنفسجي'),
      const DropdownOption(value: 'blue', label: 'أزرق'),
      const DropdownOption(value: 'yellow', label: 'أصفر'),
      const DropdownOption(value: 'pink', label: 'وردي'),
      const DropdownOption(value: 'red', label: 'أحمر'),
    ];

    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('إضافة هدف دراسي جديد'),
                      style: AppTextStyles.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      tooltip: context.tr('إغلاق'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'عنوان الهدف',
                  validation: FieldValidation.required,
                  hint: 'مثال: إنهاء 5 فصول من الكيمياء',
                  controller: titleCtrl,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'الهدف الإجمالي',
                        validation: FieldValidation.positiveInteger,
                        controller: targetCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'الإنجاز الحالي',
                        validation: FieldValidation.nonNegativeInteger,
                        controller: currentCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'تاريخ الانتهاء',
                  validation: FieldValidation.date,
                  controller: deadlineCtrl,
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: 'لون الهدف',
                  value: selectedColor,
                  options: colorOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedColor = val);
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'حفظ الهدف (+300 XP عند الاكتمال)',
                  isFullWidth: true,
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final target = AppValidators.parseInt(targetCtrl.text);
                    final current = AppValidators.parseInt(currentCtrl.text);
                    if (target == null ||
                        target < 1 ||
                        current == null ||
                        current < 0 ||
                        current > target) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.tr(
                              'الإنجاز الحالي يجب أن يكون بين صفر والهدف الإجمالي.',
                            ),
                          ),
                        ),
                      );
                      return;
                    }
                    if (title.isNotEmpty) {
                      final newGoal = GoalModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        target: AppValidators.parseInt(targetCtrl.text) ?? 10,
                        current: AppValidators.parseInt(currentCtrl.text) ?? 0,
                        deadline: deadlineCtrl.text.trim(),
                        color: selectedColor,
                      );
                      ref.read(goalsProvider.notifier).addGoal(newGoal);
                      Navigator.pop(ctx);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alerts = GoalsSmartService.analyzeGoals(goals);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'الأهداف الذكية',
            description:
                'نظام تتبع الأهداف، تحليل وتيرة الإنجاز، والتنبيهات الاستباقية',
            action: AppButton(
              text: 'هدف جديد',
              icon: Icons.add,
              onPressed: () => _showAddGoalSheet(context, ref),
            ),
          ),
          const SizedBox(height: 4),

          // 1. Smart Goals Alerts Center
          if (alerts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr(
                            'إشعارات وتنبيهات الأهداف (Goals Notifier)',
                          ),
                          style: AppTextStyles.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...alerts.map((alert) {
                    Color alertColor = AppColors.primary;
                    if (alert.type == GoalAlertType.danger) {
                      alertColor = AppColors.danger;
                    }
                    if (alert.type == GoalAlertType.warning) {
                      alertColor = AppColors.warning;
                    }
                    if (alert.type == GoalAlertType.success) {
                      alertColor = AppColors.success;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: alertColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border(
                          right: BorderSide(color: alertColor, width: 3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.goalTitle,
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: alertColor,
                            ),
                          ),
                          Text(
                            alert.message,
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (goals.isEmpty)
            AppEmptyState.initial(
              title: 'لا توجد أهداف مسجلة حالياً',
              description:
                  'حدد أهدافك الدراسية الكبيرة وتابع إنجازك خطوة بخطوة.',
              icon: Icons.track_changes_rounded,
              actionLabel: 'إضافة هدف',
              onAction: () => _showAddGoalSheet(context, ref),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final goal = goals[i];
                final goalColor = _resolveColor(goal.color);
                final percent = goal.progressPercentage.round();

                return AppCard(
                  padding: const EdgeInsets.all(18),
                  border: Border(
                    right: BorderSide(color: goalColor, width: 1),
                    top: BorderSide(color: Theme.of(context).dividerColor),
                    left: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: AppTextStyles.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.track_changes_rounded,
                            color: goalColor,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('التقدم الإجمالي'),
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: goalColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      AppProgressBar(
                        progress: percent / 100.0,
                        color: goalColor,
                        height: 8,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text(
                            context.l10n.message0d5e44a09a(
                              context.display(goal.target),
                              context.display(goal.current),
                              context.display(goal.deadline),
                            ),
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle_outline,
                                  size: 24,
                                ),
                                color: goalColor,
                                tooltip: context.tr('إضافة تقدم (+1)'),
                                onPressed: () async {
                                  if (goal.current >= goal.target) return;
                                  final newCurrent = goal.current + 1;
                                  await ref
                                      .read(goalsProvider.notifier)
                                      .incrementGoal(goal.id);
                                  if (!context.mounted) return;
                                  ref.read(rewardsProvider.notifier).addXP(10);
                                  if (newCurrent >= goal.target) {
                                    AppHaptics.milestone();
                                    ref
                                        .read(rewardsProvider.notifier)
                                        .addXP(
                                          300,
                                          reason: 'تحقيق هدف دراسي 100%',
                                        );
                                    ref
                                        .read(rewardsProvider.notifier)
                                        .unlockBadge('b4');
                                  } else {
                                    AppHaptics.medium();
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: context.tr('حذف العنصر'),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: AppColors.danger,
                                ),
                                onPressed: () {
                                  deleteWithUndo(
                                    context,
                                    onDelete: () => ref
                                        .read(goalsProvider.notifier)
                                        .deleteGoal(goal.id),
                                    onUndo: () => ref
                                        .read(goalsProvider.notifier)
                                        .addGoal(goal),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
