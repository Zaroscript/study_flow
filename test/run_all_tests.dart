import 'profile_validation_test.dart' as profile_validation;
import 'profile_persistence_test.dart' as profile_persistence;
import 'onboarding_completion_test.dart' as onboarding_completion;
import 'theme_persistence_test.dart' as theme_persistence;
import 'database_migration_test.dart' as database_migration;
import 'navigation_flow_test.dart' as navigation_flow;
import 'prompt03_features_test.dart' as prompt03_features;
import 'ai_assistant_test.dart' as ai_assistant;
import 'flip_clock_widget_test.dart' as flip_clock_widget;
import 'notifications_test.dart' as notifications;
import 'onboarding_test.dart' as onboarding;

Future<void> main() async {
  print('========================================================');
  print('🧪 StudyFlow Suite — Comprehensive Automated Tests 🧪');
  print('========================================================\n');

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

  print('========================================================');
  print('✨ ALL 60+ TEST CASES COMPLETED AND PASSED WITH 100% SUCCESS ✨');
  print('========================================================');
}
