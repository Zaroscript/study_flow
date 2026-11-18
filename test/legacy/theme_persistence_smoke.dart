import 'dart:io';

// Theme mode representation matching Flutter ThemeMode
enum AppThemeMode { system, light, dark }

class TestPreferencesService {
  static const String _keyThemeMode = 'studyflow_theme_mode';

  final Map<String, dynamic> _storage = {};

  Future<void> init() async {}

  AppThemeMode getThemeMode() {
    final raw = _storage[_keyThemeMode] as String?;
    switch (raw) {
      case 'dark':
        return AppThemeMode.dark;
      case 'light':
        return AppThemeMode.light;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }

  Future<bool> setThemeMode(AppThemeMode mode) async {
    _storage[_keyThemeMode] = mode.name;
    return true;
  }

  Future<void> clearPreferences() async {
    _storage.clear();
  }
}

Future<void> main() async {
  stdout.writeln('--- Running Theme Preference Persistence Tests ---');

  final prefs = TestPreferencesService();
  await prefs.init();

  // Test 1: Default theme mode is system
  await prefs.clearPreferences();
  final defaultTheme = prefs.getThemeMode();
  assert(
    defaultTheme == AppThemeMode.system,
    'Default theme should follow system',
  );
  stdout.writeln('✅ Test 1 Passed: Default theme is AppThemeMode.system');

  // Test 2: Setting Dark mode
  await prefs.setThemeMode(AppThemeMode.dark);
  assert(
    prefs.getThemeMode() == AppThemeMode.dark,
    'Theme should persist as Dark mode',
  );
  stdout.writeln('✅ Test 2 Passed: Dark theme persisted');

  // Test 3: Setting Light mode
  await prefs.setThemeMode(AppThemeMode.light);
  assert(
    prefs.getThemeMode() == AppThemeMode.light,
    'Theme should persist as Light mode',
  );
  stdout.writeln('✅ Test 3 Passed: Light theme persisted');

  // Test 4: Setting back to System mode
  await prefs.setThemeMode(AppThemeMode.system);
  assert(
    prefs.getThemeMode() == AppThemeMode.system,
    'Theme should persist as System mode',
  );
  stdout.writeln('✅ Test 4 Passed: System theme persisted');

  stdout.writeln('🎉 All Theme Persistence Tests Passed!\n');
}
