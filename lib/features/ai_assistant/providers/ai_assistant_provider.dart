import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_assistant_models.dart';
import '../services/ai_assistant_service.dart';

class AiAssistantState {
  final List<AiChatMessage> messages;
  final bool isTyping;
  final String selectedCategory; // 'all', 'studyPlan', 'quiz', 'summary'

  const AiAssistantState({
    required this.messages,
    this.isTyping = false,
    this.selectedCategory = 'all',
  });

  AiAssistantState copyWith({
    List<AiChatMessage>? messages,
    bool? isTyping,
    String? selectedCategory,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final aiAssistantServiceProvider = Provider<AiAssistantService>((ref) {
  return AiAssistantService.instance;
});

final aiAssistantProvider =
    StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  final service = ref.watch(aiAssistantServiceProvider);
  return AiAssistantNotifier(service);
});

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final AiAssistantService _service;

  AiAssistantNotifier(this._service)
      : super(
          AiAssistantState(
            messages: [
              AiChatMessage(
                id: 'welcome_init',
                sender: AiSender.assistant,
                timestamp: DateTime.now(),
                type: AiMessageType.text,
                content: '''أهلاً بك يا بطل! أنا مساعدك الدراسي الذكي في StudyFlow 🧠✨

أنا هنا لأساعدك في رحلتك الدراسية بأحدث أساليب التعلم الفعّال:
• 📅 **تخطيط المذاكرة الذكي**: تقسيم المواد المعقدة إلى جلسات مركزة مع فترات راحة بومودورو.
• 📝 **بنك الاختبارات والكويز**: تدريب تفاعلي فوري بأسئلة اختيار من متعدد مع شرح الحل.
• 💡 **تلخيص الملاحظات والأفكار**: تحويل دفاتر وملاحظات دراستك لنقاط مراجعة سريعة.

جرّب اختيار أحد الاقتراحات السريعة أدناه أو اكتب لي أي سؤال مباشرة! 👇''',
              ),
            ],
          ),
        );

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> sendUserPrompt(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.user,
      content: query,
      timestamp: DateTime.now(),
      type: AiMessageType.text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // Realistic micro-delay for smooth AI conversation feel without freezing UI
    await Future.delayed(const Duration(milliseconds: 350));

    final reply = _service.handleUserPrompt(query, history: state.messages);

    state = state.copyWith(
      messages: [...state.messages, reply],
      isTyping: false,
    );
  }

  Future<void> requestStudyPlan({
    required String subject,
    required int hours,
  }) async {
    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.user,
      content: 'أريد خطة دراسية ذكية لمادة "$subject" مدتها $hours ساعات.',
      timestamp: DateTime.now(),
      type: AiMessageType.text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final plan = _service.generateStudyPlan(
      subject: subject,
      availableHours: hours,
    );

    final reply = AiChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.assistant,
      content: '✨ قمت ببرمجة خطة دراسية احترافية لمادة **${plan.subject}** موزعة على **${plan.availableHours} ساعات** مع توزيع الطاقة والتركيز.',
      timestamp: DateTime.now(),
      type: AiMessageType.studyPlan,
      studyPlan: plan,
    );

    state = state.copyWith(
      messages: [...state.messages, reply],
      isTyping: false,
    );
  }

  Future<void> requestQuiz({
    required String subject,
    String difficulty = 'متوسط',
    int count = 3,
  }) async {
    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.user,
      content: 'اختبرني في مادة "$subject" بمستوى $difficulty ($count أسئلة).',
      timestamp: DateTime.now(),
      type: AiMessageType.text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final quiz = _service.generateQuiz(
      subject: subject,
      difficulty: difficulty,
      count: count,
    );

    final reply = AiChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.assistant,
      content: '🎯 إليك كويز تجريبي لمادة **${quiz.subject}** ($difficulty). اختر الإجابة الأصح لتحصل على التصحيح الفوري:',
      timestamp: DateTime.now(),
      type: AiMessageType.quiz,
      quiz: quiz,
    );

    state = state.copyWith(
      messages: [...state.messages, reply],
      isTyping: false,
    );
  }

  Future<void> requestNoteSummary({
    required String content,
    String? title,
  }) async {
    final noteName = title ?? 'ملاحظة دراسية';
    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.user,
      content: 'لخص لي الملاحظة: "$noteName".',
      timestamp: DateTime.now(),
      type: AiMessageType.text,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future.delayed(const Duration(milliseconds: 300));

    final insight = _service.generateNoteInsights(
      content: content,
      title: title,
    );

    final reply = AiChatMessage(
      id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
      sender: AiSender.assistant,
      content: '💡 هذه أبرز مفاهيم ونقاط المراجعة السريعة المستخرجة من "$noteName":',
      timestamp: DateTime.now(),
      type: AiMessageType.summary,
      noteInsight: insight,
    );

    state = state.copyWith(
      messages: [...state.messages, reply],
      isTyping: false,
    );
  }

  void answerQuizQuestion({
    required String messageId,
    required int questionIndex,
    required int selectedOptionIndex,
  }) {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id == messageId && msg.quiz != null) {
        final currentQuiz = msg.quiz!;
        final updatedAnswers = Map<int, int>.from(currentQuiz.userAnswers)
          ..[questionIndex] = selectedOptionIndex;
        final isAllAnswered =
            updatedAnswers.length == currentQuiz.questions.length;
        final updatedQuiz = currentQuiz.copyWith(
          userAnswers: updatedAnswers,
          isCompleted: isAllAnswered,
        );
        return msg.copyWith(quiz: updatedQuiz);
      }
      return msg;
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  void clearChat() {
    state = AiAssistantState(
      messages: [
        AiChatMessage(
          id: 'welcome_reset',
          sender: AiSender.assistant,
          timestamp: DateTime.now(),
          type: AiMessageType.text,
          content: 'تم بدء محادثة جديدة! كيف يمكنني مساعدتك في دراستك اليوم؟ 🎓',
        ),
      ],
      selectedCategory: 'all',
    );
  }
}
