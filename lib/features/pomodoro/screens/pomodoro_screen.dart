import '../../notifications/models/notification_item_model.dart';
import '../../common/providers/persistent_notifier.dart';

import 'package:study_flow/core/utils/app_validators.dart';
import 'package:study_flow/l10n/ui_labels.dart';

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/pomodoro_settings.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../services/pomodoro_alarm_service.dart';
import '../widgets/flip_clock_widget.dart';
import '../../notifications/providers/notifications_provider.dart';

enum PomodoroMode { study, shortBreak, longBreak }

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  PomodoroMode _currentMode = PomodoroMode.study;
  Timer? _timer;
  DateTime? _deadline;
  late int _timeLeft;
  bool _isActive = false;
  bool _useFlipClock = true;

  PomodoroAlarmSettings _alarmSettings = const PomodoroAlarmSettings(
    soundEnabled: true,
    vibrationEnabled: true,
    soundType: 'chime',
  );

  @override
  void initState() {
    super.initState();
    final settings = ref.read(pomodoroSettingsProvider);
    _timeLeft = settings.study * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _getTotalTimeForMode(PomodoroMode mode, PomodoroSettings settings) {
    switch (mode) {
      case PomodoroMode.study:
        return settings.study * 60;
      case PomodoroMode.shortBreak:
        return settings.breakDuration * 60;
      case PomodoroMode.longBreak:
        return settings.longBreak * 60;
    }
  }

  Color _getColorForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.study:
        return AppColors.primary;
      case PomodoroMode.shortBreak:
        return AppColors.success;
      case PomodoroMode.longBreak:
        return AppColors.info;
    }
  }

  String _getLabelForMode(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.study:
        return 'وقت التركيز';
      case PomodoroMode.shortBreak:
        return 'استراحة قصيرة';
      case PomodoroMode.longBreak:
        return 'استراحة طويلة';
    }
  }

  void _switchMode(PomodoroMode newMode) {
    unawaited(
      ref
          .read(notificationServiceProvider)
          .cancelScheduledNotification('pomodoro-active')
          .catchError(reportStorageFailure),
    );
    AppHaptics.selection();
    final settings = ref.read(pomodoroSettingsProvider);
    _timer?.cancel();
    setState(() {
      _currentMode = newMode;
      _isActive = false;
      _timeLeft = _getTotalTimeForMode(newMode, settings);
    });
  }

  Future<void> _startTimer() async {
    AppHaptics.medium();
    _timer?.cancel();
    _deadline = DateTime.now().add(Duration(seconds: _timeLeft));
    await ref
        .read(notificationServiceProvider)
        .scheduleNotification(
          id: 'pomodoro-active',
          title: 'ENote',
          body: Localizations.localeOf(context).languageCode == 'ar'
              ? 'انتهت جلسة المؤقت'
              : 'Timer session complete',
          scheduledTime: _deadline!,
          type: NotificationType.pomodoro,
          channelId: NotificationChannel.pomodoro,
        );
    if (!mounted) return;
    setState(() => _isActive = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining =
          (_deadline!.difference(DateTime.now()).inMilliseconds / 1000).ceil();
      if (remaining > 0) {
        setState(() => _timeLeft = remaining);
      } else {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _isActive = false;
        });
        _handleTimerComplete();
      }
    });
  }

  void _toggleTimer() {
    if (_isActive) {
      unawaited(
        ref
            .read(notificationServiceProvider)
            .cancelScheduledNotification('pomodoro-active')
            .catchError(reportStorageFailure),
      );
      AppHaptics.light();
      _timer?.cancel();
      setState(() => _isActive = false);
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    unawaited(
      ref
          .read(notificationServiceProvider)
          .cancelScheduledNotification('pomodoro-active')
          .catchError(reportStorageFailure),
    );
    AppHaptics.light();
    final settings = ref.read(pomodoroSettingsProvider);
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _timeLeft = _getTotalTimeForMode(_currentMode, settings);
    });
  }

  void _extendFiveMinutes() {
    _timeLeft += 5 * 60;
    _startTimer();
  }

  void _handleTimerComplete() async {
    await ref
        .read(notificationServiceProvider)
        .cancelScheduledNotification('pomodoro-active');
    if (!mounted) return;
    final settings = ref.read(pomodoroSettingsProvider);

    // 1. Trigger Sound & Haptic Alarm
    AppHaptics.milestone();
    await PomodoroAlarmService.triggerAlarm(_alarmSettings);
    if (!mounted) return;

    // 2. Trigger System & Notifications Center Alert
    await ref
        .read(notificationServiceProvider)
        .triggerPomodoroFinishNotification(
          isWorkSession: _currentMode == PomodoroMode.study,
        );

    if (!mounted) return;

    if (_currentMode == PomodoroMode.study) {
      await ref.read(statsProvider.notifier).addStudyMinutes(settings.study);
      if (!mounted) return;
      // Reward student with XP + unlock badge!
      ref
          .read(rewardsProvider.notifier)
          .addXP(100, reason: 'جلسة بومودورو مكتملة');
      ref.read(rewardsProvider.notifier).unlockBadge('b2');

      _showCompletionDialog(
        title: '🎉 رائع جداً! (+100 XP)',
        message: 'انتهت جلسة التركيز بنجاح! رن المنبه لتنبيهك. خذ استراحة مستحقة لتجديد طاقتك.',
        onConfirm: () => _switchMode(PomodoroMode.shortBreak),
        canExtend: true,
      );
    } else {
      _showCompletionDialog(
        title: '⏰ انتهت الاستراحة!',
        message:
            'رن المنبه لانتهاء وقت الاستراحة. عد لجلسة تركيز جديدة بكل حماس!',
        onConfirm: () => _switchMode(PomodoroMode.study),
        canExtend: false,
      );
    }
  }

  void _showCompletionDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool canExtend = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr(title),
                style: AppTextStyles.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          context.tr(message),
          style: AppTextStyles.cairo(fontSize: 14, height: 1.5),
        ),
        actions: [
          if (canExtend)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _extendFiveMinutes();
              },
              child: Text(
                context.tr('تمديد 5 دقائق'),
                style: AppTextStyles.cairo(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(
              context.tr('حسناً'),
              style: AppTextStyles.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet() {
    final settings = ref.read(pomodoroSettingsProvider);
    final studyCtrl = TextEditingController(text: settings.study.toString());
    final breakCtrl = TextEditingController(
      text: settings.breakDuration.toString(),
    );
    final longBreakCtrl = TextEditingController(
      text: settings.longBreak.toString(),
    );

    bool sound = _alarmSettings.soundEnabled;
    bool vibration = _alarmSettings.vibrationEnabled;

    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
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
                      context.tr('إعدادات المؤقت والمنبه'),
                      style: AppTextStyles.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: context.tr('إغلاق'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'وقت التركيز (دقائق)',
                  validation: FieldValidation.focusMinutes,
                  controller: studyCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'استراحة قصيرة (دقائق)',
                  validation: FieldValidation.shortBreakMinutes,
                  controller: breakCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'استراحة طويلة (دقائق)',
                  validation: FieldValidation.longBreakMinutes,
                  controller: longBreakCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Alarm toggles
                Text(
                  context.tr('خيارات التنبيه (Alarm)'),
                  style: AppTextStyles.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr('تشغيل صوت المنبه'),
                    style: AppTextStyles.cairo(fontSize: 14),
                  ),
                  subtitle: Text(
                    context.tr('رنين صوتي فوري عند انتهاء الجلسة'),
                    style: AppTextStyles.cairo(fontSize: 11),
                  ),
                  value: sound,
                  onChanged: (val) => setSheetState(() => sound = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    context.tr('اهتزاز الجهاز (Vibration)'),
                    style: AppTextStyles.cairo(fontSize: 14),
                  ),
                  subtitle: Text(
                    context.tr('تنبيه بالاهتزاز لتأكيد انتهاء الوقت'),
                    style: AppTextStyles.cairo(fontSize: 11),
                  ),
                  value: vibration,
                  onChanged: (val) => setSheetState(() => vibration = val),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'حفظ الإعدادات',
                  isFullWidth: true,
                  onPressed: () async {
                    final newSettings = PomodoroSettings(
                      study: AppValidators.parseInt(studyCtrl.text) ?? 25,
                      breakDuration:
                          AppValidators.parseInt(breakCtrl.text) ?? 5,
                      longBreak:
                          AppValidators.parseInt(longBreakCtrl.text) ?? 15,
                    );
                    await ref
                        .read(pomodoroSettingsProvider.notifier)
                        .updateSettings(newSettings);
                    if (!mounted || !ctx.mounted) return;
                    setState(() {
                      _alarmSettings = _alarmSettings.copyWith(
                        soundEnabled: sound,
                        vibrationEnabled: vibration,
                      );
                    });
                    Navigator.pop(ctx);
                    _resetTimer();
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
  Widget build(BuildContext context) {
    final settings = ref.watch(pomodoroSettingsProvider);
    final totalTime = _getTotalTimeForMode(_currentMode, settings);
    final progress = totalTime > 0
        ? ((totalTime - _timeLeft) / totalTime).clamp(0.0, 1.0)
        : 0.0;
    final modeColor = _getColorForMode(_currentMode);
    final modeLabel = _getLabelForMode(_currentMode);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const PageHeader(
            title: 'مؤقت بومودورو',
            description:
                'حافظ على تركيزك وزد من إنتاجيتك الدراسية مع منبه صوتي',
          ),
          const SizedBox(height: 12),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                // Top Settings & Alarm Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: context.tr('إعدادات المؤقت والمنبه'),
                      onPressed: _showSettingsSheet,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _alarmSettings.soundEnabled
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _alarmSettings.soundEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            size: 14,
                            color: _alarmSettings.soundEnabled
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _alarmSettings.soundEnabled
                                ? 'المنبه مفعّل'
                                : 'المنبه صامت',
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _alarmSettings.soundEnabled
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Mode Selector Buttons
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _ModeTab(
                        label: 'تركيز',
                        isSelected: _currentMode == PomodoroMode.study,
                        onTap: () => _switchMode(PomodoroMode.study),
                      ),
                      _ModeTab(
                        label: 'استراحة قصيرة',
                        isSelected: _currentMode == PomodoroMode.shortBreak,
                        onTap: () => _switchMode(PomodoroMode.shortBreak),
                      ),
                      _ModeTab(
                        label: 'استراحة طويلة',
                        isSelected: _currentMode == PomodoroMode.longBreak,
                        onTap: () => _switchMode(PomodoroMode.longBreak),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // View Selector (3D Flip Clock vs Circular Ring)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _useFlipClock = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _useFlipClock
                                ? (isDark ? AppColors.cardDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _useFlipClock
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            context.tr('ساعة قلابة 3D'),
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              fontWeight: _useFlipClock
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _useFlipClock
                                  ? (isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight)
                                  : (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _useFlipClock = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: !_useFlipClock
                                ? (isDark ? AppColors.cardDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: !_useFlipClock
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            context.tr('مؤشر دائري'),
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              fontWeight: !_useFlipClock
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: !_useFlipClock
                                  ? (isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight)
                                  : (isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timer Display: 3D Flip Clock (Default) or Circular Ring
                if (_useFlipClock)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: FlipClockWidget(
                      timeLeft: _timeLeft,
                      totalTime: totalTime,
                      accentColor: modeColor,
                      modeLabel: modeLabel,
                      isActive: _isActive,
                    ),
                  )
                else
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 230,
                          height: 230,
                          child: CircularProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            strokeWidth: 10,
                            backgroundColor: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              modeColor,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormatters.formatPomodoroTime(_timeLeft),
                              style: AppTextStyles.cairo(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              modeLabel,
                              style: AppTextStyles.cairo(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: modeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 36),

                // Controls
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reset Button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                            width: 1.5,
                          ),
                        ),
                        child: IconButton(
                          tooltip: context.tr('إعادة تشغيل المؤقت'),
                          icon: const Icon(Icons.rotate_left_rounded, size: 24),
                          onPressed: _resetTimer,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Play/Pause Button
                      AppButton(
                        text: _isActive ? 'إيقاف مؤقت' : 'ابدأ التركيز',
                        icon: _isActive
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        variant: _isActive
                            ? AppButtonVariant.danger
                            : AppButtonVariant.primary,
                        height: 52,
                        onPressed: _toggleTimer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.cardDark : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          context.tr(label),
          style: AppTextStyles.cairo(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
        ),
      ),
    );
  }
}
