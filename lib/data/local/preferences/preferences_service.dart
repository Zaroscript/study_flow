import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IPreferencesService {
  Future<void> init();
  bool isOnboardingCompleted();
  Future<bool> setOnboardingCompleted(bool value);
  ThemeMode getThemeMode();
  Future<bool> setThemeMode(ThemeMode mode);
  Future<void> clearPreferences();
}

/// Preferences fail visibly rather than pretending an in-memory write is durable.
class SharedPreferencesService implements IPreferencesService {
  SharedPreferences? _prefs;
  SharedPreferences get _store =>
      _prefs ?? (throw StateError('Preferences not initialized'));
  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  bool isOnboardingCompleted() =>
      _store.getBool('studyflow_onboarding_completed') ?? false;
  @override
  Future<bool> setOnboardingCompleted(bool value) async {
    final success = await _store.setBool(
      'studyflow_onboarding_completed',
      value,
    );
    if (!success) throw StateError('Preferences write failed');
    return true;
  }

  @override
  ThemeMode getThemeMode() =>
      switch (_store.getString('studyflow_theme_mode')) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };
  @override
  Future<bool> setThemeMode(ThemeMode mode) async {
    final success = await _store.setString('studyflow_theme_mode', mode.name);
    if (!success) throw StateError('Theme write failed');
    return true;
  }

  String get languageCode => _store.getString('enote_locale') ?? 'ar';
  Future<void> setLanguageCode(String value) async {
    if (!['ar', 'en'].contains(value)) {
      throw ArgumentError('Unsupported locale');
    }
    if (!await _store.setString('enote_locale', value)) {
      throw StateError('Locale write failed');
    }
  }

  @override
  Future<void> clearPreferences() async {
    for (final key in [
      'studyflow_onboarding_completed',
      'studyflow_theme_mode',
      'enote_locale',
    ]) {
      if (!await _store.remove(key)) {
        throw StateError('Preferences reset failed');
      }
    }
  }
}
