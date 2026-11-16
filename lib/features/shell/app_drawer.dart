import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../common/providers/study_flow_state_provider.dart';

class AppDrawer extends ConsumerWidget {
  final String currentRoute;
  final bool persistent;

  const AppDrawer({
    Key? key,
    required this.currentRoute,
    this.persistent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navItems = [
      {'title': 'الرئيسية', 'route': '/dashboard', 'icon': Icons.home_rounded},
      {
        'title': 'المساعد الدراسي الذكي (AI)',
        'route': '/ai-assistant',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'title': 'المخطط اليومي الذكي',
        'route': '/planner',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'title': 'مؤقت التركيز والمنبه',
        'route': '/pomodoro',
        'icon': Icons.timer_rounded,
      },
      {
        'title': 'الواجبات الدراسية',
        'route': '/homework',
        'icon': Icons.menu_book_rounded,
      },
      {
        'title': 'المكتبة والكتب والـ PDFs',
        'route': '/materials',
        'icon': Icons.folder_special_rounded,
      },
      {
        'title': 'الجوائز والمكافآت (XP)',
        'route': '/rewards',
        'icon': Icons.emoji_events_rounded,
      },
      {
        'title': 'الأهداف الذكية',
        'route': '/goals',
        'icon': Icons.track_changes_rounded,
      },
      {
        'title': 'العادات اليومية',
        'route': '/habits',
        'icon': Icons.show_chart_rounded,
      },
      {
        'title': 'الملاحظات',
        'route': '/notes',
        'icon': Icons.description_outlined,
      },
      {
        'title': 'مركز الإشعارات',
        'route': '/notifications',
        'icon': Icons.notifications_none_rounded,
      },
      {
        'title': 'الإعدادات',
        'route': '/settings',
        'icon': Icons.settings_outlined,
      },
    ];

    return Drawer(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header with App Identity
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'public/assets/enote-icon.png',
                      width: 44,
                      height: 44,
                      cacheWidth: 88,
                      cacheHeight: 88,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENote',
                        style: AppTextStyles.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'رفيقك الدراسي',
                        style: AppTextStyles.cairo(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Navigation Items List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                itemCount: navItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final item = navItems[i];
                  final route = item['route'] as String;
                  final title = item['title'] as String;
                  final icon = item['icon'] as IconData;
                  final isSelected = currentRoute == route;

                  return Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        AppHaptics.selection();
                        if (!persistent) Navigator.pop(ctx);
                        if (!isSelected) {
                          context.go(route);
                        }
                      },
                      dense: false,
                      selected: isSelected,
                      leading: Icon(
                        icon,
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight),
                        size: 20,
                      ),
                      title: Text(
                        title,
                        style: AppTextStyles.cairo(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // User Mini Profile Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        profile?.name.isNotEmpty == true
                            ? profile!.name.characters.first
                            : 'ط',
                        style: AppTextStyles.cairo(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.name ?? 'طالب ENote',
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            profile?.grade ?? 'النسخة الذكية',
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
