import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../models/notification_item_model.dart';
import '../providers/notifications_provider.dart';

/// Modal bottom sheet helper to display Notifications Center as a modal dialog.
Future<void> showNotificationsModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: NotificationsScreen(
          scrollController: scrollController,
          isModal: true,
        ),
      ),
    ),
  );
}

/// Dedicated Notifications Center Screen & Dialog
class NotificationsScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool isModal;

  const NotificationsScreen({
    super.key,
    this.scrollController,
    this.isModal = false,
  });

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'all';

  Color _getIconBgColor(NotificationType type, NotificationPriority priority) {
    if (priority == NotificationPriority.urgent) {
      return AppColors.danger.withValues(alpha: 0.14);
    }
    switch (type) {
      case NotificationType.taskReminder:
        return AppColors.primary.withValues(alpha: 0.14);
      case NotificationType.pomodoro:
        return AppColors.success.withValues(alpha: 0.14);
      case NotificationType.goalDeadline:
        return AppColors.warning.withValues(alpha: 0.16);
      case NotificationType.dailyBriefing:
        return AppColors.info.withValues(alpha: 0.14);
      case NotificationType.general:
        return AppColors.secondary.withValues(alpha: 0.14);
    }
  }

  Color _getIconColor(NotificationType type, NotificationPriority priority) {
    if (priority == NotificationPriority.urgent) {
      return AppColors.danger;
    }
    switch (type) {
      case NotificationType.taskReminder:
        return AppColors.primary;
      case NotificationType.pomodoro:
        return AppColors.success;
      case NotificationType.goalDeadline:
        return AppColors.warning;
      case NotificationType.dailyBriefing:
        return AppColors.info;
      case NotificationType.general:
        return AppColors.secondary;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskReminder:
        return Icons.alarm_on_rounded;
      case NotificationType.pomodoro:
        return Icons.timer_rounded;
      case NotificationType.goalDeadline:
        return Icons.track_changes_rounded;
      case NotificationType.dailyBriefing:
        return Icons.wb_sunny_rounded;
      case NotificationType.general:
        return Icons.notifications_active_rounded;
    }
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          context.tr('مسح سجل الإشعارات'),
          style: AppTextStyles.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          context.tr('هل تريد مسح جميع الإشعارات السابقة من السجل؟'),
          style: AppTextStyles.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('إلغاء'), style: AppTextStyles.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(notificationsListProvider.notifier).clearAll();
              AppHaptics.light();
            },
            child: Text(
              context.tr('مسح الكل'),
              style: AppTextStyles.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationItem item) {
    AppHaptics.selection();
    ref.read(notificationsListProvider.notifier).markAsRead(item.id);

    final route = item.payload?['route'] as String?;
    if (route != null && route.isNotEmpty) {
      if (widget.isModal) {
        Navigator.pop(context);
      }
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationsListProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items
    final filtered = notifications.where((item) {
      if (_selectedFilter == 'unread') return !item.isRead;
      if (_selectedFilter == 'tasks') {
        return item.type == NotificationType.taskReminder;
      }
      if (_selectedFilter == 'pomodoro') {
        return item.type == NotificationType.pomodoro;
      }
      if (_selectedFilter == 'goals') {
        return item.type == NotificationType.goalDeadline;
      }
      if (_selectedFilter == 'briefing') {
        return item.type == NotificationType.dailyBriefing;
      }
      return true; // 'all'
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Modal Drag Handle
        if (widget.isModal) ...[
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],

        // Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.tr('مركز الإشعارات'),
                          style: AppTextStyles.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              context.l10n.messagea8ccbc2d66(
                                context.display(unreadCount),
                              ),
                              style: AppTextStyles.cairo(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr(
                        'سجل التنبيهات، تذكيرات المهام والمواعيد الهامة',
                      ),
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
              if (widget.isModal)
                IconButton(
                  tooltip: context.tr('إغلاق'),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        ),

        // Quick Actions Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              if (unreadCount > 0) ...[
                TextButton.icon(
                  onPressed: () {
                    AppHaptics.light();
                    ref
                        .read(notificationsListProvider.notifier)
                        .markAllAsRead();
                  },
                  icon: const Icon(Icons.done_all_rounded, size: 18),
                  label: Text(
                    context.tr('قراءة الكل'),
                    style: AppTextStyles.cairo(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
              const Spacer(),
              if (notifications.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: () => _confirmClearAll(context),
                  icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                  label: Text(
                    context.tr('مسح السجل'),
                    style: AppTextStyles.cairo(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              _FilterChip(
                label: 'الكل (${notifications.length})',
                isSelected: _selectedFilter == 'all',
                onTap: () => setState(() => _selectedFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'غير مقروءة ($unreadCount)',
                isSelected: _selectedFilter == 'unread',
                onTap: () => setState(() => _selectedFilter = 'unread'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'المهام',
                isSelected: _selectedFilter == 'tasks',
                onTap: () => setState(() => _selectedFilter = 'tasks'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'مؤقت التركيز',
                isSelected: _selectedFilter == 'pomodoro',
                onTap: () => setState(() => _selectedFilter = 'pomodoro'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'الأهداف',
                isSelected: _selectedFilter == 'goals',
                onTap: () => setState(() => _selectedFilter = 'goals'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'الملخص الصباحي',
                isSelected: _selectedFilter == 'briefing',
                onTap: () => setState(() => _selectedFilter = 'briefing'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Notification List or Empty State
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AppEmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'لا توجد تنبيهات حالياً',
                        description: _selectedFilter == 'unread'
                            ? 'أحسنت! لقد قرأت واطلعت على جميع الإشعارات.'
                            : 'ستظهر هنا التذكيرات اليومية بالمذاكرة ومؤقت التركيز وتحديثات الأهداف.',
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final iconBg = _getIconBgColor(item.type, item.priority);
                    final iconColor = _getIconColor(item.type, item.priority);
                    final iconData = _getIcon(item.type);

                    return Dismissible(
                      key: Key('notif_${item.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) {
                        ref
                            .read(notificationsListProvider.notifier)
                            .deleteNotification(item.id);
                        AppHaptics.light();
                      },
                      child: AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () => _onNotificationTap(item),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(iconData, color: iconColor, size: 22),
                            ),
                            const SizedBox(width: 12),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: AppTextStyles.cairo(
                                            fontSize: 14,
                                            fontWeight: item.isRead
                                                ? FontWeight.w600
                                                : FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ),
                                      if (!item.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                            left: 6,
                                          ),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: AppTextStyles.cairo(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        _formatRelativeTime(item.createdAt),
                                        style: AppTextStyles.cairo(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.textMutedDark
                                                    .withValues(alpha: 0.8)
                                              : AppColors.textMutedLight
                                                    .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (item.payload?['route'] != null)
                                        Text(
                                          context.tr('عرض التفاصيل ←'),
                                          style: AppTextStyles.cairo(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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

    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
        ),
      ),
    );
  }
}
