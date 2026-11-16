import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/page_header.dart';
import '../../common/providers/theme_provider.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../../notifications/models/notification_item_model.dart';
import '../../notifications/providers/notifications_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تأكيد مسح البيانات',
          style: AppTextStyles.cairo(
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء وسيتم إعادة ضبط التطبيق من البداية.',
          style: AppTextStyles.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.cairo()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final repository = ref.read(studyFlowRepositoryProvider);
              final preferences = ref.read(preferencesServiceProvider);
              final profile = ref.read(profileProvider.notifier);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              await repository.clearAllData();
              await preferences.clearPreferences();
              ref.invalidate(tasksProvider);
              ref.invalidate(homeworkProvider);
              ref.invalidate(goalsProvider);
              ref.invalidate(habitsProvider);
              ref.invalidate(notesProvider);
              ref.invalidate(statsProvider);
              ref.invalidate(pomodoroSettingsProvider);
              await profile.clearProfile();
              if (context.mounted) {
                context.go('/onboarding');
              }
            },
            child: Text(
              'مسح نهائي',
              style: AppTextStyles.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final profile = ref.watch(profileProvider);
    final notifPrefs = ref.watch(notificationPreferencesProvider);
    final notifNotifier = ref.read(notificationPreferencesProvider.notifier);
    final notifService = ref.read(notificationServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'الإعدادات',
            description: 'تخصيص تجربة التطبيق، إدارة ملف الطالب والمظهر',
          ),
          const SizedBox(height: 8),

          // 1. Profile Management Card
          AppCard(
            padding: const EdgeInsets.all(18),
            onTap: () => context.push('/settings/profile'),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    profile?.name.isNotEmpty == true
                        ? profile!.name.characters.first
                        : 'ط',
                    style: AppTextStyles.cairo(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.name ?? 'طالب ENote',
                        style: AppTextStyles.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.grade ?? 'انقر لتعديل بيانات الطالب',
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
                Icon(
                  Icons.arrow_forward_ios_rounded, // In RTL points to the left/action
                  size: 16,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Theme Selection Card (Light, Dark, System)
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.palette_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'مظهر التطبيق',
                      style: AppTextStyles.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر المظهر المفضل أو اتركه متوافقاً مع إعدادات نظام جهازك',
                  style: AppTextStyles.cairo(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 16),

                // Theme Mode Radios
                _ThemeOptionTile(
                  title: 'الوضع الفاتح (Light)',
                  icon: Icons.light_mode_outlined,
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light),
                ),
                const SizedBox(height: 8),
                _ThemeOptionTile(
                  title: 'الوضع الداكن (Dark)',
                  icon: Icons.dark_mode_outlined,
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.dark),
                ),
                const SizedBox(height: 8),
                _ThemeOptionTile(
                  title: 'تلقائي حسب النظام (System)',
                  icon: Icons.brightness_auto_outlined,
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Notifications & Reminders Card
          AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الإشعارات والتنبيهات',
                      style: AppTextStyles.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: notifPrefs.notificationsEnabled,
                      activeColor: AppColors.primary,
                      onChanged: (val) => notifNotifier.toggleMaster(val),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'تحكم في تذكيرات المهام اليومية، جلسات مؤقت التركيز والملخص الصباحي',
                  style: AppTextStyles.cairo(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
                if (!notifService.permissionStatus.isGranted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'لم يتم تفعيل إذن الإشعارات بعد على هذا الجهاز.',
                            style: AppTextStyles.cairo(fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final status = await notifService.requestPermission();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    status.isGranted
                                        ? 'تم تفعيل إذن الإشعارات بنجاح!'
                                        : 'تعذر الحصول على إذن الإشعارات من المتصفح أو النظام.',
                                    style: AppTextStyles.cairo(),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'طلب الإذن',
                            style: AppTextStyles.cairo(
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (notifPrefs.notificationsEnabled) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _NotificationToggleTile(
                    title: 'تذكير المهام الدراسية (قبل 15 دقيقة)',
                    description: 'تنبيه مبكر قبل موعد كل مهمة في المخطط الدراسي',
                    icon: Icons.alarm_rounded,
                    value: notifPrefs.taskRemindersEnabled,
                    onChanged: (val) => notifNotifier.toggleTaskReminders(val),
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'تنبيهات مؤقت التركيز والاستراحات',
                    description: 'إشعار فوري عند اكتمال جلسة المذاكرة أو وقت الراحة',
                    icon: Icons.timer_rounded,
                    value: notifPrefs.pomodoroAlertsEnabled,
                    onChanged: (val) => notifNotifier.togglePomodoroAlerts(val),
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'تحذيرات مواعيد الأهداف الذكية',
                    description: 'تنبيه عند اقتراب المهلة النهائية أو الاحتفال بإنجاز الهدف',
                    icon: Icons.track_changes_rounded,
                    value: notifPrefs.goalAlertsEnabled,
                    onChanged: (val) => notifNotifier.toggleGoalAlerts(val),
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'الملخص الصباحي اليومي',
                    description: 'رسالة إيجابية صباحية بمهام وأهداف اليوم لبدء الدراسة بنشاط',
                    icon: Icons.wb_sunny_rounded,
                    value: notifPrefs.dailyBriefingEnabled,
                    onChanged: (val) => notifNotifier.toggleDailyBriefing(val),
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'الأصوات والتأثيرات الصوتية',
                    description: 'تشغيل نغمة تنبيه صوتية مصاحبة للإشعار',
                    icon: Icons.volume_up_rounded,
                    value: notifPrefs.soundEnabled,
                    onChanged: (val) => notifNotifier.toggleSound(val),
                  ),
                  const SizedBox(height: 12),
                  _NotificationToggleTile(
                    title: 'الاهتزاز الحسي (Haptics)',
                    description: 'تفعيل الاهتزاز عند استلام التنبيه',
                    icon: Icons.vibration_rounded,
                    value: notifPrefs.vibrationEnabled,
                    onChanged: (val) => notifNotifier.toggleVibration(val),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      final item = await notifService.showNotification(
                        title: '🔔 إشعار تجريبي من StudyFlow',
                        body: 'نظام الإشعارات يعمل بكفاءة وتوافق تام! استمتع بيوم دراسي منظم.',
                        type: NotificationType.general,
                      );
                      if (context.mounted && item != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'تم إرسال إشعار تجريبي وتسجيله في مركز الإشعارات!',
                              style: AppTextStyles.cairo(),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      'إرسال إشعار تجريبي الآن',
                      style: AppTextStyles.cairo(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Danger Zone
          AppCard(
            padding: const EdgeInsets.all(18),
            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.danger,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'منطقة الخطر',
                      style: AppTextStyles.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'سيتم حذف جميع السجلات والملف الشخصي نهائياً من قاعدة البيانات المحلية وإعادة فتح شاشة التهيئة.',
                  style: AppTextStyles.cairo(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'مسح جميع البيانات',
                  icon: Icons.delete_forever_rounded,
                  variant: AppButtonVariant.danger,
                  onPressed: () => _confirmClearData(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.cairo(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? Colors.white : AppColors.textPrimaryLight),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleTile({
    required this.title,
    required this.description,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: value
                ? AppColors.primary.withOpacity(0.12)
                : (isDark ? Colors.white10 : Colors.black12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: value
                ? AppColors.primary
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                description,
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
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
