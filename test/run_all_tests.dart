import 'dart:io';

import 'legacy/profile_validation_smoke.dart' as profile_validation;
import 'legacy/profile_persistence_smoke.dart' as profile_persistence;
import 'legacy/onboarding_completion_smoke.dart' as onboarding_completion;
import 'legacy/theme_persistence_smoke.dart' as theme_persistence;
import 'legacy/database_migration_smoke.dart' as database_migration;
import 'legacy/navigation_flow_smoke.dart' as navigation_flow;
import 'legacy/prompt03_features_smoke.dart' as prompt03_features;
import 'legacy/ai_assistant_smoke.dart' as ai_assistant;
import 'legacy/flip_clock_widget_smoke.dart' as flip_clock_widget;
import 'legacy/notifications_smoke.dart' as notifications;
import 'legacy/onboarding_smoke.dart' as onboarding;

Future<void> main() async {
  stdout.writeln('========================================================');
  stdout.writeln('🧪 StudyFlow Suite — Comprehensive Automated Tests 🧪');
  stdout.writeln('========================================================\n');

  profile_validation.main();
  await profile_persistence.main();
  await onboarding_completion.main();
  await theme_persistence.main();
  await database_migration.main();
  navigation_flow.main();
  prompt03_features.main();
  ai_assistant.main();
  flip_clock_widget.main();
  await notifications.main();
  onboarding.main();

  stdout.writeln('========================================================');
  stdout.writeln(
    'Legacy smoke fixtures completed; production verification uses flutter test.',
  );
  stdout.writeln('========================================================');
}
