import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

class DropdownOption<T> {
  final T value;
  final String label;

  const DropdownOption({required this.value, required this.label});
}

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownOption<T>> options;
  final ValueChanged<T?> onChanged;
  final String? hint;

  const AppDropdown({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            context.tr(label!),
            style: AppTextStyles.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          style: AppTextStyles.cairo(
            fontSize: 16,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          decoration: InputDecoration(
            hintText: hint == null ? null : context.tr(hint!),
          ),
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option.value,
              child: Text(
                context.tr(option.label),
                style: AppTextStyles.cairo(
                  fontSize: 16,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
