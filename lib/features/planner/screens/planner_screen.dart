import 'package:flutter/material.dart';

import '../../../core/utils/app_validators.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/task_model.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../services/smart_task_service.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  String _activeFilter = 'all'; // 'all', 'high', 'study', 'completed'

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'study';
    String selectedPriority = 'medium';
    String startTime = '09:00';
    String endTime = '10:00';
    final startCtrl = TextEditingController(text: startTime);
    final endCtrl = TextEditingController(text: endTime);

    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إضافة مهمة ذكية جديدة',
                        style: AppTextStyles.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'عنوان المهمة',
                    hint: 'مثال: مراجعة الفصل الثالث فيزياء',
                    controller: titleController,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'التصنيف',
                          value: selectedCategory,
                          options: CategoryConstants.categoryLabelsAr.entries
                              .map((e) {
                                return DropdownOption(
                                  value: e.key,
                                  label: e.value,
                                );
                              })
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              setSheetState(() => selectedCategory = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdown<String>(
                          label: 'الأولوية الذكية',
                          value: selectedPriority,
                          options: const [
                            DropdownOption(
                              value: 'high',
                              label: 'عاجل وهام 🔴',
                            ),
                            DropdownOption(
                              value: 'medium',
                              label: 'مهم ومتوسط 🟡',
                            ),
                            DropdownOption(
                              value: 'low',
                              label: 'روتيني وخفيف 🟢',
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null)
                              setSheetState(() => selectedPriority = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'وقت البدء',
                          hint: '09:00',
                          controller: startCtrl,
                          onChanged: (val) => startTime = val,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'وقت الانتهاء',
                          hint: '10:00',
                          controller: endCtrl,
                          onChanged: (val) => endTime = val,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    SmartTaskService.getEnergyAdvice(selectedCategory),
                    style: AppTextStyles.cairo(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'حفظ المهمة (+50 XP عند الإنجاز)',
                    isFullWidth: true,
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (!AppValidators.validTimeRange(startTime, endTime)) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'وقت الانتهاء يجب أن يكون بعد وقت البدء.',
                            ),
                          ),
                        );
                        return;
                      }
                      if (title.isNotEmpty) {
                        final newTask = TaskModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: title,
                          category: selectedCategory,
                          priority: selectedPriority,
                          startTime: startTime,
                          endTime: endTime,
                          date: DateTime.now().toIso8601String().split('T')[0],
                        );
                        ref.read(tasksProvider.notifier).addTask(newTask);
                        ref.read(notificationServiceProvider).scheduleTaskReminder(newTask);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleRollover(List<TaskModel> rolloverTasks) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    for (final task in rolloverTasks) {
      final updatedTask = task.copyWith(date: today);
      ref.read(tasksProvider.notifier).addTask(updatedTask);
      ref.read(tasksProvider.notifier).deleteTask(task.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم ترحيل ${rolloverTasks.length} مهام إلى جدول اليوم بنجاح! ⚡',
          style: AppTextStyles.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    final rolloverTasks = SmartTaskService.getPendingRolloverTasks(
      tasks,
      todayStr,
    );

    // Apply Filter
    final filteredTasks = tasks.where((task) {
      if (_activeFilter == 'high') return task.priority == 'high';
      if (_activeFilter == 'study') return task.category == 'study';
      if (_activeFilter == 'completed') return task.completed;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'المخطط اليومي الذكي',
            description:
                'نظام إدارة وجدولة المهام مع مصفوفة الأولويات وترحيل المهام',
            action: AppButton(
              text: 'مهمة جديدة',
              icon: Icons.add,
              onPressed: () => _showAddTaskSheet(context),
            ),
          ),
          const SizedBox(height: 4),

          // 1. Smart Rollover Banner (if uncompleted past tasks exist)
          if (rolloverTasks.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF261D15)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ترحيل ذكي للمهام (${rolloverTasks.length} مهام)',
                          style: AppTextStyles.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                        Text(
                          'لديك مهام غير مكتملة من أيام سابقة، رحّلها لجدول اليوم بضغطة زر واحدة.',
                          style: AppTextStyles.cairo(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _handleRollover(rolloverTasks),
                    child: Text(
                      'ترحيل الآن',
                      style: AppTextStyles.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 2. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل (${tasks.length})',
                  isSelected: _activeFilter == 'all',
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _activeFilter = 'all');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'عاجل وهام 🔴',
                  isSelected: _activeFilter == 'high',
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _activeFilter = 'high');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'مذاكرة رئيسية 📚',
                  isSelected: _activeFilter == 'study',
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _activeFilter = 'study');
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'مكتمل ✅',
                  isSelected: _activeFilter == 'completed',
                  onTap: () {
                    AppHaptics.selection();
                    setState(() => _activeFilter = 'completed');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (filteredTasks.isEmpty)
            if (tasks.isEmpty)
              AppEmptyState.initial(
                title: 'يومك صفحة جديدة',
                description: 'لم تسجل أي مهام لهذا اليوم بعد. ابدأ بإضافة مهمة واحدة ورتّب أولوياتك.',
                icon: Icons.calendar_today_outlined,
                actionLabel: 'إضافة مهمة',
                onAction: () => _showAddTaskSheet(context),
              )
            else
              AppEmptyState.filtered(
                title: 'لا توجد مهام مطابقة للفلتر',
                description: 'لا توجد مهام مطابقة لتصنيف التصفية المحدد حالياً.',
                actionLabel: 'عرض جميع المهام',
                onClearFilter: () {
                  AppHaptics.selection();
                  setState(() => _activeFilter = 'all');
                },
              )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                final categoryColor = AppColors.getCategoryColor(task.category);
                final categoryLabel = CategoryConstants.getLabel(task.category);
                final energyAdvice = SmartTaskService.getEnergyAdvice(
                  task.category,
                );

                return AppCard(
                  padding: const EdgeInsets.all(14),
                  border: Border(
                    right: BorderSide(
                      color: task.completed
                          ? AppColors.success
                          : (task.priority == 'high'
                                ? AppColors.danger
                                : AppColors.primary),
                      width: 1,
                    ),
                    top: BorderSide(color: Theme.of(context).dividerColor),
                    left: BorderSide(color: Theme.of(context).dividerColor),
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'إكمال ${task.title}',
                        checked: task.completed,
                        child: Checkbox(
                          value: task.completed,
                          onChanged: (_) {
                            final wasCompleted = task.completed;
                            if (!wasCompleted) {
                              AppHaptics.medium();
                            } else {
                              AppHaptics.light();
                            }
                            ref
                                .read(tasksProvider.notifier)
                                .toggleTaskCompletion(task.id);
                            if (!wasCompleted) {
                              ref
                                  .read(rewardsProvider.notifier)
                                  .addXP(50, reason: 'إكمال مهمة دراسية');
                              ref
                                  .read(rewardsProvider.notifier)
                                  .unlockBadge('b1');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Task info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: AppTextStyles.cairo(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration: task.completed
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: task.completed
                                          ? (isDark
                                                ? AppColors.textMutedDark
                                                : AppColors.textMutedLight)
                                          : (isDark
                                                ? Colors.white
                                                : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ),
                                if (task.priority == 'high')
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'عاجل',
                                      style: AppTextStyles.cairo(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.startTime} - ${task.endTime}',
                                  style: AppTextStyles.cairo(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    categoryLabel,
                                    style: AppTextStyles.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              energyAdvice,
                              style: AppTextStyles.cairo(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete action
                      IconButton(
                        tooltip: 'حذف المهمة',
                        onPressed: () {
                          deleteWithUndo(
                            context,
                            onDelete: () => ref
                                .read(tasksProvider.notifier)
                                .deleteTask(task.id),
                            onUndo: () =>
                                ref.read(tasksProvider.notifier).addTask(task),
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                          size: 20,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
        ),
      ),
    );
  }
}
