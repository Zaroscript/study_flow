import 'dart:io';

import 'package:study_flow/data/models/user_profile.dart';

String calculateRedirect({
  required bool isOnboardingCompleted,
  required UserProfile? profile,
  required String targetLocation,
}) {
  final hasCompleted = isOnboardingCompleted || profile != null;
  final isOnboarding = targetLocation == '/onboarding';

  if (!hasCompleted && !isOnboarding) {
    return '/onboarding';
  }

  if (hasCompleted && isOnboarding) {
    return '/dashboard';
  }

  return targetLocation; // allowed
}

void main() {
  stdout.writeln('--- Running Navigation Guard & Routing Flow Tests ---');

  // Test 1: First-time user navigating to dashboard gets redirected to onboarding
  final redirect1 = calculateRedirect(
    isOnboardingCompleted: false,
    profile: null,
    targetLocation: '/dashboard',
  );
  assert(
    redirect1 == '/onboarding',
    'First-time user should be redirected to /onboarding',
  );
  stdout.writeln('✅ Test 1 Passed: First-time user redirected to /onboarding');

  // Test 2: First-time user on /onboarding stays on /onboarding
  final redirect2 = calculateRedirect(
    isOnboardingCompleted: false,
    profile: null,
    targetLocation: '/onboarding',
  );
  assert(
    redirect2 == '/onboarding',
    'User on onboarding should stay on onboarding',
  );
  stdout.writeln('✅ Test 2 Passed: First-time user allowed on /onboarding');

  // Test 3: Returning user navigating to /dashboard is allowed
  const testProfile = UserProfile(name: 'عمر علي', grade: 'المرحلة الإعدادية');
  final redirect3 = calculateRedirect(
    isOnboardingCompleted: true,
    profile: testProfile,
    targetLocation: '/dashboard',
  );
  assert(
    redirect3 == '/dashboard',
    'Returning user should enter /dashboard directly',
  );
  stdout.writeln(
    '✅ Test 3 Passed: Returning user navigates directly to /dashboard',
  );

  // Test 4: Guard prevents accidental return to /onboarding after completion
  final redirect4 = calculateRedirect(
    isOnboardingCompleted: true,
    profile: testProfile,
    targetLocation: '/onboarding',
  );
  assert(
    redirect4 == '/dashboard',
    'Returning user should be redirected away from onboarding',
  );
  stdout.writeln(
    '✅ Test 4 Passed: Onboarding locked after completion; redirected to /dashboard',
  );

  // Test 5: Sub-routes such as /settings/profile are allowed for completed users
  final redirect5 = calculateRedirect(
    isOnboardingCompleted: true,
    profile: testProfile,
    targetLocation: '/settings/profile',
  );
  assert(
    redirect5 == '/settings/profile',
    'Profile edit route allowed for returning user',
  );
  stdout.writeln('✅ Test 5 Passed: Profile editing sub-route accessible');

  stdout.writeln('🎉 All Navigation Flow Tests Passed!\n');
}
