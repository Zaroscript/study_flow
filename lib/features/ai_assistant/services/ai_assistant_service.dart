import '../models/ai_assistant_models.dart';

class AiAssistantService {
  AiAssistantService._();

  static final AiAssistantService instance = AiAssistantService._();

  /// Generates a comprehensive, pedagogical study plan for a subject
  AiStudyPlan generateStudyPlan({
    required String subject,
    required int availableHours,
    String level = 'متوسط',
  }) {
    final cleanSubject = subject.trim().isEmpty ? 'المادة الدراسية' : subject.trim();
    final totalMinutes = (availableHours <= 0 ? 2 : availableHours) * 60;
    final planId = 'plan_${DateTime.now().millisecondsSinceEpoch}';

    // Calculate time allocations
    final phase1Minutes = (totalMinutes * 0.25).round();
    final phase2Minutes = (totalMinutes * 0.40).round();
    final phase3Minutes = (totalMinutes * 0.20).round();
    final phase4Minutes = totalMinutes - (phase1Minutes + phase2Minutes + phase3Minutes);

    final isMathOrScience = _matchesCategory(cleanSubject, ['رياضيات', 'حساب', 'جبر', 'تفاضل', 'تكامل', 'فيزياء', 'كيمياء', 'ميكانيكا', 'هندسة']);
    final isLanguage = _matchesCategory(cleanSubject, ['عربي', 'نحو', 'بلاغة', 'لغة', 'إنجليزي', 'english', 'فرنسي', 'أدب']);
    final isMemorizationOrHistory = _matchesCategory(cleanSubject, ['تاريخ', 'جغرافيا', 'أحياء', 'علوم', 'دراسات', 'فلسفة', 'اجتماع']);

    List<AiStudySessionPhase> phases;
    List<String> tips;
    String pomodoroRec;

    if (isMathOrScience) {
      phases = [
        AiStudySessionPhase(
          title: 'المرحلة 1: تفكيك القوانين والمفاهيم النظرية',
          durationMinutes: phase1Minutes,
          description: 'فهم النظريات وتدوين ورقة القوانين الخاصة بـ $cleanSubject بدون حفظ أعمى.',
          cognitiveLevel: 'استيعاب مفاهيمي',
          energyBadge: 'طاقة عالية ⚡',
          subtasks: [
            'كتابة القوانين الأساسية في ورقة ملخص جانبية',
            'فهم شروط تطبيق كل قانون ووحدات القياس',
            'قراءة مسألة محلولة نموذجية لكل فكرة رئيسية',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 2: التدريب المركز وحل المسائل المتدرجة',
          durationMinutes: phase2Minutes,
          description: 'حل تمارين مباشرة أولاً ثم الانتقال إلى مسائل ذات أفكار مركبة وامتحانات سابقة.',
          cognitiveLevel: 'تطبيق عملي عميق',
          energyBadge: 'تركيز استثنائي 🎯',
          subtasks: [
            'حل 3-5 مسائل متوسطة المستوى بشكل منفرد',
            'مواجهة مسألتين من أسئلة الامتحانات الصعبة',
            'تدوين الملاحظات حول الأخطاء الحسابية لتفاديها',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 3: تقنية فاينمان والشرح الذاتي',
          durationMinutes: phase3Minutes,
          description: 'اشرح أصعب مسألة أو قانون بصوت عالٍ كأنك تشرحه لطالب مبتدئ لكشف أي فجوة في الفهم.',
          cognitiveLevel: 'استرجاع نشط (Active Recall)',
          energyBadge: 'تثبيت ذهني 🧠',
          subtasks: [
            'إعادة استنتاج القانون بدون النظر للورقة',
            'تحديد النقاط التي ترددت فيها ومراجعتها فوراً',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 4: محاكاة الامتحان واختبار السرعة',
          durationMinutes: phase4Minutes,
          description: 'حل مسألتين تحت ضغط الوقت والمراجعة السريعة على القوانين الأساسية.',
          cognitiveLevel: 'تقييم ذاتي',
          energyBadge: 'جاهزية الاختبار ⏱️',
          subtasks: [
            'ضبط مؤقت وحل مسألة امتحان في وقت قياسي',
            'التأكد من حفظ الخطوات المنطقية وطريقة كتابة الإجابة النموذجية',
          ],
        ),
      ];
      tips = [
        'لا تقرأ الحل الجاهز بعينيك أبداً؛ أمسك القلم واكتب بيدك خطوة بخطوة.',
        'احتفظ بـ "سجل الأخطاء": اكتب فيه كل فكرة خدعتك لتراجعها ليلة الامتحان.',
        'ركز على الوحدات والتحويلات الحسابية، فهي تفقد درجات سهلة.',
      ];
      pomodoroRec = availableHours >= 3
          ? 'استخدم دورات (50 دقيقة تركيز + 10 دقائق استراحة) للغوص العميق في حل المسائل.'
          : 'استخدم دورات بومودورو التقليدية (25 دقيقة تركيز + 5 دقائق استراحة).';
    } else if (isLanguage) {
      phases = [
        AiStudySessionPhase(
          title: 'المرحلة 1: استيعاب القواعد والمفردات المركزية',
          durationMinutes: phase1Minutes,
          description: 'مراجعة القواعد النحوية أو اللغوية والمفردات مع وضع كل قاعدة في سياق جمل حية.',
          cognitiveLevel: 'فهم لغوي ونحوي',
          energyBadge: 'طاقة عالية ⚡',
          subtasks: [
            'قراءة أمثلة كتاب الوزارة أو المنهج المعتمد',
            'استخراج الكلمات المفتاحية وأدوات الربط',
            'صياغة جمل خاصة بك لكل قاعدة',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 2: التطبيق والتحليل النصي والإعراب',
          durationMinutes: phase2Minutes,
          description: 'حل قطع نحو أو تدريبات لغوية كاملة واستخراج الشواهد البلاغية والأسئلة المقالية.',
          cognitiveLevel: 'تطبيق وتحليل',
          energyBadge: 'تركيز عميق 🎯',
          subtasks: [
            'إعراب 5 جمل نموذجية أو حل تمرينين في القواعد',
            'حل أسئلة الفهم القرائي والاستنتاج',
            'مراجعة شواهد النصوص الأدبية أو التعبيرات الاصطلاحية',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 3: بطاقات الاستذكار السريع والتسميع',
          durationMinutes: phase3Minutes,
          description: 'تسميع الكلمات والقواعد والمحسنات البلاغية بدون الاستعانة بالكتاب.',
          cognitiveLevel: 'استرجاع نشط',
          energyBadge: 'تثبيت لغوي 📖',
          subtasks: [
            'اختبار ذاتي على معاني الكلمات ومضاداتها',
            'إعادة كتابة القواعد الأساسية في ملخص من صفحة واحدة',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 4: تقييم ختامي وتطبيق سريع',
          durationMinutes: phase4Minutes,
          description: 'حل نموذج اختبار تجريبي مصغر للتأكد من شمول كافة جوانب الدرس.',
          cognitiveLevel: 'تقييم شامل',
          energyBadge: 'استقرار وثقة ✨',
          subtasks: [
            'تصحيح الأخطاء من نموذج الإجابة',
            'قراءة الملخص النهائي قبل إنهاء الجلسة',
          ],
        ),
      ];
      tips = [
        'في اللغات، الممارسة اليومية القصيرة أفضل من الحفظ المتواصل لساعات طويلة.',
        'اقرأ النصوص بصوت مسموع لتقوية الذاكرة السمعية والربط العصبي.',
        'اصنع بطاقات كلمات (Flashcards) للألفاظ الصعبة أو القواعد الشاذة.',
      ];
      pomodoroRec = 'نوصي بـ (25 دقيقة مذاكرة + 5 دقائق استراحة) للحفاظ على نشاط الذاكرة اللفظية.';
    } else {
      // Humanities / Biology / General
      phases = [
        AiStudySessionPhase(
          title: 'المرحلة 1: القراءة الاستكشافية ورسم الخريطة الذهنية',
          durationMinutes: phase1Minutes,
          description: 'مسح سريع للعناوين الرئيسية والفرعية ورسم هيكل عام لموضوعات $cleanSubject.',
          cognitiveLevel: 'هيكلة وإدراك شامل',
          energyBadge: 'طاقة أولية ⚡',
          subtasks: [
            'تصفح العناوين والرسومات التوضيحية',
            'رسم مخطط شجري يربط عناصر الدرس ببعضها',
            'تحديد الأسئلة التي يجب الإجابة عنها أثناء المذاكرة',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 2: المذاكرة المعمقة والربط السببي',
          durationMinutes: phase2Minutes,
          description: 'قراءة متأنية لكل قسم مع فهم "لماذا" و"كيف"، وتدوين الهوامش والكلمات الدالة.',
          cognitiveLevel: 'فهم تحليلي دقيق',
          energyBadge: 'تركيز مكثف 🎯',
          subtasks: [
            'تحويل الفقرات الطويلة إلى نقاط مرقمة',
            'ربط التواريخ والأحداث أو العمليات الحيوية بأسباب ونتائج',
            'استخدام الألوان للتمييز بين المفاهيم والمقارنات',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 3: الاسترجاع الحر (Active Recall) وإخفاء النص',
          durationMinutes: phase3Minutes,
          description: 'أغلق الكتاب واكتب كل ما تتذكره عن الدرس على ورقة بيضاء (Brain Dump).',
          cognitiveLevel: 'استرجاع عصبي فائق',
          energyBadge: 'تثبيت عميق 🧠',
          subtasks: [
            'مقارنة ما كتبته بالكتاب ومعرفة النقاط المنسية',
            'التركيز على الفروقات الدقيقة بين المفاهيم المتشابهة',
          ],
        ),
        AiStudySessionPhase(
          title: 'المرحلة 4: بنك الأسئلة والأسئلة المتوقعة',
          durationMinutes: phase4Minutes,
          description: 'حل أسئلة السنوات السابقة وأسئلة نهاية الفصل لمطابقة إجاباتك مع المعايير.',
          cognitiveLevel: 'تطبيق امتحاني',
          energyBadge: 'مراجعة ختامية 🌟',
          subtasks: [
            'حل 10 أسئلة موضوعية (اختيار متعدد)',
            'صياغة إجابة نموذجية لسؤال مقالي متكرر',
          ],
        ),
      ];
      tips = [
        'اربط المعلومات بقصص أو اختصارات ذهنية (Mnemonics) لتسهيل تذكر القوائم الطويلة.',
        'الاسترجاع النشط يرفع نسبة التذكر بنسبة تزيد عن 80% مقارنة بإعادة القراءة السلبية.',
        'راجع الخريطة الذهنية بعد 24 ساعة لكسر منحنى النسيان.',
      ];
      pomodoroRec = 'جلسات 30 دقيقة تركيز + 5 دقائق راحة مع شرب كوب من الماء لإنعاش الدماغ.';
    }

    return AiStudyPlan(
      id: planId,
      subject: cleanSubject,
      availableHours: availableHours,
      overview: 'خطة مدروسة مصممة خصيصاً لمادة "$cleanSubject" موزعة على $availableHours ساعات بأسلوب التكرار المتباعد والتطبيق العملي لضمان أعلى درجات الاستيعاب والتركيز.',
      phases: phases,
      smartTips: tips,
      pomodoroRecommendation: pomodoroRec,
      revisionCadence: 'جدول المراجعة الموصى به: مراجعة سريعة (15 دقيقة) بعد 24 ساعة، ثم مراجعة شاملة بعد 3 أيام، ثم حل اختبار تجريبي بعد أسبوع.',
    );
  }

  /// Generates interactive quiz questions for a subject & difficulty
  AiQuiz generateQuiz({
    required String subject,
    String difficulty = 'متوسط',
    int count = 3,
  }) {
    final cleanSubject = subject.trim().isEmpty ? 'عام' : subject.trim();
    final quizId = 'quiz_${DateTime.now().millisecondsSinceEpoch}';

    final questions = _buildQuizQuestions(cleanSubject, difficulty, count);

    return AiQuiz(
      id: quizId,
      subject: cleanSubject,
      difficulty: difficulty,
      questions: questions,
    );
  }

  /// Extracts key summaries and high-yield insights from study notes
  AiNoteInsight generateNoteInsights({
    required String content,
    String? title,
  }) {
    final noteTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : 'ملاحظة دراسية';
    final insightId = 'insight_${DateTime.now().millisecondsSinceEpoch}';

    final lines = content
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final wordCount = content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    final estimatedReadTime = (wordCount / 60).ceil().clamp(1, 15);

    // Extract bullet points
    List<String> keyTakeaways = [];
    List<String> actionItems = [];
    List<String> keywords = [];

    if (lines.length <= 2) {
      keyTakeaways = [
        'المفهوم الجوهري: ${lines.isNotEmpty ? lines.first : "محتوى الملاحظة"}',
        'الربط المنطقي: يُنصح بالتوسع في أمثلة عملية تدعم هذا المفهوم.',
        'نقطة مراجعة: ركّز على صياغة هذا المحتوى بأسلوبك الشخصي لترسيخه.',
      ];
      actionItems = [
        'إضافة مثال تطبيقي أو مسألة عملية لتوضيح الفكرة.',
        'مراجعة هذه الفكرة بعد 48 ساعة لتثبيتها في الذاكرة طويلة الأجل.',
      ];
      keywords = ['مراجعة سريعة', 'فهم مفاهيمي', 'تركيز'];
    } else {
      // Meaningful extraction
      for (final line in lines) {
        final clean = line.replaceAll(RegExp(r'^[-*•\d\.)\s]+'), '');
        if (clean.length > 8 && keyTakeaways.length < 5) {
          keyTakeaways.add(clean);
        }
      }

      actionItems = [
        'حل 3 تمارين تطبيقية مستوحاة من هذه النقاط الرئيسية.',
        'إعداد بطاقة استرجاع سريع (Flashcard) لأهم المصطلحات الواردة.',
        'مقارنة هذه الملاحظات مع أسئلة امتحانات السنوات السابقة.',
      ];

      keywords = _extractKeywords(content);
    }

    final summary = 'تحتوي هذه الملاحظة على حوالي $wordCount كلمة تغطي مفاهيم رئيسية في "$noteTitle". ركزت النقاط المستخلصة على الأفكار المحورية التي يمكن الاستناد إليها في المراجعة المركزة قبل الاختبارات.';

    return AiNoteInsight(
      id: insightId,
      title: noteTitle,
      summary: summary,
      keyTakeaways: keyTakeaways,
      actionItems: actionItems,
      keywords: keywords,
      estimatedReadMinutes: estimatedReadTime,
    );
  }

  /// Processes natural language prompt and returns contextual conversational reply with optional rich attachments
  AiChatMessage handleUserPrompt(
    String userPrompt, {
    List<AiChatMessage>? history,
  }) {
    final text = userPrompt.trim();
    final lower = text.toLowerCase();
    final msgId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Study Plan Intent
    if (lower.contains('خطة') ||
        lower.contains('جدول') ||
        lower.contains('أذاكر') ||
        lower.contains('تنظيم وقت') ||
        lower.contains('ساعات') ||
        lower.contains('مذاكرة')) {
      final hours = _extractHours(text);
      final subject = _extractSubjectFromPlanPrompt(text);
      final plan = generateStudyPlan(subject: subject, availableHours: hours);

      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.studyPlan,
        studyPlan: plan,
        content: '✨ قمت بإعداد **خطة دراسية ذكية وشاملة** لمادة **${plan.subject}** موزعة على **${plan.availableHours} ساعات** بتقنيات المذاكرة المتقدمة وتقسيم مراحل التركيز.\n\nتفضل بالاطلاع على تفاصيل الخطة أدناه ويمكنك تعديلها في أي وقت!',
      );
    }

    // 2. Quiz / Exam Prep Intent
    if (lower.contains('اختبرني') ||
        lower.contains('كويز') ||
        lower.contains('امتحان') ||
        lower.contains('أسئلة') ||
        lower.contains('سؤال') ||
        lower.contains('اختبار')) {
      final subject = _extractSubjectFromQuizPrompt(text);
      final difficulty = lower.contains('صعب')
          ? 'صعب'
          : (lower.contains('سهل') ? 'سهل' : 'متوسط');
      final quiz = generateQuiz(subject: subject, difficulty: difficulty, count: 3);

      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.quiz,
        quiz: quiz,
        content: '🎯 إليك **اختبار تدريبي سريع** لمادة **${quiz.subject}** بمستوى **$difficulty**.\n\nاختر الإجابة التي تراها صحيحة لكل سؤال لتحصل على التقييم الفوري مع التفسير العلمي للشرح:',
      );
    }

    // 3. Summarization & Note Insights Intent
    if (lower.contains('لخص') ||
        lower.contains('تلخيص') ||
        lower.contains('ملخص') ||
        lower.contains('أهم النقاط') ||
        lower.contains('استخرج') ||
        lower.contains('أفكار')) {
      final insight = generateNoteInsights(
        content: text,
        title: 'استخلاص فوري للملاحظات',
      );

      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.summary,
        noteInsight: insight,
        content: '💡 قمت بتحليل النص واستخراج **أهم الأفكار ونقاط المراجعة السريعة** لمساعدتك في استذكار المحتوى في أقل وقت ممكن:',
      );
    }

    // 4. Study Techniques / Feynman / Pomodoro
    if (lower.contains('فاينمان') || lower.contains('feynman')) {
      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.text,
        content: '''🧠 **تقنية فاينمان للتعلم الفائق (Feynman Technique):**
تعتمد على مبدأ: *"إذا لم تستطع شرح الشيء ببساطة، فأنت لم تفهمه بشكل كافٍ"*.

**الخطوات الأربع العملية:**
1. **اختر المفهوم:** اكتب اسم الدرس أو المصطلح الصعب في أعلى صفحة بيضاء.
2. **اشرحه لطفل عمره 10 سنوات:** استخدم كلمات بسيطة جداً، وتجنب المصطلحات المعقدة، واعتمد على التشبيهات اليومية.
3. **حدد مواطن التعثر (الفجوات):** عندما تتوقف وتجد نفسك غير قادر على الشرح السلس، ارجع فوراً للمصدر أو الكتاب.
4. **بسّط وأعد الصياغة:** نظّم شرحك النهائي في قصة قصيرة أو رسم توضيحي مبسط.

جرب تطبيقها الآن على أي درس تشعر بصعوبته وسأساعدك في اختباره!''',
      );
    }

    if (lower.contains('بومودورو') || lower.contains('pomodoro') || lower.contains('تركيز')) {
      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.text,
        content: '''⏱️ **تقنية البومودورو لإدارة الوقت والتركيز الأقصى:**

- **جلسة دراسية:** 25 دقيقة تركيز خالص بدون أي مقاطعات (الهاتف بعيد تماماً).
- **استراحة قصيرة:** 5 دقائق للحركة، شرب الماء، وإراحة العينين.
- **بعد 4 دورات:** خذ استراحة طويلة (15 - 30 دقيقة) لتجديد الطاقة العصبية.

💡 **نصيحة ذهبية:** يمكنك تفعيل مؤقت البومودورو مباشرة من قسم **"مؤقت التركيز"** في التطبيق!''',
      );
    }

    if (lower.contains('قلق') || lower.contains('خوف') || lower.contains('توتر') || lower.contains('امتحانات')) {
      return AiChatMessage(
        id: msgId,
        sender: AiSender.assistant,
        timestamp: DateTime.now(),
        type: AiMessageType.text,
        content: '''🌿 **كيف تتغلب على قلق الامتحانات وضغط المذاكرة؟**

1. **قسّم الجبل لحجارة صغيرة:** الخوف يأتي من رؤية المنهج ككتلة واحدة ضخمة. قسّمه إلى فصول، ثم صفحات، وركز فقط على الصفحة التي أمامك الآن.
2. **تنفس صندوقي (Box Breathing):** شهيق في 4 ثوانٍ، حبس النفس 4 ثوانٍ، زفير في 4 ثوانٍ، توقف 4 ثوانٍ. يهدئ الجهاز العصبي خلال دقيقتين.
3. **النوم أولاً:** قلة النوم تقلل من كفاءة استرجاع الذاكرة بنسبة 40%. حافظ على 7 ساعات نوم خصوصاً ليلة الاختبار.
4. **حل نماذج تجريبية:** التعرض المسبق لشكل ورقة الامتحان يزيل رهبة المجهول تماماً.''',
      );
    }

    // Default intelligent conversational helper
    return AiChatMessage(
      id: msgId,
      sender: AiSender.assistant,
      timestamp: DateTime.now(),
      type: AiMessageType.text,
      content: '''مرحباً بك! أنا مساعدك الدراسي الذكي 🎓✨

يسعدني دائماً مساعدتك في أي مما يلي:
- 📅 **تخطيط المذاكرة:** اطلب مني مثلاً: *"ضع لي خطة لمذاكرة الفيزياء في 3 ساعات"*.
- 📝 **الاختبارات والكويزات:** اطلب: *"اختبرني في مادة الرياضيات بأسئلة اختيار متعدد"*.
- 💡 **التلخيص والملاحظات:** اكتب أو الصق أي نص دراسي وسأستخرج منه أهم نقاط المراجعة السريعة.
- ⚡ **استراتيجيات التفوق:** اسألني عن تقنية فاينمان، علاج التسويف، أو التحضير لليلة الامتحان.

ما الذي تود أن نعمل عليه معاً الآن؟''',
    );
  }

  // --- Helpers ---

  static bool _matchesCategory(String text, List<String> keywords) {
    final lower = text.toLowerCase();
    return keywords.any((k) => lower.contains(k.toLowerCase()));
  }

  static int _extractHours(String text) {
    if (text.contains('ساعة واحدة') || text.contains('ساعة')) {
      if (text.contains('ساعتين') || text.contains('ساعتان')) return 2;
      if (text.contains('3') || text.contains('ثلاث')) return 3;
      if (text.contains('4') || text.contains('اربع') || text.contains('أربع')) return 4;
      if (text.contains('5') || text.contains('خمس')) return 5;
      if (text.contains('6') || text.contains('ست')) return 6;
      return 1;
    }
    final match = RegExp(r'(\d+)\s*ساع').firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 2;
    }
    if (text.contains('ساعتين') || text.contains('ساعتان')) return 2;
    return 3;
  }

  static String _extractSubjectFromPlanPrompt(String text) {
    final keywords = ['مادة', 'في', 'لمادة', 'درس', 'موضوع'];
    for (final kw in keywords) {
      final index = text.indexOf(kw);
      if (index != -1) {
        final rest = text.substring(index + kw.length).trim();
        final words = rest.split(RegExp(r'\s+'));
        if (words.isNotEmpty && words.first.isNotEmpty) {
          final candidate = words.take(2).join(' ').replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '');
          if (candidate.isNotEmpty && !candidate.contains('ساع')) {
            return candidate;
          }
        }
      }
    }
    if (text.contains('رياضيات')) return 'الرياضيات';
    if (text.contains('فيزياء')) return 'الفيزياء';
    if (text.contains('كيمياء')) return 'الكيمياء';
    if (text.contains('أحياء') || text.contains('احياء')) return 'الأحياء';
    if (text.contains('تاريخ')) return 'التاريخ';
    if (text.contains('عربي') || text.contains('نحو')) return 'اللغة العربية';
    if (text.contains('انجليزي') || text.contains('إنجليزي')) return 'اللغة الإنجليزية';
    return 'المادة الدراسية';
  }

  static String _extractSubjectFromQuizPrompt(String text) {
    return _extractSubjectFromPlanPrompt(text);
  }

  static List<AiQuizQuestion> _buildQuizQuestions(String subject, String difficulty, int count) {
    final lower = subject.toLowerCase();

    if (_matchesCategory(lower, ['رياضيات', 'حساب', 'جبر', 'تفاضل'])) {
      return [
        const AiQuizQuestion(
          id: 'q_math_1',
          question: 'إذا كانت د(س) = 3س² + 5س - 7، فإن المشتقة الأولى د\'(س) تساوي:',
          options: ['6س + 5', '3س + 5', '6س² + 5', '6س - 7'],
          correctIndex: 0,
          explanation: 'مشتقة 3س² هي 2 × 3س = 6س، ومشتقة 5س هي 5، ومشتقة الثابت صفر. فيكون الناتج 6س + 5.',
          hint: 'تذكر قاعدة إنزال الأس وطرح 1 منه.',
          difficulty: 'متوسط',
        ),
        const AiQuizQuestion(
          id: 'q_math_2',
          question: 'مجموع قياسات الزوايا الداخلية لأي مضلع سداسي منتظم يساوي:',
          options: ['360°', '540°', '720°', '1080°'],
          correctIndex: 2,
          explanation: 'القاعدة هي (ن - 2) × 180°. بالنسبة للسداسي ن = 6، إذن (6 - 2) × 180° = 4 × 180° = 720°.',
          hint: 'استخدم قانون (ن - 2) × 180 حيث ن عدد الأضلاع.',
          difficulty: 'متوسط',
        ),
        const AiQuizQuestion(
          id: 'q_math_3',
          question: 'حل المعادلة س² - 9 = 0 في مجموعة الأعداد الحقيقية هو:',
          options: ['{3}', '{-3}', '{3, -3}', '{9, -9}'],
          correctIndex: 2,
          explanation: 'بتحليل الفرق بين مربعين: (س - 3)(س + 3) = 0، وبالتالي س = 3 أو س = -3.',
          hint: 'حلل كفرق بين مربعين.',
          difficulty: 'سهل',
        ),
      ].take(count).toList();
    }

    if (_matchesCategory(lower, ['فيزياء', 'ميكانيكا', 'طاقة', 'كهرباء'])) {
      return [
        const AiQuizQuestion(
          id: 'q_phy_1',
          question: 'ما هي وحدة قياس القوة في النظام الدولي للوحدات (SI)؟',
          options: ['الجول (Joule)', 'النيوتن (Newton)', 'الواط (Watt)', 'الباسكال (Pascal)'],
          correctIndex: 1,
          explanation: 'النيوتن هو وحدة القوة المشتقة (كجم·م/ث²)، بينما الجول للطاقة والواط للقدرة.',
          hint: 'سميت باسم العالم الذي وضع قوانين الحركة والجاذبية الشهيرة.',
          difficulty: 'سهل',
        ),
        const AiQuizQuestion(
          id: 'q_phy_2',
          question: 'وفقاً لقانون نيوتن الثاني، إذا تضاعفت القوة المؤثرة على جسم مع ثبات كتلته، فإن تسارعه:',
          options: ['يقل إلى النصف', 'يتضاعف مرتين', 'يظل ثابتاً', 'يتضاعف 4 مرات'],
          correctIndex: 1,
          explanation: 'القوة = الكتلة × التسارع (ق = ك × ت). العلاقة بين القوة والتسارع طردية خطية عند ثبات الكتلة.',
          hint: 'تذكر علاقة ق = ك × ت (التناسب الطردي).',
          difficulty: 'متوسط',
        ),
        const AiQuizQuestion(
          id: 'q_phy_3',
          question: 'في الدوائر الكهربائية، النسبة بين فرق الجهد وشدة التيار تمثل:',
          options: ['المقاومة الكهربائية', 'القدرة الكهربائية', 'السعة الكهربائية', 'الشحنة الكهربائية'],
          correctIndex: 0,
          explanation: 'قانون أوم ينص على أن المقاومة (م) = فرق الجهد (جـ) ÷ شدة التيار (ت).',
          hint: 'هذا هو قانون أوم الأساسي.',
          difficulty: 'سهل',
        ),
      ].take(count).toList();
    }

    if (_matchesCategory(lower, ['كيمياء', 'عناصر', 'تفاعلات'])) {
      return [
        const AiQuizQuestion(
          id: 'q_chem_1',
          question: 'ما هو العنصر الأكثر وفرة في الغلاف الجوي للأرض؟',
          options: ['الأكسجين (O₂)', 'النيتروجين (N₂)', 'ثاني أكسيد الكربون (CO₂)', 'الهيدروجين (H₂)'],
          correctIndex: 1,
          explanation: 'غاز النيتروجين يشكل حوالي 78% من الغلاف الجوي، بينما الأكسجين يشكل حوالي 21%.',
          hint: 'يشكل قرابة 78% من الهواء المحيط بنا.',
          difficulty: 'سهل',
        ),
        const AiQuizQuestion(
          id: 'q_chem_2',
          question: 'الرابطة الناتجة عن انتقال كامل للإلكترونات من ذرة فلز إلى ذرة لافلز هي رابطة:',
          options: ['تساهمية', 'أيونية', 'هيدروجينية', 'فلزية'],
          correctIndex: 1,
          explanation: 'الرابطة الأيونية تنشأ بين أيون موجب (فقد إلكترون) وأيون سالب (اكتسب إلكترون).',
          hint: 'تنشأ بين فلز يفقد ولافلز يكتسب.',
          difficulty: 'متوسط',
        ),
        const AiQuizQuestion(
          id: 'q_chem_3',
          question: 'الرقم الهيدروجيني (pH) لمحلول متعادل عند درجة حرارة 25°C يساوي:',
          options: ['0', '7', '14', '1'],
          correctIndex: 1,
          explanation: 'الرقم 7 يمثل نقطة التعادل؛ أقل من 7 حمضي وأكبر من 7 قاعدي.',
          hint: 'يقع تماماً في منتصف المقياس من 0 إلى 14.',
          difficulty: 'سهل',
        ),
      ].take(count).toList();
    }

    if (_matchesCategory(lower, ['عربي', 'لغة عربية', 'نحو', 'بلاغة'])) {
      return [
        const AiQuizQuestion(
          id: 'q_ar_1',
          question: 'ما إعراب كلمة "مُجتهداً" في جملة: (كان الطالبُ مُجتهداً)؟',
          options: ['فاعل مرفوع', 'خبر كان منصوب', 'حال منصوبة', 'نعت منصوب'],
          correctIndex: 1,
          explanation: 'كان وأخواتها أفعال ناسخة ترفع المبتدأ ويسمى اسمها، وتنصب الخبر ويسمى خبرها.',
          hint: 'تذكر عمل الأفعال الناسخة الناقصة (كان وأخواتها).',
          difficulty: 'سهل',
        ),
        const AiQuizQuestion(
          id: 'q_ar_2',
          question: 'في البلاغة العربية، ما هو الغرض البلاغي من استخدام صيغة الأمر في الدعاء لله تعالى؟',
          options: ['الإلزام والوجوب', 'الدعاء والتوسل', 'التهديد والوعيد', 'التعجيز'],
          correctIndex: 1,
          explanation: 'إذا كان الأمر موجهاً من الأدنى إلى الأعلى منزلة (كالعبد إلى ربه) يخرج غرضه البلاغي للدعاء.',
          hint: 'الأمر الموجه من العبد إلى خالقه عز وجل.',
          difficulty: 'متوسط',
        ),
        const AiQuizQuestion(
          id: 'q_ar_3',
          question: 'من الحروف الناسخة التي تفيد الاستدراك في اللغة العربية:',
          options: ['إنّ', 'كأنّ', 'ليت', 'لكنّ'],
          correctIndex: 3,
          explanation: '"لكنّ" من أخوات إن وتفيد الاستدراك (منع الفهم الخاطئ لما قبلها).',
          hint: 'تفيد رفع ما قد يتوهمه السامع من الكلام السابق.',
          difficulty: 'متوسط',
        ),
      ].take(count).toList();
    }

    // Default / General Study Skills & Subject Quiz
    return [
      AiQuizQuestion(
        id: 'q_gen_1',
        question: 'في دراسة "$subject"، ما هي أفضل طريقة لتثبيت المفاهيم في الذاكرة طويلة المدى؟',
        options: [
          'إعادة القراءة السلبية عدة مرات متتالية',
          'التسميع والاسترجاع النشط (Active Recall) مع التكرار المتباعد',
          'وضع خطوط ملونة تحت كل أسطر الصفحة',
          'السهر ليلة الاختبار لإنهاء المنهج كاملاً دفعة واحدة',
        ],
        correctIndex: 1,
        explanation: 'أثبتت أبحاث علم الأعصاب أن محاولة تذكر المعلومة بدون النظر للمصدر تبني مسارات عصبية قوية جداً.',
        hint: 'الطريقة التي تجبر الدماغ على بذل جهد لاستعادة المعلومة.',
        difficulty: difficulty,
      ),
      AiQuizQuestion(
        id: 'q_gen_2',
        question: 'ما هي الفائدة الأساسية من تقسيم جلسة المذاكرة إلى فترات 25 دقيقة (تقنية البومودورو)؟',
        options: [
          'إطالة ساعات المذاكرة دون الحاجة للنوم',
          'الحفاظ على التركيز الذهني الكامل وتفادي الإرهاق الإدراكي',
          'إنهاء الكتاب في جلسة واحدة',
          'تجنب حل التمارين والمسائل الصعبة',
        ],
        correctIndex: 1,
        explanation: 'الفترات القصيرة تمنع تشتت الانتباه وتمنح الدماغ فرصة لإعادة شحن الدوبامين خلال الاستراحات.',
        hint: 'تتعلق بالانتباه المستمر وجودة الاستيعاب.',
        difficulty: difficulty,
      ),
      AiQuizQuestion(
        id: 'q_gen_3',
        question: 'عند مراجعة موضوع مركب في "$subject"، ينصح بتطبيق تقنية فاينمان عن طريق:',
        options: [
          'حفظ التعريف الحرفي بدون تغيير أي كلمة',
          'شرح المفهوم بأسلوب مبسط جداً وكأنك تشرحه لشخص لا يعرف شيئاً عنه',
          'تخطي الأجزاء الغامضة والتركيز على السهل فقط',
          'قراءة الملخصات الخارجية فقط دون الرجوع للمصدر الأصلي',
        ],
        correctIndex: 1,
        explanation: 'التبسيط وكشف مواطن الضعف في الشرح الذاتي هو جوهر تقنية فاينمان لضمان الفهم التام.',
        hint: 'التبسيط الشديد وكشف الفجوات الذهنية.',
        difficulty: difficulty,
      ),
    ].take(count).toList();
  }

  static List<String> _extractKeywords(String content) {
    final words = content
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 4)
        .toList();

    final stopWords = {
      'هذا', 'هذه', 'ذلك', 'تلك', 'التي', 'الذي', 'الذين', 'على', 'إلى', 'مع', 'عن', 'في', 'من', 'أن', 'إن', 'كان', 'كانت', 'يكون', 'ثم', 'حيث', 'كل', 'ما', 'لا', 'قد', 'بين'
    };

    final filtered = words.where((w) => !stopWords.contains(w)).toSet().take(4).toList();
    if (filtered.isEmpty) {
      return ['مفاهيم أساسية', 'مراجعة', 'نقاط تركيز'];
    }
    return filtered;
  }
}
