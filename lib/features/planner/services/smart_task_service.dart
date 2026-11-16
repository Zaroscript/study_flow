import '../../../data/models/task_model.dart';

enum SmartTaskQuadrant { urgentImportant, importantNotUrgent, routineQuickWin }

class SmartTaskService {
  SmartTaskService._();

  /// Identifies unfinished tasks from past days that should be rolled over to today
  static List<TaskModel> getPendingRolloverTasks(
    List<TaskModel> allTasks,
    String todayDate,
  ) {
    return allTasks.where((task) {
      return !task.completed &&
          task.date.isNotEmpty &&
          task.date.compareTo(todayDate) < 0;
    }).toList();
  }

  /// Classifies tasks into Eisenhower Quadrants
  static SmartTaskQuadrant classifyTask(TaskModel task) {
    if (task.priority == 'high') {
      return SmartTaskQuadrant.urgentImportant;
    } else if (task.priority == 'medium' || task.category == 'study') {
      return SmartTaskQuadrant.importantNotUrgent;
    } else {
      return SmartTaskQuadrant.routineQuickWin;
    }
  }

  /// Provides smart energy-level study advice based on category
  static String getEnergyAdvice(String category) {
    switch (category) {
      case 'study':
      case 'school':
        return '⚡ طاقة عالية: يُفضل إنجازها في الفترة الصباحية لزيادة الاستيعاب.';
      case 'homework':
      case 'lesson':
        return '✍️ تركيز عملي: مثالية لفترة بعد الظهر بعد وجبة الغداء والاستراحة.';
      case 'reading':
      case 'personal':
      case 'break':
        return '📖 هدوء واستيعاب: مناسبة للمساء للمراجعة الخفيفة وتثبيت المعلومات.';
      default:
        return '🎯 حدد وقتاً مخصصاً وركز على مهمة واحدة في كل مرة.';
    }
  }
}
