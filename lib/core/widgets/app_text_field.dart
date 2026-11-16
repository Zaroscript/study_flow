import 'package:flutter/material.dart';

import '../utils/app_validators.dart';

class AppTextField extends StatelessWidget {
  final String? label, hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText, readOnly;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon, suffixIcon;
  final int maxLines;
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
  });
  String? _validate(String? value) {
    if (validator != null) return validator!(value);
    final name = label ?? '';
    if (name.contains('وقت التركيز'))
      return AppValidators.integer(value, min: 1, max: 120);
    if (name.contains('استراحة قصيرة'))
      return AppValidators.integer(value, min: 1, max: 30);
    if (name.contains('استراحة طويلة'))
      return AppValidators.integer(value, min: 1, max: 60);
    if (name == 'الهدف الإجمالي') return AppValidators.integer(value, min: 1);
    if (name == 'الإنجاز الحالي') return AppValidators.integer(value);
    if (name == 'وقت البدء' || name == 'وقت الانتهاء')
      return AppValidators.time(value);
    if (name.contains('تاريخ')) return AppValidators.date(value);
    if ([
      'العنوان',
      'عنوان المهمة',
      'عنوان الهدف',
      'اسم العادة',
      'المادة',
      'تفاصيل الواجب',
      'الاسم الكامل',
    ].contains(name))
      return AppValidators.required(value);
    return null;
  }

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    readOnly: readOnly,
    maxLines: obscureText ? 1 : maxLines,
    validator: _validate,
    onChanged: onChanged,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: Theme.of(context).textTheme.bodyLarge,
    textInputAction: maxLines == 1
        ? TextInputAction.next
        : TextInputAction.newline,
    scrollPadding: const EdgeInsets.all(32),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 3,
    ),
  );
}
