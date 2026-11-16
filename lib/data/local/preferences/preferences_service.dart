import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IPreferencesService {
  Future<void> init();
  bool isOnboardingCompleted();
  Future<bool> setOnboardingCompleted(bool value);
  ThemeMode getThemeMode();
  Future<bool> setThemeMode(ThemeMode mode);
  Future<void> clearPreferences();
}

class SharedPreferencesService implements IPreferencesService {
  static const String _keyOnboardingCompleted =
      'studyflow_onboarding_completed';
  static const String _keyThemeMode = 'studyflow_theme_mode';

  SharedPreferences? _prefs;
  // Fallback in-memory cache to guarantee zero runtime crashes and instant startup
  final Map<String, dynamic> _memoryCache = {};

  @override
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (_prefs != null) {
        _memoryCache[_keyOnboardingCompleted] = _prefs!.getBool(
          _keyOnboardingCompleted,
        );
        _memoryCache[_keyThemeMode] = _prefs!.getString(_keyThemeMode);
      }
    } catch (_) {
      // In tests or headless environments, fallback to memoryCache safely
    }
  }

  @override
  bool isOnboardingCompleted() {
    if (_prefs != null) {
      return _prefs!.getBool(_keyOnboardingCompleted) ?? false;
    }
    return (_memoryCache[_keyOnboardingCompleted] as bool?) ?? false;
  }

  @override
  Future<bool> setOnboardingCompleted(bool value) async {
    _memoryCache[_keyOnboardingCompleted] = value;
    try {
      if (_prefs != null) {
        return await _prefs!.setBool(_keyOnboardingCompleted, value);
      }
    } catch (_) {}
    return true;
  }

  @override
  ThemeMode getThemeMode() {
    String? raw;
    if (_prefs != null) {
      raw = _prefs!.getString(_keyThemeMode);
    } else {
      raw = _memoryCache[_keyThemeMode] as String?;
    }

    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<bool> setThemeMode(ThemeMode mode) async {
    String rawValue;
    switch (mode) {
      case ThemeMode.dark:
        rawValue = 'dark';
        break;
      case ThemeMode.light:
        rawValue = 'light';
        break;
      case ThemeMode.system:
        rawValue = 'system';
        break;
    }

    _memoryCache[_keyThemeMode] = rawValue;
    try {
      if (_prefs != null) {
        return await _prefs!.setString(_keyThemeMode, rawValue);
      }
    } catch (_) {}
    return true;
  }

  @override
  Future<void> clearPreferences() async {
    _memoryCache.clear();
    try {
      if (_prefs != null) {
        await _prefs!.clear();
      }
    } catch (_) {}
  }
}
