import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_flow/main.dart';
import 'package:study_flow/features/onboarding/screens/onboarding_screen.dart';

void main() {
  testWidgets('StudyFlow smoke test - loads onboarding when profile is null', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: StudyFlowApp()));

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify Onboarding screen is loaded as initial route
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('مرحباً بك في ENote'), findsOneWidget);
    expect(find.text('ابدأ رحلتك'), findsOneWidget);
  });
}
