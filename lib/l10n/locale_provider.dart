import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/preferences/preferences_service.dart';
import '../features/common/providers/study_flow_state_provider.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(preferencesServiceProvider)),
);

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._preferences)
    : super(
        Locale(
          _preferences is SharedPreferencesService
              ? _preferences.languageCode
              : 'ar',
        ),
      );
  final IPreferencesService _preferences;
  Future<void> setLanguage(String code) async {
    if (code != 'ar' && code != 'en') {
      throw ArgumentError('Unsupported language');
    }
    final preferences = _preferences;
    if (preferences is! SharedPreferencesService) {
      throw StateError('Locale persistence unavailable');
    }
    await preferences.setLanguageCode(code);
    if (mounted) state = Locale(code);
  }
}
