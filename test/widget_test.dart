import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_flow/main.dart';
import 'package:study_flow/features/onboarding/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_flow/data/local/preferences/preferences_service.dart';
import 'package:study_flow/data/repositories/in_memory_study_flow_repository.dart';
import 'package:study_flow/features/common/providers/study_flow_state_provider.dart';

void main() {
  testWidgets('StudyFlow smoke test - loads onboarding when profile is null', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = SharedPreferencesService();
    await preferences.init();
    final repository = InMemoryStudyFlowRepository();
    await repository.clearAllData();
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(preferences),
          studyFlowRepositoryProvider.overrideWithValue(repository),
        ],
        child: const StudyFlowApp(),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify Onboarding screen is loaded as initial route
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('مرحباً بك في ENote'), findsOneWidget);
    expect(find.text('ابدأ الإعداد المخصص'), findsOneWidget);
  });
}
