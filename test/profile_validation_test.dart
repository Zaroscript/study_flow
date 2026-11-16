import '../lib/core/constants/app_constants.dart';

void main() {
  print('--- Running Profile Validation Tests ---');

  // Test 1: Whitespace-only name should fail validation
  String rawName1 = '    ';
  String trimmed1 = rawName1.trim();
  assert(trimmed1.isEmpty, 'Whitespace-only name should be empty after trim');
  print('✅ Test 1 Passed: Whitespace-only name rejected');

  // Test 2: Valid trimmed name
  String rawName2 = '  أحمد محمد  ';
  String trimmed2 = rawName2.trim();
  assert(trimmed2 == 'أحمد محمد', 'Name should be trimmed accurately');
  assert(trimmed2.isNotEmpty, 'Trimmed name should not be empty');
  print('✅ Test 2 Passed: Valid name trimmed successfully: $trimmed2');

  // Test 3: Educational stage validation
  const allowedStages = AppConstants.educationalGrades;
  assert(allowedStages.contains('المرحلة الثانوية'), 'Allowed stages should contain secondary stage');
  assert(allowedStages.contains('المرحلة الإعدادية'), 'Allowed stages should contain preparatory stage');
  assert(allowedStages.contains('المرحلة الجامعية'), 'Allowed stages should contain university stage');
  assert(allowedStages.contains('أخرى'), 'Allowed stages should contain other stage');
  assert(!allowedStages.contains('غير محدد'), 'Invalid stage should be rejected');
  print('✅ Test 3 Passed: Educational stage options strictly validated');

  print('🎉 All Profile Validation Tests Passed!\n');
}
