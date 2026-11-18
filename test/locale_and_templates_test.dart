import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_flow/data/local/preferences/preferences_service.dart';
import 'package:study_flow/l10n/locale_provider.dart';
import 'package:study_flow/features/ai_assistant/services/ai_assistant_service.dart';
import 'package:study_flow/features/ai_assistant/models/ai_assistant_models.dart';

void main() {
  test('language survives preferences and notifier recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = SharedPreferencesService();
    await preferences.init();
    final notifier = LocaleNotifier(preferences);
    await notifier.setLanguage('en');
    notifier.dispose();
    final reopened = SharedPreferencesService();
    await reopened.init();
    final restored = LocaleNotifier(reopened);
    expect(restored.state.languageCode, 'en');
    await expectLater(restored.setLanguage('fr'), throwsArgumentError);
    expect(restored.state.languageCode, 'en');
    restored.dispose();
  });

  test(
    'local templates preserve source text and label English quiz honestly',
    () {
      final service = AiAssistantService.forLanguage('en');
      final plan = service.generateStudyPlan(
        subject: 'مذاكرتي الخاصة',
        availableHours: 3,
      );
      expect(plan.subject, 'مذاكرتي الخاصة');
      expect(plan.totalMinutes, 180);
      expect(plan.phases.every((phase) => phase.durationMinutes > 0), isTrue);
      final insight = service.generateNoteInsights(
        content: 'محتوى يكتبه المستخدم\nSecond original line.',
      );
      expect(insight.keyTakeaways, contains('محتوى يكتبه المستخدم'));
      expect(insight.keyTakeaways, contains('Second original line'));
      expect(
        service.labels.localQuizReply,
        contains('does not assess your subject knowledge'),
      );
      expect(
        service.generateQuiz(subject: 'Physics', count: 99).questions.length,
        3,
      );
    },
  );

  test('exam anxiety takes precedence over study-plan and quiz keywords', () {
    for (final language in ['ar', 'en']) {
      final service = AiAssistantService.forLanguage(language);
      final prompt = language == 'ar'
          ? 'عندي قلق من الامتحانات ومذاكرة صعبة'
          : 'I am anxious about my study plan and exam quiz';
      final reply = service.handleUserPrompt(prompt);
      expect(reply.type, AiMessageType.text);
      expect(reply.quiz, isNull);
      expect(reply.studyPlan, isNull);
      expect(reply.content, isNot(contains('40%')));
    }
  });
}
