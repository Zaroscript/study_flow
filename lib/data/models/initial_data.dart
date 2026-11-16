import 'user_profile.dart';
import 'task_model.dart';
import 'homework_model.dart';
import 'exam_model.dart';
import 'habit_model.dart';
import 'goal_model.dart';
import 'note_model.dart';
import 'stats_model.dart';
import 'pomodoro_settings.dart';

class InitialData {
  InitialData._();

  static List<TaskModel> get tasks {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return [
      TaskModel(
        id: '1',
        title: 'مراجعة فيزياء الباب الأول',
        category: 'study',
        startTime: '10:00',
        endTime: '12:00',
        completed: false,
        priority: 'high',
        date: today,
      ),
      TaskModel(
        id: '2',
        title: 'حل تمارين الرياضيات',
        category: 'homework',
        startTime: '14:00',
        endTime: '15:30',
        completed: true,
        priority: 'medium',
        date: today,
      ),
      TaskModel(
        id: '3',
        title: 'درس لغة عربية',
        category: 'lesson',
        startTime: '16:00',
        endTime: '18:00',
        completed: false,
        priority: 'high',
        date: today,
      ),
    ];
  }

  static List<HomeworkModel> get homework {
    final tomorrow = DateTime.now()
        .add(const Duration(days: 1))
        .toIso8601String()
        .split('T')[0];
    final dayAfterTomorrow = DateTime.now()
        .add(const Duration(days: 2))
        .toIso8601String()
        .split('T')[0];

    return [
      HomeworkModel(
        id: '1',
        subject: 'رياضيات',
        description: 'حل صفحة 45 و 46',
        deadline: tomorrow,
        priority: 'high',
        status: 'pending',
      ),
      HomeworkModel(
        id: '2',
        subject: 'لغة إنجليزية',
        description: 'كتابة مقال عن التلوث',
        deadline: dayAfterTomorrow,
        priority: 'medium',
        status: 'completed',
      ),
    ];
  }

  static List<ExamModel> get exams {
    final inFiveDays = DateTime.now()
        .add(const Duration(days: 5))
        .toIso8601String()
        .split('T')[0];

    return [
      ExamModel(
        id: '1',
        subject: 'كيمياء',
        date: inFiveDays,
        time: '09:00',
        location: 'المدرسة - قاعة 3',
        priority: 'high',
      ),
    ];
  }

  static List<HabitModel> get habits => [
    const HabitModel(
      id: '1',
      name: 'الاستيقاظ مبكراً (6 ص)',
      icon: 'Sun',
      color: 'yellow',
    ),
    const HabitModel(
      id: '2',
      name: 'شرب 2 لتر ماء',
      icon: 'Coffee',
      color: 'blue',
    ),
    const HabitModel(
      id: '3',
      name: 'قراءة 10 صفحات',
      icon: 'Book',
      color: 'teal',
    ),
  ];

  static List<GoalModel> get goals {
    final in30Days = DateTime.now()
        .add(const Duration(days: 30))
        .toIso8601String()
        .split('T')[0];
    final in60Days = DateTime.now()
        .add(const Duration(days: 60))
        .toIso8601String()
        .split('T')[0];

    return [
      GoalModel(
        id: '1',
        title: 'الحصول على 95% في الرياضيات',
        target: 100,
        current: 80,
        deadline: in30Days,
        color: 'green',
      ),
      GoalModel(
        id: '2',
        title: 'ختم القرآن الكريم',
        target: 30,
        current: 15,
        deadline: in60Days,
        color: 'indigo',
      ),
    ];
  }

  static List<NoteModel> get notes => [
    NoteModel(
      id: '1',
      title: 'ملخص قوانين نيوتن',
      content: 'القانون الأول: يظل الجسم على حالته...\nالقانون الثاني: القوة = الكتلة × العجلة...',
      folder: 'فيزياء',
      date: DateTime.now().toIso8601String(),
    ),
  ];

  static const StudyStats stats = StudyStats(
    studyTimeMinutes: 450,
    tasksCompleted: 12,
    focusScore: 85,
  );

  static const PomodoroSettings pomodoro = PomodoroSettings(
    study: 25,
    breakDuration: 5,
    longBreak: 15,
  );

  static const UserProfile? initialProfile = null;
}
