import 'package:material_ui/material_ui.dart';

/// Design tokens and color palette matching the original StudyFlow web application.
class AppColors {
  AppColors._();

  // Brand colors
  static const Color primary = Color(0xFF6344AD); // Indigo
  static const Color primaryLight = Color(0xFFC3AAF9);
  static const Color secondary = Color(0xFF9E4279); // Pink

  // Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFF7F7FB);
  static const Color backgroundDark = Color(0xFF191824);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF242231);

  // Borders
  static const Color borderLight = Color(0xFFE5E1ED);
  static const Color borderDark = Color(0xFF454052);

  // Text
  static const Color textPrimaryLight = Color(0xFF29243C);
  static const Color textPrimaryDark = Color(0xFFF2EFF9);
  static const Color textMutedLight = Color(0xFF686177);
  static const Color textMutedDark = Color(0xFFBCB5CB);

  // Status & Accents
  static const Color success = Color(0xFF267153); // Green
  static const Color warning = Color(0xFF806106); // Yellow
  static const Color danger = Color(0xFFAC3244); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Category Colors
  static const Color categoryStudy = Color(0xFF3B82F6);
  static const Color categorySchool = Color(0xFF6366F1);
  static const Color categoryLesson = Color(0xFFA855F7);
  static const Color categoryHomework = Color(0xFF9E4279);
  static const Color categorySleep = Color(0xFF686177);
  static const Color categoryExercise = Color(0xFF267153);
  static const Color categoryMeal = Color(0xFFF97316);
  static const Color categoryReading = Color(0xFF14B8A6);
  static const Color categoryBreak = Color(0xFF806106);
  static const Color categoryPersonal = Color(0xFFAC3244);

  /// Helper to get color by category identifier
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'study':
        return categoryStudy;
      case 'school':
        return categorySchool;
      case 'lesson':
        return categoryLesson;
      case 'homework':
        return categoryHomework;
      case 'sleep':
        return categorySleep;
      case 'exercise':
        return categoryExercise;
      case 'meal':
        return categoryMeal;
      case 'reading':
        return categoryReading;
      case 'break':
        return categoryBreak;
      case 'personal':
        return categoryPersonal;
      default:
        return primary;
    }
  }
}
