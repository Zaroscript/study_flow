import 'package:flutter/material.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/homework_model.dart';
import '../../common/providers/study_flow_state_provider.dart';

class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({Key? key}) : super(key: key);

  void _showAddHomeworkSheet(BuildContext context, WidgetRef ref) {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final deadlineCtrl = TextEditingController(
      text: DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0],
    );

    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
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
                  'إضافة واجب جديد',
                  style: AppTextStyles.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                  tooltip: 'إغلاق',
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'المادة',
              hint: 'مثال: رياضيات',
              controller: subjectCtrl,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'تفاصيل الواجب',
              hint: 'مثال: حل صفحة 45 و 46',
              controller: descCtrl,
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'تاريخ التسليم',
              hint: 'YYYY-MM-DD',
              controller: deadlineCtrl,
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'حفظ الواجب',
              isFullWidth: true,
              onPressed: () {
                final subject = subjectCtrl.text.trim();
                final desc = descCtrl.text.trim();
                if (subject.isNotEmpty) {
                  final newHw = HomeworkModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    subject: subject,
                    description: desc,
                    deadline: deadlineCtrl.text.trim(),
                    status: 'pending',
                  );
                  ref.read(homeworkProvider.notifier).addHomework(newHw);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkList = ref.watch(homeworkProvider);
    final pending = homeworkList.where((h) => h.status == 'pending').toList();
    final completed = homeworkList
        .where((h) => h.status == 'completed')
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'مدير الواجبات',
            description: 'تتبع واجباتك المدرسية ومواعيد تسليمها',
            action: AppButton(
              text: 'إضافة واجب',
              icon: Icons.add,
              onPressed: () => _showAddHomeworkSheet(context, ref),
            ),
          ),
          const SizedBox(height: 8),

          if (homeworkList.isEmpty)
            AppEmptyState.initial(
              title: 'لا توجد واجبات دراسية بعد',
              description: 'سجّل واجباتك وتكاليفك الدراسية ومواعيد تسليمها لتنظيم استذكارك أولاً بأول.',
              icon: Icons.menu_book_rounded,
              actionLabel: 'إضافة واجب جديد',
              onAction: () => _showAddHomeworkSheet(context, ref),
            )
          else ...[
            // Section 1: Pending
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.categoryMeal,
                ),
                const SizedBox(width: 8),
                Text(
                  'قيد الانتظار (${pending.length})',
                  style: AppTextStyles.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          if (pending.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'لا توجد واجبات قيد الانتظار حالياً 🎉',
                style: AppTextStyles.cairo(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final hw = pending[i];
                return AppCard(
                  padding: const EdgeInsets.all(16),
                  border: Border(
                    right: const BorderSide(color: Color(0xFFF97316), width: 1),
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEDD5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hw.subject,
                              style: AppTextStyles.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC2410C),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'تسجيل الإنجاز',
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                                onPressed: () {
                                  AppHaptics.medium();
                                  ref
                                      .read(homeworkProvider.notifier)
                                      .toggleStatus(hw.id);
                                },
                              ),
                              IconButton(
                                tooltip: 'حذف العنصر',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                                onPressed: () {
                                  deleteWithUndo(
                                    context,
                                    onDelete: () => ref
                                        .read(homeworkProvider.notifier)
                                        .deleteHomework(hw.id),
                                    onUndo: () => ref
                                        .read(homeworkProvider.notifier)
                                        .addHomework(hw),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hw.description,
                        style: AppTextStyles.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'التسليم: ${hw.deadline}',
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 28),

          // Section 2: Completed
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'مكتمل (${completed.length})',
                style: AppTextStyles.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final hw = completed[i];
              return AppCard(
                padding: const EdgeInsets.all(14),
                border: Border(
                  right: const BorderSide(color: AppColors.success, width: 1),
                  top: BorderSide(color: Theme.of(context).dividerColor),
                  left: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hw.description,
                          style: AppTextStyles.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          hw.subject,
                          style: AppTextStyles.cairo(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'إعادة تشغيل المؤقت',
                      icon: const Icon(
                        Icons.rotate_left_rounded,
                        color: AppColors.success,
                      ),
                      onPressed: () {
                        AppHaptics.light();
                        ref.read(homeworkProvider.notifier).toggleStatus(hw.id);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
