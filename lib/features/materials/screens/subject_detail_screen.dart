import 'package:flutter/material.dart' hide MaterialType;

import '../../../core/widgets/app_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/material_item_model.dart';
import '../providers/materials_provider.dart';

class SubjectDetailScreen extends ConsumerWidget {
  final String folderId;
  final MaterialFolder? folder;

  const SubjectDetailScreen({Key? key, required this.folderId, this.folder})
    : super(key: key);

  String _formatType(MaterialType type) {
    switch (type) {
      case MaterialType.book:
        return 'كتاب دراسي';
      case MaterialType.pdf:
        return 'ملف PDF';
      case MaterialType.summary:
        return 'ملخص مراجعة';
      case MaterialType.examBank:
        return 'بنك أسئلة';
      case MaterialType.note:
        return 'مذكرة شرح';
    }
  }

  Color _typeColor(MaterialType type) {
    switch (type) {
      case MaterialType.book:
        return AppColors.primary;
      case MaterialType.pdf:
        return AppColors.danger;
      case MaterialType.summary:
        return AppColors.success;
      case MaterialType.examBank:
        return AppColors.warning;
      case MaterialType.note:
        return AppColors.secondary;
    }
  }

  void _showAddItemSheet(
    BuildContext context,
    WidgetRef ref,
    String folderName,
  ) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final pagesCtrl = TextEditingController(text: '100');
    MaterialType selectedType = MaterialType.pdf;

    final typeOptions = [
      const DropdownOption(value: MaterialType.pdf, label: 'ملف PDF'),
      const DropdownOption(value: MaterialType.book, label: 'كتاب دراسي'),
      const DropdownOption(value: MaterialType.summary, label: 'ملخص مراجعة'),
      const DropdownOption(value: MaterialType.examBank, label: 'بنك أسئلة'),
      const DropdownOption(value: MaterialType.note, label: 'مذكرة شرح'),
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
                      'إضافة ملف أو كتاب جديد',
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
                  label: 'عنوان الملف أو الكتاب',
                  hint: 'مثال: كتاب الفيزياء الحديثة - الفصل الأول',
                  controller: titleCtrl,
                ),
                const SizedBox(height: 12),
                AppDropdown<MaterialType>(
                  label: 'نوع المادة',
                  value: selectedType,
                  options: typeOptions,
                  onChanged: (val) {
                    if (val != null) setState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'إجمالي عدد الصفحات',
                  controller: pagesCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'ملاحظات / وصف المحتوى',
                  hint: 'ملاحظات هامة حول هذا الملف...',
                  controller: descCtrl,
                ),
                const SizedBox(height: 20),
                AppButton(
                  text: 'حفظ في المجلد',
                  isFullWidth: true,
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    if (title.isNotEmpty) {
                      final newItem = MaterialItem(
                        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                        folderId: folderId,
                        subject: folderName,
                        title: title,
                        type: selectedType,
                        totalPages: int.tryParse(pagesCtrl.text) ?? 100,
                        readPages: 0,
                        description: descCtrl.text.trim(),
                        dateAdded: DateTime.now()
                            .toIso8601String()
                            .split('T')
                            .first,
                      );
                      ref
                          .read(materialsProvider.notifier)
                          .addMaterialItem(newItem);
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

  void _showUpdateProgressDialog(
    BuildContext context,
    WidgetRef ref,
    MaterialItem item,
  ) {
    final pagesCtrl = TextEditingController(text: item.readPages.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تحديث تقدم القراءة',
          style: AppTextStyles.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل رقم آخر صفحة قرأتها في "${item.title}":',
              style: AppTextStyles.cairo(fontSize: 13),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'الصفحات المقروءة (من أصل ${item.totalPages})',
              controller: pagesCtrl,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: AppTextStyles.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              final newPages = int.tryParse(pagesCtrl.text) ?? item.readPages;
              if (newPages >= item.totalPages) {
                AppHaptics.milestone();
              } else {
                AppHaptics.medium();
              }
              ref
                  .read(materialsProvider.notifier)
                  .updateReadingProgress(item.id, newPages);
              Navigator.pop(ctx);
            },
            child: Text(
              'تحديث',
              style: AppTextStyles.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(materialsProvider);
    final items = state.getItemsForFolder(folderId);
    final currentFolder =
        folder ??
        state.folders.firstWhere(
          (f) => f.id == folderId,
          orElse: () => MaterialFolder(id: folderId, name: 'المادة'),
        );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentFolder.name,
          style: AppTextStyles.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'إضافة ملف',
            onPressed: () =>
                _showAddItemSheet(context, ref, currentFolder.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Folder Stats Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6366F1)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentFolder.name,
                        style: AppTextStyles.cairo(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${items.length} ملفات',
                          style: AppTextStyles.cairo(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'جميع الكتب والمذكرات والملخصات الدراسية الخاصة بهذه المادة',
                    style: AppTextStyles.cairo(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (items.isEmpty)
              AppEmptyState.initial(
                title: 'المجلد فارغ حالياً',
                description:
                    'أضف كتب ومذكرات و PDFs مادة ${currentFolder.name} لتنظيمها وتتبع قراءتك.',
                icon: Icons.menu_book_outlined,
                actionLabel: 'إضافة ملف الآن',
                onAction: () =>
                    _showAddItemSheet(context, ref, currentFolder.name),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final typeBadgeColor = _typeColor(item.type);
                  final percent = item.readingPercentage;

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: typeBadgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _formatType(item.type),
                                style: AppTextStyles.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: typeBadgeColor,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'تحديث الصفحات',
                                  onPressed: () => _showUpdateProgressDialog(
                                    context,
                                    ref,
                                    item,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'حذف العنصر',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(materialsProvider.notifier)
                                        .deleteItem(item.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          style: AppTextStyles.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Reading Progress Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تقدم القراءة: ${item.readPages} من ${item.totalPages} صفحة',
                              style: AppTextStyles.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: AppTextStyles.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: typeBadgeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        AppProgressBar(
                          progress: percent.toDouble(),
                          color: typeBadgeColor,
                          height: 7,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
