import '../../../l10n/app_localizations_en.dart';
import '../models/ai_assistant_models.dart';

/// Offline templates: never represents a model connection or syllabus assessment.
class EnglishStudyTemplates {
  final l10n = AppLocalizationsEn();
  String get welcome => l10n.localWelcome;

  AiStudyPlan plan(String subject, int hours) {
    final safeHours = hours.clamp(1, 12);
    final minutes = safeHours * 60;
    final allocations = [
      (minutes * .25).round(),
      (minutes * .4).round(),
      (minutes * .2).round(),
    ];
    allocations.add(minutes - allocations.fold<int>(0, (sum, n) => sum + n));
    final titles = [
      l10n.localUnderstand,
      l10n.localPractise,
      l10n.localStrategies,
      l10n.localRevision,
    ];
    final descriptions = [
      l10n.localUnderstandBody,
      l10n.localPractiseBody,
      l10n.localRevision,
      l10n.localRevision,
    ];
    return AiStudyPlan(
      id: 'plan_${DateTime.now().microsecondsSinceEpoch}',
      subject: subject.trim().isEmpty ? l10n.localSubject : subject.trim(),
      availableHours: safeHours,
      overview: l10n.localOverview,
      phases: List.generate(
        4,
        (i) => AiStudySessionPhase(
          title: titles[i],
          durationMinutes: allocations[i],
          description: descriptions[i],
          cognitiveLevel: titles[i],
          energyBadge: '',
          subtasks: [descriptions[i]],
        ),
      ),
      smartTips: [l10n.localPlanTip],
      pomodoroRecommendation: l10n.localPomodoroTip,
      revisionCadence: l10n.localRevision,
    );
  }

  AiQuiz quiz(String subject, String difficulty, int count) {
    final questions = [
      (
        l10n.localQuizQ1,
        [l10n.localQuizA1, l10n.localQuizB1, l10n.localQuizC1],
        l10n.localQuizWhy1,
      ),
      (
        l10n.localQuizQ2,
        [l10n.localQuizB2, l10n.localQuizA2, l10n.localQuizC2],
        l10n.localQuizWhy2,
      ),
      (
        l10n.localQuizQ3,
        [l10n.localQuizB3, l10n.localQuizC3, l10n.localQuizA3],
        l10n.localQuizWhy3,
      ),
    ];
    return AiQuiz(
      id: 'quiz_${DateTime.now().microsecondsSinceEpoch}',
      subject: '${l10n.localStrategies} • $subject',
      difficulty: l10n.localMedium,
      questions: List.generate(
        count.clamp(1, 3),
        (i) => AiQuizQuestion(
          id: 'strategy_$i',
          question: questions[i].$1,
          options: questions[i].$2,
          correctIndex: i,
          explanation: questions[i].$3,
          hint: l10n.localPlanTip,
          difficulty: l10n.localMedium,
        ),
      ),
    );
  }

  AiNoteInsight extract(String content, String? title) {
    final points = content
        .split(RegExp(r'[\n.!?]'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(5)
        .toList();
    return AiNoteInsight(
      id: 'insight_${DateTime.now().microsecondsSinceEpoch}',
      title: title?.trim().isNotEmpty == true ? title!.trim() : l10n.localNote,
      summary: l10n.localNoteSummary,
      keyTakeaways: points,
      actionItems: [l10n.localNoteAction],
      keywords: const [],
      estimatedReadMinutes: (content.split(RegExp(r'\s+')).length / 200)
          .ceil()
          .clamp(1, 60),
    );
  }

  AiChatMessage prompt(String text) {
    final lower = text.toLowerCase();
    final id = 'message_${DateTime.now().microsecondsSinceEpoch}';
    if ([
      'anxious',
      'anxiety',
      'worried',
      'stress',
      'قلق',
      'توتر',
      'خوف',
    ].any(lower.contains)) {
      return AiChatMessage(
        id: id,
        sender: AiSender.assistant,
        content: l10n.localExamSupport,
        timestamp: DateTime.now(),
      );
    }
    if (['quiz', 'test me', 'اختبرني', 'كويز'].any(lower.contains)) {
      return AiChatMessage(
        id: id,
        sender: AiSender.assistant,
        content: l10n.localQuizReply,
        timestamp: DateTime.now(),
        type: AiMessageType.quiz,
        quiz: quiz(l10n.localSubject, l10n.localMedium, 3),
      );
    }
    if (['summar', 'extract', 'لخص', 'ملخص'].any(lower.contains)) {
      return AiChatMessage(
        id: id,
        sender: AiSender.assistant,
        content: l10n.localNoteReply,
        timestamp: DateTime.now(),
        type: AiMessageType.summary,
        noteInsight: extract(text, null),
      );
    }
    if (['plan', 'schedule', 'خطة', 'جدول'].any(lower.contains)) {
      final hours =
          int.tryParse(RegExp(r'\d+').firstMatch(text)?.group(0) ?? '') ?? 2;
      final result = plan(l10n.localSubject, hours);
      return AiChatMessage(
        id: id,
        sender: AiSender.assistant,
        content: l10n.localPlanReply(result.subject),
        timestamp: DateTime.now(),
        type: AiMessageType.studyPlan,
        studyPlan: result,
      );
    }
    return AiChatMessage(
      id: id,
      sender: AiSender.assistant,
      content: l10n.localWelcome,
      timestamp: DateTime.now(),
    );
  }
}
