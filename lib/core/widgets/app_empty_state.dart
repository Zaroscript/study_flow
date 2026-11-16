import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';
import 'app_button.dart';

enum EmptyStateType { initial, filtered, error }

/// Unified Empty & Error State widget adhering to `ui-states-and-feedback` skill.
///
/// Distinguishes between:
/// 1. Initial Empty (لم تقم بإضافة عناصر بعد): Offers primary creation action.
/// 2. Filtered Empty (لا توجد عناصر مطابقة للفلتر): Offers clear filter action.
/// 3. Error (تعذر التحميل): Offers safe retry action.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final EmptyStateType type;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    String? description,
    String? message,
    required this.icon,
    this.type = EmptyStateType.initial,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  }) : description = description ?? message ?? '';

  /// Factory for when a user has no content yet
  factory AppEmptyState.initial({
    required String title,
    required String description,
    IconData icon = Icons.inbox_outlined,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      title: title,
      description: description,
      icon: icon,
      type: EmptyStateType.initial,
      actionLabel: actionLabel,
      actionIcon: actionIcon ?? Icons.add,
      onAction: onAction,
    );
  }

  /// Factory for when an active filter yields 0 matches
  factory AppEmptyState.filtered({
    String title = 'لا توجد نتائج مطابقة',
    String description = 'جرّب تغيير خيارات التصفية أو إزالة الفلتر لعرض جميع العناصر.',
    IconData icon = Icons.filter_alt_off_outlined,
    String actionLabel = 'عرض الكل',
    VoidCallback? onClearFilter,
  }) {
    return AppEmptyState(
      title: title,
      description: description,
      icon: icon,
      type: EmptyStateType.filtered,
      actionLabel: actionLabel,
      actionIcon: Icons.refresh_rounded,
      onAction: onClearFilter,
    );
  }

  /// Factory for error recovery
  factory AppEmptyState.error({
    String title = 'تعذر تحميل المحتوى',
    String description = 'حدث خطأ غير متوقع أثناء استرجاع البيانات. يرجى المحاولة مجدداً.',
    IconData icon = Icons.error_outline_rounded,
    String actionLabel = 'إعادة المحاولة',
    VoidCallback? onRetry,
  }) {
    return AppEmptyState(
      title: title,
      description: description,
      icon: icon,
      type: EmptyStateType.error,
      actionLabel: actionLabel,
      actionIcon: Icons.replay_rounded,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconBgColor;
    Color iconColor;

    switch (type) {
      case EmptyStateType.initial:
        iconBgColor = AppColors.primary.withOpacity(0.12);
        iconColor = AppColors.primary;
        break;
      case EmptyStateType.filtered:
        iconBgColor = AppColors.warning.withOpacity(0.12);
        iconColor = AppColors.warning;
        break;
      case EmptyStateType.error:
        iconBgColor = AppColors.danger.withOpacity(0.12);
        iconColor = AppColors.danger;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.cairo(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: actionLabel!,
                icon: actionIcon,
                variant: type == EmptyStateType.error
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.primary,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
