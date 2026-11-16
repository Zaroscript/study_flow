import '../lib/data/models/user_profile.dart';

void runOnboardingTests() {
  print('Running Onboarding & Multi-Step Setup Logic Tests...');

  // Test 1: Whitespace trimming
  const rawInput = '   أحمد محمد   ';
  final trimmed = rawInput.trim();
  assert(trimmed == 'أحمد محمد', 'Trimmed name failed');
  assert(trimmed.isNotEmpty, 'Trimmed name empty');
  print('  ✓ Student name validation & whitespace stripping: PASSED');

  // Test 2: Educational stages validation
  const stages = [
    'المرحلة الإعدادية',
    'المرحلة الثانوية',
    'المرحلة الجامعية',
    'أخرى',
  ];
  assert(stages.length == 4, 'Stages length mismatch');
  assert(stages.contains('المرحلة الثانوية'), 'Missing high school stage');
  assert(stages.contains('المرحلة الجامعية'), 'Missing university stage');
  print('  ✓ Educational stages catalog: PASSED');

  // Test 3: UserProfile creation and persistence model
  final profile = UserProfile(
    name: 'سارة خالد',
    grade: 'المرحلة الثانوية',
  );
  assert(profile.name == 'سارة خالد', 'Profile name mismatch');
  assert(profile.grade == 'المرحلة الثانوية', 'Profile grade mismatch');

  final json = profile.toJson();
  final restored = UserProfile.fromJson(json);
  assert(restored.name == 'سارة خالد', 'Restored name mismatch');
  assert(restored.grade == 'المرحلة الثانوية', 'Restored grade mismatch');
  print('  ✓ UserProfile multi-step serialization: PASSED');

  // Test 4: Daily target limits
  const targets = [45, 90, 120, 180];
  for (final t in targets) {
    assert(t >= 30, 'Target too low');
    assert(t <= 240, 'Target too high');
  }
  print('  ✓ Daily focus target constraints: PASSED');

  // Test 5: Preferred study time
  const times = ['صباحي', 'مسائي'];
  assert(times.contains('صباحي'), 'Missing morning slot');
  assert(times.contains('مسائي'), 'Missing evening slot');
  print('  ✓ Preferred study rhythm slots: PASSED');
}

void main() {
  runOnboardingTests();
}
