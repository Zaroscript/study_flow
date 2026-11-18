import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/habit_model.dart';
import '../../common/providers/study_flow_state_provider.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  List<DateTime> _getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedColor = 'indigo';

    final colorOptions = [
      const DropdownOption(value: 'indigo', label: 'بنفسجي'),
      const DropdownOption(value: 'blue', label: 'أزرق'),
      const DropdownOption(value: 'green', label: 'أخضر'),
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
                  context.tr('إضافة عادة جديدة'),
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
              label: 'اسم العادة',
              validation: FieldValidation.required,
              hint: 'مثال: القراءة لمدة 20 دقيقة',
              controller: nameCtrl,
            ),
            const SizedBox(height: 12),
            AppDropdown<String>(
              label: 'لون العادة',
              value: selectedColor,
              options: colorOptions,
              onChanged: (val) {
                if (val != null) selectedColor = val;
              },
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'حفظ العادة',
              isFullWidth: true,
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  final newHabit = HabitModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    color: selectedColor,
                    history: {},
                  );
                  ref.read(habitsProvider.notifier).addHabit(newHabit);
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
    final habits = ref.watch(habitsProvider);
    final days = _getLast7Days();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'متتبع العادات',
            description: 'ابنِ عادات إيجابية يومية وطوّر نفسك',
            action: AppButton(
              text: 'إضافة عادة',
              icon: Icons.add,
              onPressed: () => _showAddHabitSheet(context, ref),
            ),
          ),
          const SizedBox(height: 8),

          if (habits.isEmpty)
            AppEmptyState.initial(
              title: 'لا توجد عادات مسجلة حالياً',
              description: 'ابنِ عادات دراسية إيجابية والتزم بها يومياً لتصل إلى قمة أهدافك.',
              icon: Icons.star_outline_rounded,
              actionLabel: 'إضافة عادة',
              onAction: () => _showAddHabitSheet(context, ref),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, index) {
                final habit = habits[index];

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              habit.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: context.tr('حذف العادة'),
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            onPressed: () => deleteWithUndo(
                              context,
                              onDelete: () => ref
                                  .read(habitsProvider.notifier)
                                  .deleteHabit(habit.id),
                              onUndo: () => ref
                                  .read(habitsProvider.notifier)
                                  .addHabit(habit),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // The whole labelled control is a 48dp touch target.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: days.map((day) {
                            final dateKey = day
                                .toIso8601String()
                                .split('T')
                                .first;
                            final completed = habit.isCompletedOn(dateKey);
                            final weekday = [
                              'الإثنين',
                              'الثلاثاء',
                              'الأربعاء',
                              'الخميس',
                              'الجمعة',
                              'السبت',
                              'الأحد',
                            ][day.weekday - 1];
                            return Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: Semantics(
                                label: '${habit.name}، $weekday ${day.day}',
                                toggled: completed,
                                child: Column(
                                  children: [
                                    Text(
                                      weekday,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton.filledTonal(
                                      tooltip:
                                          '$weekday ${day.day}: ${completed ? 'مكتمل' : 'تسجيل الإنجاز'}',
                                      isSelected: completed,
                                      selectedIcon: const Icon(Icons.check),
                                      icon: Text('${day.day}'),
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                        minHeight: 48,
                                      ),
                                      onPressed: () async {
                                        final willComplete = !completed;
                                        if (willComplete) {
                                          AppHaptics.medium();
                                        } else {
                                          AppHaptics.light();
                                        }
                                        await ref
                                            .read(habitsProvider.notifier)
                                            .toggleHabit(habit.id, dateKey);
                                        if (!context.mounted) return;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
