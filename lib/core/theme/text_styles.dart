import 'package:material_ui/material_ui.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle cairo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Cairo',
      fontSize: fontSize == null ? 16 : (fontSize < 14 ? 14 : fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.6,
      decoration: decoration,
    );
  }
}
