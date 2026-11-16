import 'package:flutter/material.dart';

import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../providers/materials_provider.dart';

class MaterialsScreen extends ConsumerWidget {
  const MaterialsScreen({Key? key}) : super(key: key);

  Color _resolveColor(String colorKey) {
    switch (colorKey) {
      case 'indigo':
        return AppColors.primary;
      case 'blue':
        return AppColors.info;
      case 'purple':
        return const Color(0xFF9333EA);
      case 'green':
        return AppColors.success;
      case 'pink':
        return AppColors.secondary;
      case 'teal':
        return const Color(0xFF0D9488);
      default:
        return AppColors.primary;
    }
  }

  void _showAddFolderSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedColor = 'indigo';

    final colorOptions = [
      const DropdownOption(value: 'indigo', label: 'بنفسجي'),
      const DropdownOption(value: 'blue', label: 'أزرق'),
      const DropdownOption(value: 'purple', label: 'أرجواني'),
      const DropdownOption(value: 'green', label: 'أخضر'),
      const DropdownOption(value: 'pink', label: 'وردي'),
      const DropdownOption(value: 'teal', label: 'سماوي'),
    ];

    showAppSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
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
                      'إضافة مجلد مادة جديدة',
                      style: AppTextStyles.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'اسم المادة',
                  hint: 'مثال: الأحياء والجيولوجيا',
                  controller: nameCtrl,
                ),
                const SizedBox(height: 12),
                AppDropdown<String>(
                  label: 'لون المجلد',
                  value: selectedColor,
                  options: colorOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedColor = val);
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'إنشاء المجلد',
                  isFullWidth: true,
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      ref
                          .read(materialsProvider.notifier)
                          .addFolder(name, selectedColor);
                      Navigator.pop(ctx);
                    }
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(materialsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'المكتبة والمذكرات',
            description:
                'تنظيم الكتب، المذكرات، والـ PDFs في مجلدات خاصة بكل مادة',
            action: AppButton(
              text: 'مادة جديدة',
              icon: Icons.create_new_folder_outlined,
              onPressed: () => _showAddFolderSheet(context, ref),
            ),
          ),
          const SizedBox(height: 8),

          // Overview KPI
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المواد الدراسية',
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${state.folders.length} مواد',
                            style: AppTextStyles.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي الملفات',
                            style: AppTextStyles.cairo(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                          Text(
                            '${state.totalBooksCount} كتب وملفات',
                            style: AppTextStyles.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'مجلدات المواد الدراسية',
            style: AppTextStyles.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (state.folders.isEmpty)
            AppEmptyState.initial(
              title: 'لا توجد مجلدات بعد',
              description: 'أنشئ مجلدك الأول لكل مادة لتنظيم الكتب، المذكرات، والملفات بسهولة.',
              icon: Icons.folder_open_rounded,
              actionLabel: 'إضافة مادة جديدة',
              onAction: () => _showAddFolderSheet(context, ref),
            )
          else
            // Folders Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.folders.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent:
                    240 * (MediaQuery.textScalerOf(context).scale(16) / 16),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (ctx, i) {
                final folder = state.folders[i];
                final folderColor = _resolveColor(folder.color);

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () {
                    AppHaptics.selection();
                    context.push('/materials/${folder.id}', extra: folder);
                  },
                border: Border(
                  top: BorderSide(color: folderColor, width: 1),
                  right: BorderSide(color: Theme.of(context).dividerColor),
                  left: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: folderColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.folder_open_rounded,
                            color: folderColor,
                            size: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${folder.filesCount} ملف',
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.name,
                          style: AppTextStyles.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'فتح المجلد',
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
              );
            },
          ),
        ],
      ),
    );
  }
}
