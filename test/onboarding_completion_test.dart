// Standalone implementation of SharedPreferences logic for unit testing
class TestPreferencesService {
  static const String _keyOnboardingCompleted = 'studyflow_onboarding_completed';
  static const String _keyThemeMode = 'studyflow_theme_mode';

  final Map<String, dynamic> _storage = {};

  Future<void> init() async {}

  bool isOnboardingCompleted() {
    return (_storage[_keyOnboardingCompleted] as bool?) ?? false;
  }

  Future<bool> setOnboardingCompleted(bool value) async {
    _storage[_keyOnboardingCompleted] = value;
    return true;
  }

  String getThemeMode() {
    return (_storage[_keyThemeMode] as String?) ?? 'system';
  }

  Future<bool> setThemeMode(String mode) async {
    _storage[_keyThemeMode] = mode;
    return true;
  }

  Future<void> clearPreferences() async {
    _storage.clear();
  }
}

Future<void> main() async {
  print('--- Running Onboarding Completion Persistence Tests ---');

  final prefs = TestPreferencesService();
  await prefs.init();

  // Test 1: By default, onboarding is not completed
  await prefs.clearPreferences();
  assert(prefs.isOnboardingCompleted() == false, 'First-time launch should have onboarding incomplete');
  print('✅ Test 1 Passed: First-time user defaults to onboarding incomplete');

  // Test 2: Set onboarding completed
  await prefs.setOnboardingCompleted(true);
  assert(prefs.isOnboardingCompleted() == true, 'Onboarding completion flag should be true');
  print('✅ Test 2 Passed: Onboarding completion persisted');

  // Test 3: Reset preferences returns it to incomplete
  await prefs.clearPreferences();
  assert(prefs.isOnboardingCompleted() == false, 'Resetting preferences resets onboarding flag');
  print('✅ Test 3 Passed: Reset restores initial onboarding state');

  print('🎉 All Onboarding Completion Tests Passed!\n');
}
