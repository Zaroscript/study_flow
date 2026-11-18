import 'dart:io';

import 'package:study_flow/core/utils/app_validators.dart';

// Runs without Flutter: dart --enable-asserts test/native_validators_smoke.dart
void main() {
  var assertionsEnabled = false;
  assert(assertionsEnabled = true);
  if (!assertionsEnabled) {
    throw StateError('Run this file with --enable-asserts.');
  }
  assert(AppValidators.required('  ') != null);
  assert(AppValidators.integer('0', min: 1) != null);
  assert(AppValidators.integer('121', min: 1, max: 120) != null);
  assert(AppValidators.integer('25', min: 1, max: 120) == null);
  assert(AppValidators.validTimeRange('09:00', '10:30'));
  assert(!AppValidators.validTimeRange('10:30', '09:00'));
  assert(!AppValidators.validTimeRange('09:00', '09:00'));
  assert(AppValidators.time('12:99') != null);
  assert(AppValidators.date('2026-02-31') != null);
  assert(AppValidators.date('2026-11-15') == null);
  stdout.writeln('PASS: 10 native form validation checks.');
}
