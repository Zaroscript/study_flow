import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/app_validators.dart';

enum FieldValidation {
  none,
  required,
  focusMinutes,
  shortBreakMinutes,
  longBreakMinutes,
  positiveInteger,
  nonNegativeInteger,
  time,
  date,
}

class AppTextField extends StatelessWidget {
  final String? label, hint;
  final FieldValidation validation;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText, readOnly;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon, suffixIcon;
  final int maxLines;
  const AppTextField({
    super.key,
    this.validation = FieldValidation.none,
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
  String? _validate(String? value) => validator != null
      ? validator!(value)
      : switch (validation) {
          FieldValidation.none => null,
          FieldValidation.required => AppValidators.required(value),
          FieldValidation.focusMinutes => AppValidators.integer(
            value,
            min: 1,
            max: 120,
          ),
          FieldValidation.shortBreakMinutes => AppValidators.integer(
            value,
            min: 1,
            max: 30,
          ),
          FieldValidation.longBreakMinutes => AppValidators.integer(
            value,
            min: 1,
            max: 60,
          ),
          FieldValidation.positiveInteger => AppValidators.integer(
            value,
            min: 1,
          ),
          FieldValidation.nonNegativeInteger => AppValidators.integer(value),
          FieldValidation.time => AppValidators.time(value),
          FieldValidation.date => AppValidators.date(value),
        };

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    readOnly: readOnly,
    maxLines: obscureText ? 1 : maxLines,
    validator: (value) {
      final error = _validate(value);
      if (error == null) return null;
      if (error == 'هذا الحقل مطلوب') return context.l10n.validationRequired;
      if (error == 'استخدم وقتًا صالحًا مثل 09:30') {
        return context.l10n.validationTime;
      }
      if (error == 'اختر تاريخًا صالحًا بصيغة YYYY-MM-DD') {
        return context.l10n.validationDate;
      }
      final range = RegExp(r'^أدخل عددًا صحيحًا بين (\d+) و(\d+)$')
          .firstMatch(error);
      if (range != null) {
        return context.l10n.validationInteger(
          context.display(int.parse(range[1]!)),
          context.display(int.parse(range[2]!)),
        );
      }
      return context.tr(error);
    },
    onChanged: onChanged,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    style: Theme.of(context).textTheme.bodyLarge,
    textInputAction: maxLines == 1
        ? TextInputAction.next
        : TextInputAction.newline,
    scrollPadding: const EdgeInsets.all(32),
    decoration: InputDecoration(
      labelText: label == null ? null : context.tr(label!),
      hintText: hint == null ? null : context.tr(hint!),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorMaxLines: 3,
    ),
  );
}
