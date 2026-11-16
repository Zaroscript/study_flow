import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';

class GradeCardSelector extends StatelessWidget {
  final String? selectedGrade;
  final ValueChanged<String> onSelected;

  const GradeCardSelector({
    Key? key,
    required this.selectedGrade,
    required this.onSelected,
  }) : super(key: key);

  static const _gradeMetadata = [
    {
      'title': 'المرحلة الإعدادية',
      'subtitle': 'تأسيس قوي وعادات تنظيمية',
      'icon': Icons.menu_book_rounded,
      'color': Colors.blue,
    },
    {
      'title': 'المرحلة الثانوية',
      'subtitle': 'تركيز عالي وإدارة الأولويات',
      'icon': Icons.auto_stories_rounded,
      'color': Colors.indigo,
    },
    {
      'title': 'المرحلة الجامعية',
      'subtitle': 'أبحاث ومحاضرات ومشاريع',
      'icon': Icons.school_rounded,
      'color': Colors.purple,
    },
    {
      'title': 'أخرى',
      'subtitle': 'تعلّم ذاتي ودورات مهنية',
      'icon': Icons.workspace_premium_rounded,
      'color': Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _gradeMetadata.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = _gradeMetadata[index];
        final title = item['title'] as String;
        final subtitle = item['subtitle'] as String;
        final icon = item['icon'] as IconData;
        final color = item['color'] as MaterialColor;
        final isSelected = selectedGrade == title;

        return GestureDetector(
          onTap: () {
            AppHaptics.selectionClick();
            onSelected(title);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(isDark ? 0.25 : 0.08)
                  : (isDark ? const Color(0xFF1F1D2B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF2E2C3D) : const Color(0xFFE5E7EB)),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: (isSelected ? AppColors.primary : color)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected ? AppColors.primary : color,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.white : AppColors.textPrimaryLight),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
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
        );
      },
    );
  }
}
