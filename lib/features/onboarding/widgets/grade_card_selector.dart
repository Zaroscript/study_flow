import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';

class GradeCardSelector extends StatelessWidget {
  final String? selectedGrade;
  final ValueChanged<String> onSelected;

  const GradeCardSelector({
    super.key,
    required this.selectedGrade,
    required this.onSelected,
  });

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide =
            constraints.maxWidth >= 600 &&
            MediaQuery.textScalerOf(context).scale(16) < 24;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _gradeMetadata.map((item) {
            final title = item['title'] as String;
            final selected = selectedGrade == title;
            return SizedBox(
              width: wide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth,
              child: Semantics(
                selected: selected,
                inMutuallyExclusiveGroup: true,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  color: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(item['icon'] as IconData),
                    title: Text(
                      context.tr(title),
                      style: AppTextStyles.cairo(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      context.tr(item['subtitle'] as String),
                      style: AppTextStyles.cairo(),
                    ),
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    onTap: () {
                      AppHaptics.selectionClick();
                      onSelected(title);
                    },
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
