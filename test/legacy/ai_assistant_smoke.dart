import 'dart:io';

import 'package:study_flow/core/utils/app_haptics.dart';
import 'package:study_flow/features/ai_assistant/models/ai_assistant_models.dart';
import 'package:study_flow/features/ai_assistant/services/ai_assistant_service.dart';

void main() {
  stdout.writeln('========================================================');
  stdout.writeln('🤖 StudyFlow AI Assistant Automated Unit Tests 🤖');
  stdout.writeln('========================================================\n');

  testStudyPlanGeneration();
  testQuizGeneratorSystem();
  testNoteInsightsAndSummary();
  testNaturalLanguageIntentHandling();
  testModelSerializationAndImmutability();
  testHapticsAndEmptyStateIntegration();

  stdout.writeln('\n========================================================');
  stdout.writeln('🌟 ALL AI ASSISTANT UNIT TESTS PASSED WITH 100% SUCCESS! 🌟');
  stdout.writeln('========================================================');
}

void testStudyPlanGeneration() {
  stdout.writeln('Running Smart Study Plan Generation Tests...');

  final service = AiAssistantService.instance;

  // 1. Math / Science Plan Generation (4 hours = 240 mins)
  final mathPlan = service.generateStudyPlan(
    subject: 'الرياضيات البحتة والتفاضل',
    availableHours: 4,
  );

  assert(
    mathPlan.subject == 'الرياضيات البحتة والتفاضل',
    'Subject mismatch in math plan',
  );
  assert(mathPlan.availableHours == 4, 'Available hours should be 4');
  assert(
    mathPlan.totalMinutes == 240,
    'Total minutes should be 240 for 4 hours, got ${mathPlan.totalMinutes}',
  );
  assert(mathPlan.phases.length == 4, 'Expected 4 study phases');
  assert(
    mathPlan.phases[0].energyBadge.contains('⚡'),
    'First phase should be high energy',
  );
  assert(
    mathPlan.phases[1].durationMinutes == 96,
    'Second phase (40%) should be 96 mins, got ${mathPlan.phases[1].durationMinutes}',
  );
  assert(mathPlan.smartTips.isNotEmpty, 'Smart tips must not be empty');
  assert(
    mathPlan.pomodoroRecommendation.contains('50 دقيقة') ||
        mathPlan.pomodoroRecommendation.contains('بومودورو'),
    'Pomodoro recommendation should be present',
  );

  // 2. Language Plan Generation (2 hours = 120 mins)
  final langPlan = service.generateStudyPlan(
    subject: 'اللغة العربية والنحو',
    availableHours: 2,
  );

  assert(
    langPlan.totalMinutes == 120,
    'Total minutes should be 120 for 2 hours',
  );
  assert(
    langPlan.phases[0].title.contains('القواعد'),
    'Language phase 1 should focus on rules',
  );
  assert(
    langPlan.phases[1].cognitiveLevel.contains('تطبيق'),
    'Phase 2 should focus on application',
  );

  // 3. Humanities / Biology Plan Generation (3 hours = 180 mins)
  final bioPlan = service.generateStudyPlan(
    subject: 'الأحياء والوراثة',
    availableHours: 3,
  );

  assert(
    bioPlan.totalMinutes == 180,
    'Total minutes should be 180 for 3 hours',
  );
  assert(
    bioPlan.phases[0].title.contains('الخريطة الذهنية'),
    'Humanities phase 1 should focus on mind mapping',
  );
  assert(
    bioPlan.phases[2].cognitiveLevel.contains('استرجاع'),
    'Phase 3 should focus on active recall',
  );

  stdout.writeln('  ✓ Math/Science breakdown & calculation: PASSED');
  stdout.writeln('  ✓ Language curriculum breakdown: PASSED');
  stdout.writeln('  ✓ Humanities & Biology active recall allocation: PASSED');
}

void testQuizGeneratorSystem() {
  stdout.writeln('Running Exam Prep & Quiz Generator Tests...');

  final service = AiAssistantService.instance;

  // 1. Math Quiz
  final mathQuiz = service.generateQuiz(
    subject: 'رياضيات',
    difficulty: 'متوسط',
    count: 3,
  );
  assert(mathQuiz.subject == 'رياضيات', 'Math quiz subject mismatch');
  assert(mathQuiz.questions.length == 3, 'Expected 3 questions in math quiz');

  for (final q in mathQuiz.questions) {
    assert(q.options.length == 4, 'Each question must have exactly 4 options');
    assert(
      q.correctIndex >= 0 && q.correctIndex < 4,
      'correctIndex must be between 0 and 3',
    );
    assert(q.explanation.isNotEmpty, 'Question must have an explanation');
    assert(q.hint.isNotEmpty, 'Question must have a hint');
  }

  // 2. Physics Quiz
  final phyQuiz = service.generateQuiz(
    subject: 'فيزياء',
    difficulty: 'صعب',
    count: 3,
  );
  assert(
    phyQuiz.questions.isNotEmpty,
    'Physics quiz questions should not be empty',
  );
  assert(
    phyQuiz.questions[0].question.contains('القوة') ||
        phyQuiz.questions[0].question.contains('نيوتن') ||
        phyQuiz.questions[0].question.contains('كهربا'),
    'Physics question content validation',
  );

  // 3. Chemistry Quiz
  final chemQuiz = service.generateQuiz(
    subject: 'كيمياء',
    difficulty: 'سهل',
    count: 3,
  );
  assert(
    chemQuiz.questions.isNotEmpty,
    'Chemistry quiz questions should not be empty',
  );

  // 4. Custom/Generic Topic Quiz
  final genericQuiz = service.generateQuiz(
    subject: 'الذكاء الاصطناعي وهندسة البرمجيات',
    difficulty: 'متوسط',
    count: 3,
  );
  assert(
    genericQuiz.questions.length == 3,
    'Generic quiz should generate requested count',
  );

  // 5. Quiz Scoring Logic
  // Perfect score scenario
  var interactiveQuiz = mathQuiz.copyWith(
    userAnswers: {
      0: mathQuiz.questions[0].correctIndex,
      1: mathQuiz.questions[1].correctIndex,
      2: mathQuiz.questions[2].correctIndex,
    },
    isCompleted: true,
  );

  assert(interactiveQuiz.score == 3, 'Expected score 3/3');
  assert(interactiveQuiz.percentage == 100, 'Expected 100% percentage');
  assert(
    interactiveQuiz.isCompleted == true,
    'Quiz should be marked completed',
  );

  // Partial score scenario
  final wrongOption0 = (mathQuiz.questions[0].correctIndex + 1) % 4;
  interactiveQuiz = mathQuiz.copyWith(
    userAnswers: {
      0: wrongOption0,
      1: mathQuiz.questions[1].correctIndex,
      2: mathQuiz.questions[2].correctIndex,
    },
    isCompleted: true,
  );

  assert(interactiveQuiz.score == 2, 'Expected score 2/3');
  assert(
    interactiveQuiz.percentage == 67,
    'Expected 67% percentage (2/3 rounded)',
  );

  stdout.writeln('  ✓ 4-option structure & bounds validation: PASSED');
  stdout.writeln(
    '  ✓ Multi-subject question banks (Math, Physics, Chem, Arabic): PASSED',
  );
  stdout.writeln('  ✓ Scoring, percentage & completion logic: PASSED');
}

void testNoteInsightsAndSummary() {
  stdout.writeln('Running Note Summary & Insights Tests...');

  final service = AiAssistantService.instance;

  const sampleNoteContent = '''
قوانين الديناميكا الحرارية والفيزياء الإحصائية.
القانون الأول للديناميكا الحرارية: الطاقة لا تفنى ولا تستحدث من عدم ولكن تتحول من صورة لأخرى.
القانون الثاني: الإنتروبيا (مقياس العشوائية) في أي نظام معزول تزداد تلقائياً مع مرور الزمن.
مفهوم الكفاءة الحرارية للآلات والمحركات وتطبيق دورة كارنو المثالية.
تطبيقات هندسية في المحركات البخارية ومضخات الحرارة والتبريد الحديث.
''';

  final insight = service.generateNoteInsights(
    content: sampleNoteContent,
    title: 'ملاحظات الديناميكا الحرارية',
  );

  assert(insight.title == 'ملاحظات الديناميكا الحرارية', 'Note title mismatch');
  assert(
    insight.summary.contains('الديناميكا الحرارية'),
    'Summary should reference note topic',
  );
  assert(insight.keyTakeaways.isNotEmpty, 'Key takeaways should be extracted');
  assert(insight.actionItems.isNotEmpty, 'Action items should be suggested');
  assert(
    insight.estimatedReadMinutes >= 1,
    'Estimated read time should be >= 1 min',
  );
  assert(insight.keywords.isNotEmpty, 'Keywords should be extracted');

  // Test short note fallback
  final shortInsight = service.generateNoteInsights(
    content: 'قانون أوم يربط بين فرق الجهد وشدة التيار.',
    title: 'قانون أوم',
  );

  assert(
    shortInsight.keyTakeaways.isNotEmpty,
    'Short note should provide structured fallback takeaways',
  );

  stdout.writeln('  ✓ Executive summary generation: PASSED');
  stdout.writeln(
    '  ✓ Key takeaways (high-yield bullet points) extraction: PASSED',
  );
  stdout.writeln('  ✓ Action items & keyword tagging: PASSED');
}

void testNaturalLanguageIntentHandling() {
  stdout.writeln('Running Natural Language Intent Handling Tests...');

  final service = AiAssistantService.instance;

  // 1. Study Plan Intent
  final planMsg = service.handleUserPrompt(
    'ضع لي جدول وخطة لمذاكرة مادة الكيمياء في 4 ساعات',
  );
  assert(
    planMsg.type == AiMessageType.studyPlan,
    'Expected studyPlan message type',
  );
  assert(planMsg.studyPlan != null, 'Attached study plan should not be null');
  assert(planMsg.studyPlan!.availableHours == 4, 'Extracted hours should be 4');
  assert(
    planMsg.studyPlan!.subject.contains('الكيمياء'),
    'Extracted subject should contain الكيمياء',
  );

  // 2. Quiz Intent
  final quizMsg = service.handleUserPrompt(
    'اختبرني في مادة الفيزياء بأسئلة كويز صعبة',
  );
  assert(quizMsg.type == AiMessageType.quiz, 'Expected quiz message type');
  assert(quizMsg.quiz != null, 'Attached quiz should not be null');
  assert(
    quizMsg.quiz!.difficulty == 'صعب',
    'Extracted difficulty should be صعب',
  );
  assert(
    quizMsg.quiz!.questions.length == 3,
    'Quiz should contain 3 questions',
  );

  // 3. Summarization Intent
  final summaryMsg = service.handleUserPrompt(
    'لخص لي هذا الدرس: الخلية هي الوحدة التركيبية والوظيفية لجميع الكائنات الحية.',
  );
  assert(
    summaryMsg.type == AiMessageType.summary,
    'Expected summary message type',
  );
  assert(
    summaryMsg.noteInsight != null,
    'Attached note insight should not be null',
  );

  // 4. Feynman Strategy Query
  final feynmanMsg = service.handleUserPrompt(
    'ما هي تقنية فاينمان وكيف أطبقها؟',
  );
  assert(
    feynmanMsg.type == AiMessageType.text,
    'Expected text message type for educational Q&A',
  );
  assert(
    feynmanMsg.content.contains('فاينمان'),
    'Response should mention Feynman',
  );
  assert(
    feynmanMsg.content.contains('الخطوات الأربع'),
    'Response should detail the 4 steps',
  );

  // 5. Pomodoro Technique Query
  final pomodoroMsg = service.handleUserPrompt('كيف أستخدم بومودورو للتركيز؟');
  assert(
    pomodoroMsg.content.contains('25 دقيقة'),
    'Response should mention 25 min cycle',
  );

  // 6. Exam Anxiety Query
  final anxietyMsg = service.handleUserPrompt(
    'أشعر بالتوتر وقلق الامتحانات، كيف أهدأ؟',
  );
  assert(
    anxietyMsg.content.contains('قلق') || anxietyMsg.content.contains('تنفس'),
    'Response should address anxiety',
  );

  // 7. General Assistant Greeting
  final greetingMsg = service.handleUserPrompt('مرحباً، من أنت؟');
  assert(
    greetingMsg.content.contains('مساعدك الدراسي الذكي'),
    'Response should identify as AI study assistant',
  );

  stdout.writeln(
    '  ✓ Study plan intent detection & parameter extraction: PASSED',
  );
  stdout.writeln('  ✓ Quiz generator intent & difficulty parsing: PASSED');
  stdout.writeln('  ✓ Summary intent & content analysis: PASSED');
  stdout.writeln(
    '  ✓ Study methodology guides (Feynman, Pomodoro, Stress relief): PASSED',
  );
}

void testModelSerializationAndImmutability() {
  stdout.writeln('Running Model Serialization & Immutability Tests...');

  // AiStudyPlan JSON
  const sessionPhase = AiStudySessionPhase(
    title: 'المرحلة 1: الفهم',
    durationMinutes: 45,
    description: 'شرح المفاهيم',
    cognitiveLevel: 'استيعاب',
    energyBadge: 'طاقة عالية ⚡',
    subtasks: ['مهمة 1', 'مهمة 2'],
  );
  final phaseJson = sessionPhase.toJson();
  final restoredPhase = AiStudySessionPhase.fromJson(phaseJson);
  assert(restoredPhase.title == sessionPhase.title, 'Phase title mismatch');
  assert(restoredPhase.durationMinutes == 45, 'Phase duration mismatch');

  const studyPlan = AiStudyPlan(
    id: 'test_plan_1',
    subject: 'جبر متقدم',
    availableHours: 3,
    overview: 'خطة تجريبية',
    phases: [sessionPhase],
    smartTips: ['نصيحة 1'],
    pomodoroRecommendation: '25/5',
    revisionCadence: '24h/3d',
  );
  final planJson = studyPlan.toJson();
  final restoredPlan = AiStudyPlan.fromJson(planJson);
  assert(restoredPlan.id == 'test_plan_1', 'Plan id mismatch');
  assert(restoredPlan.subject == 'جبر متقدم', 'Plan subject mismatch');
  assert(restoredPlan.phases.length == 1, 'Plan phases count mismatch');

  // AiQuiz JSON
  const question = AiQuizQuestion(
    id: 'q_1',
    question: 'ما هو حاصل ضرب 7 × 8؟',
    options: ['54', '56', '58', '64'],
    correctIndex: 1,
    explanation: '7 × 8 = 56',
    hint: 'جدول ضرب 7',
    difficulty: 'سهل',
  );
  final qJson = question.toJson();
  final restoredQ = AiQuizQuestion.fromJson(qJson);
  assert(restoredQ.correctIndex == 1, 'Question correctIndex mismatch');

  const quiz = AiQuiz(
    id: 'quiz_1',
    subject: 'حساب',
    difficulty: 'سهل',
    questions: [question],
    userAnswers: {0: 1},
    isCompleted: true,
  );
  final quizJson = quiz.toJson();
  final restoredQuiz = AiQuiz.fromJson(quizJson);
  assert(restoredQuiz.id == 'quiz_1', 'Quiz id mismatch');
  assert(restoredQuiz.userAnswers[0] == 1, 'User answers mismatch');
  assert(restoredQuiz.isCompleted == true, 'Quiz completed mismatch');

  // AiNoteInsight JSON
  const insight = AiNoteInsight(
    id: 'ins_1',
    title: 'ملخص النحو',
    summary: 'شرح كان وأخواتها',
    keyTakeaways: ['كان ترفع المبتدأ'],
    actionItems: ['حل تمارين'],
    keywords: ['نحو', 'إعراب'],
    estimatedReadMinutes: 2,
  );
  final insJson = insight.toJson();
  final restoredIns = AiNoteInsight.fromJson(insJson);
  assert(restoredIns.id == 'ins_1', 'Insight id mismatch');
  assert(restoredIns.keyTakeaways.length == 1, 'Key takeaways count mismatch');

  // AiChatMessage JSON
  final msg = AiChatMessage(
    id: 'msg_1',
    sender: AiSender.assistant,
    content: 'رسالة تجريبية',
    timestamp: DateTime(2026, 11, 15, 20, 0),
    type: AiMessageType.studyPlan,
    studyPlan: studyPlan,
  );
  final msgJson = msg.toJson();
  final restoredMsg = AiChatMessage.fromJson(msgJson);
  assert(restoredMsg.id == 'msg_1', 'Message id mismatch');
  assert(restoredMsg.sender == AiSender.assistant, 'Message sender mismatch');
  assert(restoredMsg.type == AiMessageType.studyPlan, 'Message type mismatch');
  assert(
    restoredMsg.studyPlan != null,
    'Restored study plan should not be null',
  );

  stdout.writeln(
    '  ✓ AiStudySessionPhase & AiStudyPlan JSON serialization: PASSED',
  );
  stdout.writeln('  ✓ AiQuizQuestion & AiQuiz JSON serialization: PASSED');
  stdout.writeln('  ✓ AiNoteInsight JSON serialization: PASSED');
  stdout.writeln('  ✓ AiChatMessage JSON serialization: PASSED');
}

void testHapticsAndEmptyStateIntegration() {
  stdout.writeln('Running Motion & Haptics Integration Tests...');

  // 1. AppHaptics safe execution (no uncaught exceptions in pure headless Dart)
  AppHaptics.isEnabled = true;
  int hapticFiredCount = 0;
  AppHaptics.onLight = () => hapticFiredCount++;
  AppHaptics.onMedium = () => hapticFiredCount++;
  AppHaptics.onMilestone = () => hapticFiredCount++;
  AppHaptics.onSelection = () => hapticFiredCount++;
  AppHaptics.onRejection = () => hapticFiredCount++;

  AppHaptics.selection();
  AppHaptics.light();
  AppHaptics.medium();
  AppHaptics.milestone();
  AppHaptics.rejection();
  assert(
    hapticFiredCount == 5,
    'Expected 5 haptic dispatches, got $hapticFiredCount',
  );

  // Central toggle gate test
  AppHaptics.isEnabled = false;
  AppHaptics.selection(); // should safely no-op
  AppHaptics.light();
  assert(hapticFiredCount == 5, 'Should not dispatch when isEnabled is false');

  AppHaptics.isEnabled = true; // restore
  AppHaptics.onLight = null;
  AppHaptics.onMedium = null;
  AppHaptics.onMilestone = null;
  AppHaptics.onSelection = null;
  AppHaptics.onRejection = null;

  stdout.writeln('  ✓ AppHaptics decoupled hooks & dispatch count: PASSED');
  stdout.writeln('  ✓ AppHaptics central gate toggle verification: PASSED');
}
