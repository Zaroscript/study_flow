enum AiSender { user, assistant, system }

enum AiMessageType { text, studyPlan, quiz, summary }

class AiStudySessionPhase {
  final String title;
  final int durationMinutes;
  final String description;
  final String cognitiveLevel;
  final String energyBadge;
  final List<String> subtasks;

  const AiStudySessionPhase({
    required this.title,
    required this.durationMinutes,
    required this.description,
    required this.cognitiveLevel,
    required this.energyBadge,
    this.subtasks = const [],
  });

  AiStudySessionPhase copyWith({
    String? title,
    int? durationMinutes,
    String? description,
    String? cognitiveLevel,
    String? energyBadge,
    List<String>? subtasks,
  }) {
    return AiStudySessionPhase(
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      cognitiveLevel: cognitiveLevel ?? this.cognitiveLevel,
      energyBadge: energyBadge ?? this.energyBadge,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  factory AiStudySessionPhase.fromJson(Map<String, dynamic> json) {
    return AiStudySessionPhase(
      title: json['title'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      description: json['description'] as String? ?? '',
      cognitiveLevel: json['cognitiveLevel'] as String? ?? 'فهم وتطبيق',
      energyBadge: json['energyBadge'] as String? ?? 'طاقة عالية ⚡',
      subtasks:
          (json['subtasks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'durationMinutes': durationMinutes,
      'description': description,
      'cognitiveLevel': cognitiveLevel,
      'energyBadge': energyBadge,
      'subtasks': subtasks,
    };
  }
}

class AiStudyPlan {
  final String id;
  final String subject;
  final int availableHours;
  final String overview;
  final List<AiStudySessionPhase> phases;
  final List<String> smartTips;
  final String pomodoroRecommendation;
  final String revisionCadence;

  const AiStudyPlan({
    required this.id,
    required this.subject,
    required this.availableHours,
    required this.overview,
    required this.phases,
    required this.smartTips,
    required this.pomodoroRecommendation,
    required this.revisionCadence,
  });

  int get totalMinutes => phases.fold(0, (sum, p) => sum + p.durationMinutes);

  AiStudyPlan copyWith({
    String? id,
    String? subject,
    int? availableHours,
    String? overview,
    List<AiStudySessionPhase>? phases,
    List<String>? smartTips,
    String? pomodoroRecommendation,
    String? revisionCadence,
  }) {
    return AiStudyPlan(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      availableHours: availableHours ?? this.availableHours,
      overview: overview ?? this.overview,
      phases: phases ?? this.phases,
      smartTips: smartTips ?? this.smartTips,
      pomodoroRecommendation:
          pomodoroRecommendation ?? this.pomodoroRecommendation,
      revisionCadence: revisionCadence ?? this.revisionCadence,
    );
  }

  factory AiStudyPlan.fromJson(Map<String, dynamic> json) {
    return AiStudyPlan(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      availableHours: json['availableHours'] as int? ?? 2,
      overview: json['overview'] as String? ?? '',
      phases:
          (json['phases'] as List<dynamic>?)
              ?.map(
                (e) => AiStudySessionPhase.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      smartTips:
          (json['smartTips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pomodoroRecommendation: json['pomodoroRecommendation'] as String? ?? '',
      revisionCadence: json['revisionCadence'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'availableHours': availableHours,
      'overview': overview,
      'phases': phases.map((p) => p.toJson()).toList(),
      'smartTips': smartTips,
      'pomodoroRecommendation': pomodoroRecommendation,
      'revisionCadence': revisionCadence,
    };
  }
}

class AiQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String hint;
  final String difficulty;

  const AiQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.hint,
    this.difficulty = 'متوسط',
  });

  AiQuizQuestion copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctIndex,
    String? explanation,
    String? hint,
    String? difficulty,
  }) {
    return AiQuizQuestion(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      explanation: explanation ?? this.explanation,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  factory AiQuizQuestion.fromJson(Map<String, dynamic> json) {
    return AiQuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      hint: json['hint'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'متوسط',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'hint': hint,
      'difficulty': difficulty,
    };
  }
}

class AiQuiz {
  final String id;
  final String subject;
  final String difficulty;
  final List<AiQuizQuestion> questions;
  final Map<int, int> userAnswers; // questionIndex -> selectedOptionIndex
  final bool isCompleted;

  const AiQuiz({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.questions,
    this.userAnswers = const {},
    this.isCompleted = false,
  });

  int get score {
    int total = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctIndex) {
        total++;
      }
    }
    return total;
  }

  int get percentage =>
      questions.isEmpty ? 0 : ((score / questions.length) * 100).round();

  AiQuiz copyWith({
    String? id,
    String? subject,
    String? difficulty,
    List<AiQuizQuestion>? questions,
    Map<int, int>? userAnswers,
    bool? isCompleted,
  }) {
    return AiQuiz(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory AiQuiz.fromJson(Map<String, dynamic> json) {
    return AiQuiz(
      id: json['id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'متوسط',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((e) => AiQuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      userAnswers:
          (json['userAnswers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.parse(k), v as int),
          ) ??
          const {},
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'difficulty': difficulty,
      'questions': questions.map((q) => q.toJson()).toList(),
      'userAnswers': userAnswers.map((k, v) => MapEntry(k.toString(), v)),
      'isCompleted': isCompleted,
    };
  }
}

class AiNoteInsight {
  final String id;
  final String title;
  final String summary;
  final List<String> keyTakeaways;
  final List<String> actionItems;
  final List<String> keywords;
  final int estimatedReadMinutes;

  const AiNoteInsight({
    required this.id,
    required this.title,
    required this.summary,
    required this.keyTakeaways,
    required this.actionItems,
    this.keywords = const [],
    this.estimatedReadMinutes = 3,
  });

  AiNoteInsight copyWith({
    String? id,
    String? title,
    String? summary,
    List<String>? keyTakeaways,
    List<String>? actionItems,
    List<String>? keywords,
    int? estimatedReadMinutes,
  }) {
    return AiNoteInsight(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      actionItems: actionItems ?? this.actionItems,
      keywords: keywords ?? this.keywords,
      estimatedReadMinutes: estimatedReadMinutes ?? this.estimatedReadMinutes,
    );
  }

  factory AiNoteInsight.fromJson(Map<String, dynamic> json) {
    return AiNoteInsight(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      keyTakeaways:
          (json['keyTakeaways'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      actionItems:
          (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      estimatedReadMinutes: json['estimatedReadMinutes'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'keyTakeaways': keyTakeaways,
      'actionItems': actionItems,
      'keywords': keywords,
      'estimatedReadMinutes': estimatedReadMinutes,
    };
  }
}

class AiChatMessage {
  final String id;
  final AiSender sender;
  final String content;
  final DateTime timestamp;
  final AiMessageType type;
  final AiStudyPlan? studyPlan;
  final AiQuiz? quiz;
  final AiNoteInsight? noteInsight;

  const AiChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.type = AiMessageType.text,
    this.studyPlan,
    this.quiz,
    this.noteInsight,
  });

  AiChatMessage copyWith({
    String? id,
    AiSender? sender,
    String? content,
    DateTime? timestamp,
    AiMessageType? type,
    AiStudyPlan? studyPlan,
    AiQuiz? quiz,
    AiNoteInsight? noteInsight,
  }) {
    return AiChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      studyPlan: studyPlan ?? this.studyPlan,
      quiz: quiz ?? this.quiz,
      noteInsight: noteInsight ?? this.noteInsight,
    );
  }

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String? ?? '',
      sender: AiSender.values.firstWhere(
        (e) => e.name == json['sender'],
        orElse: () => AiSender.assistant,
      ),
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      type: AiMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AiMessageType.text,
      ),
      studyPlan: json['studyPlan'] != null
          ? AiStudyPlan.fromJson(json['studyPlan'] as Map<String, dynamic>)
          : null,
      quiz: json['quiz'] != null
          ? AiQuiz.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
      noteInsight: json['noteInsight'] != null
          ? AiNoteInsight.fromJson(json['noteInsight'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'studyPlan': studyPlan?.toJson(),
      'quiz': quiz?.toJson(),
      'noteInsight': noteInsight?.toJson(),
    };
  }
}
