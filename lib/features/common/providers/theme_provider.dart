import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/preferences/preferences_service.dart';
import '../../../core/utils/app_haptics.dart';
import 'study_flow_state_provider.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(prefsService);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final IPreferencesService _prefs;

  ThemeModeNotifier(this._prefs) : super(_prefs.getThemeMode());

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setTheme(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    if (mounted) state = mode;
  }

  Future<void> toggleTheme() async {
    AppHaptics.selection();
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }
}
