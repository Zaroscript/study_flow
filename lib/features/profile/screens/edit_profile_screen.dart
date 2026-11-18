import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/page_header.dart';
import '../../../data/models/user_profile.dart';
import '../../common/providers/study_flow_state_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  String? _selectedGrade;
  String? _errorMessage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    if (profile != null) {
      _nameController.text = profile.name;
      _selectedGrade = profile.grade;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final trimmedName = _nameController.text.trim();

    if (trimmedName.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال اسم الطالب.');
      return;
    }

    if (_selectedGrade == null || _selectedGrade!.trim().isEmpty) {
      setState(() => _errorMessage = 'يرجى اختيار المرحلة الدراسية.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updatedProfile = UserProfile(
        name: trimmedName,
        grade: _selectedGrade!,
      );

      await ref.read(profileProvider.notifier).saveProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('تم تحديث الملف الشخصي بنجاح! ✅'),
              style: AppTextStyles.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'حدث خطأ أثناء حفظ التعديلات.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradeOptions = AppConstants.educationalGrades
        .map((grade) => DropdownOption(value: grade, label: grade))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('تعديل الملف الشخصي'),
          style: AppTextStyles.cairo(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'الملف الشخصي',
                description: 'تعديل بيانات الطالب والمرحلة الدراسية المسجلة',
              ),
              const SizedBox(height: 8),

              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    AppTextField(
                      label: 'اسم الطالب',
                      hint: 'الاسم الكامل',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    AppDropdown<String>(
                      label: 'المرحلة الدراسية',
                      value: _selectedGrade,
                      options: gradeOptions,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedGrade = val;
                            if (_errorMessage != null) _errorMessage = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    AppButton(
                      text: 'حفظ التعديلات',
                      isFullWidth: true,
                      height: 50,
                      isLoading: _isSaving,
                      icon: Icons.check_rounded,
                      onPressed: _handleSave,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
