import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/category_constants.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/page_header.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../../materials/providers/materials_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final allTasks = ref.watch(tasksProvider);
    final today = DateTime.now().toIso8601String().split('T').first;
    final tasks = allTasks.where((task) => task.date == today).toList();
    final completed = tasks.where((task) => task.completed).length;
    final goals = ref.watch(goalsProvider);
    final pending = ref
        .watch(homeworkProvider)
        .where((item) => item.status == 'pending')
        .toList();
    final stats = ref.watch(statsProvider);
    final rewards = ref.watch(rewardsProvider);
    final materials = ref.watch(materialsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final firstName =
        profile?.name.trim().split(' ').first ?? context.tr('يا صديقي');

    // 7-Day Performance Statistics & Today's Category Distribution
    final days = List.generate(
      7,
      (index) => DateTime.now().subtract(Duration(days: 6 - index)),
    );
    final counts = days
        .map(
          (day) => allTasks
              .where(
                (task) =>
                    task.completed &&
                    task.date == day.toIso8601String().split('T').first,
              )
              .length,
        )
        .toList();
    final maximum = counts.fold<int>(
      1,
      (previous, value) => value > previous ? value : previous,
    );
    final distribution = <String, int>{};
    for (final task in allTasks.where((task) => task.date == today)) {
      if (!AppValidators.validTimeRange(task.startTime, task.endTime)) continue;
      int minute(String value) =>
          int.parse(value.substring(0, 2)) * 60 + int.parse(value.substring(3));
      distribution.update(
        task.category,
        (value) => value + minute(task.endTime) - minute(task.startTime),
        ifAbsent: () => minute(task.endTime) - minute(task.startTime),
      );
    }
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    Widget heading(String title, String route) => Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
        ),
        TextButton(
          onPressed: () => context.go(route),
          child: Text(context.tr('عرض الكل')),
        ),
      ],
    );
    final taskPanel = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('على خطتك اليوم', '/planner'),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('يومك صفحة جديدة. ابدأ بمهمة واحدة.')),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'إضافة مهمة',
                    icon: Icons.add,
                    onPressed: () => context.go('/planner'),
                  ),
                ],
              ),
            )
          else
            ...tasks
                .take(4)
                .map(
                  (task) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      task.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: task.completed
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      '${task.startTime} – ${task.endTime}',
                      textDirection: TextDirection.ltr,
                    ),
                    onTap: () => context.go('/planner'),
                  ),
                ),
        ],
      ),
    );
    final goalPanel = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('خطوة نحو أهدافك', '/goals'),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(context.tr('أضف هدفك الأول وابدأ متابعة تقدّمك.')),
            ),
          ...goals
              .take(3)
              .map(
                (goal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      AppProgressBar(
                        progress: goal.target > 0
                            ? (goal.current / goal.target)
                                  .clamp(0.0, 1.0)
                                  .toDouble()
                            : 0,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.messagec991cdd692(
                          context.display(goal.current),
                          context.display(goal.target),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );

    final rewardsPanel = AppCard(
      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
      border: Border.all(
        color: const Color(0xFF6366F1).withValues(alpha: 0.35),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.message30abd8f96f(
                        context.display(rewards.currentXP),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.message34a64aeb49(
                        context.display(rewards.level),
                        context.display(rewards.levelTitle),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: TextButton.icon(
                  onPressed: () => context.go('/rewards'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    context.tr('سجل الجوائز'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppProgressBar(
            progress: rewards.levelProgress,
            color: const Color(0xFFF59E0B),
            height: 8,
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                context.l10n.message0b8b5f7fdc(
                  context.display(rewards.streakDays),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                context.l10n.messagee8c8186e98(
                  context.display(
                    rewards.badges.where((b) => b.isUnlocked).length,
                  ),
                  context.display(rewards.badges.length),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final statsPanel = AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    context.tr('إحصائيات الأداء الأسبوعي'),
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${counts.fold<int>(0, (a, b) => a + b)} مهام مكتملة',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'توزيع المهام المنجزة فعلياً خلال الأيام السبعة الأخيرة.',
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            7,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          weekdays[days[index].weekday - 1],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        context.l10n.tasks(counts[index]),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: counts[index] / maximum,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    semanticsLabel:
                        '${weekdays[days[index].weekday - 1]}: مهام مكتملة',
                    semanticsValue: '${counts[index]}',
                  ),
                ],
              ),
            ),
          ),
          if (distribution.isNotEmpty) ...[
            const Divider(height: 28),
            Text(
              context.tr('توزيع وقت المذاكرة المخطط اليوم'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...distribution.entries.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(CategoryConstants.getLabel(item.key))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        context.l10n.minutes(item.value),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: '${context.tr('مرحبًا،')} $firstName',
            description: 'كل خطوة صغيرة تقرّبك من أهدافك. هذه خطتك لليوم.',
          ),
          AppCard(
            color: theme.colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('وقتك يستاهل خطة حلوة.'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'رتّب أولوياتك وابدأ بمهمة واحدة. خذ استراحة قصيرة بين جلسات التركيز.',
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'ابدأ جلسة تركيز',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.go('/pomodoro'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            color: isDark ? AppColors.cardDark : Colors.white,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Stack the action under the copy on narrow cards or with
                // enlarged text, so the row never overflows.
                final compact = constraints.maxWidth < 560;
                final assistantButton = AppButton(
                  text: 'تحدث مع المساعد',
                  icon: Icons.chat_bubble_outline_rounded,
                  isFullWidth: compact,
                  onPressed: () => context.go('/ai-assistant'),
                );
                final summary = Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('المساعد الدراسي الذكي (AI)'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr(
                              'خطط مذاكرة تفاعلية، كويزات فورية، وتلخيص ذكي لملاحظاتك الدراسية.',
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 12),
                      assistantButton,
                    ],
                  ],
                );
                if (!compact) return summary;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    const SizedBox(height: 16),
                    assistantButton,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          rewardsPanel,
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _Metric(
                  label: 'مهام اليوم المنجزة',
                  value: '$completed / ${tasks.length}',
                  icon: Icons.task_alt,
                  width: constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 32) / 3,
                ),
                _Metric(
                  label: 'دقائق التركيز المسجلة',
                  value: '${stats.studyTimeMinutes}',
                  icon: Icons.timer_outlined,
                  width: constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 32) / 3,
                ),
                _Metric(
                  label: 'أهداف قيد التحقيق',
                  value:
                      '${goals.where((goal) => goal.current < goal.target).length}',
                  icon: Icons.flag_outlined,
                  width: constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 32) / 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: taskPanel),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: goalPanel),
                    ],
                  )
                : Column(
                    children: [
                      taskPanel,
                      const SizedBox(height: 20),
                      goalPanel,
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          statsPanel,
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('الواجبات القادمة', '/homework'),
                if (pending.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(context.tr('لا توجد واجبات معلقة. أحسنت!')),
                  ),
                ...pending
                    .take(3)
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.menu_book_outlined),
                        title: Text(item.subject),
                        subtitle: Text(item.description),
                        onTap: () => context.go('/homework'),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton(
                text: 'المساعد الذكي (AI)',
                icon: Icons.auto_awesome_rounded,
                variant: AppButtonVariant.primary,
                onPressed: () => context.go('/ai-assistant'),
              ),
              AppButton(
                text: 'المكتبة · ${materials.totalBooksCount} ملفات',
                icon: Icons.folder_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/materials'),
              ),
              AppButton(
                text: 'المكافآت · ${rewards.currentXP} XP',
                icon: Icons.emoji_events_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go('/rewards'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final double width;
  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
    required this.width,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: AppCard(
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textDirection: TextDirection.ltr,
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
