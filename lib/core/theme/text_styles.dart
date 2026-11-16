import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle cairo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize == null ? 16 : (fontSize < 14 ? 14 : fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.6,
      decoration: decoration,
    );
  }
}
