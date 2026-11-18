import 'package:material_ui/material_ui.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: dark ? AppColors.primaryLight : AppColors.primary,
          onPrimary: dark ? const Color(0xFF211834) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF372C4D)
              : const Color(0xFFEFEBF8),
          onPrimaryContainer: dark ? AppColors.primaryLight : AppColors.primary,
          surface: dark ? AppColors.cardDark : AppColors.cardLight,
          onSurface: dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          onSurfaceVariant: dark
              ? AppColors.textMutedDark
              : AppColors.textMutedLight,
          outline: dark ? const Color(0xFF8F859F) : const Color(0xFF9991A9),
          outlineVariant: dark ? AppColors.borderDark : AppColors.borderLight,
          error: dark ? const Color(0xFFFFA8B6) : AppColors.danger,
          onError: dark ? const Color(0xFF481420) : Colors.white,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
    );
    final text = base.textTheme
        .apply(fontFamily: 'Cairo')
        .copyWith(
          headlineSmall: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 26,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            height: 1.5,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            height: 1.7,
            color: scheme.onSurface,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            height: 1.7,
            color: scheme.onSurface,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w700,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        );
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      scaffoldBackgroundColor: dark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: border(scheme.outline),
        enabledBorder: border(scheme.outline),
        focusedBorder: border(scheme.primary, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
        errorMaxLines: 3,
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          foregroundColor: WidgetStatePropertyAll(scheme.onSurfaceVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
    );
  }
}
