import '../../../data/models/goal_model.dart';
import '../../../data/models/goal_notification_model.dart';

class GoalsSmartService {
  GoalsSmartService._();

  static List<GoalAlert> analyzeGoals(List<GoalModel> goals) {
    final alerts = <GoalAlert>[];
    final now = DateTime.now();

    for (final goal in goals) {
      final percent = goal.progressPercentage.round();
      DateTime? deadlineDate;
      try {
        deadlineDate = DateTime.parse(goal.deadline);
      } catch (_) {
        continue;
      }

      final daysLeft = deadlineDate.difference(now).inDays;

      if (percent >= 100) {
        alerts.add(
          GoalAlert(
            goalId: goal.id,
            goalTitle: goal.title,
            type: GoalAlertType.info,
            message: 'رائع جداً! تم تحقيق هذا الهدف بالكامل بنسبة 100% 🎯',
            daysLeft: daysLeft,
            progressPercent: percent,
          ),
        );
      } else if (daysLeft <= 0) {
        alerts.add(
          GoalAlert(
            goalId: goal.id,
            goalTitle: goal.title,
            type: GoalAlertType.danger,
            message:
                'انتهى الموعد المحدد لهذا الهدف بنسبة إنجاز $percent%. يمكنك تمديد التاريخ أو إنهائه الآن.',
            daysLeft: daysLeft,
            progressPercent: percent,
          ),
        );
      } else if (daysLeft <= 3 && percent < 75) {
        alerts.add(
          GoalAlert(
            goalId: goal.id,
            goalTitle: goal.title,
            type: GoalAlertType.danger,
            message:
                'تنبيه عاجل: متبقي $daysLeft أيام فقط ونسبة الإنجاز $percent%. كثف جلسات التركيز لتدارك الهدف!',
            daysLeft: daysLeft,
            progressPercent: percent,
          ),
        );
      } else if (percent >= 80) {
        alerts.add(
          GoalAlert(
            goalId: goal.id,
            goalTitle: goal.title,
            type: GoalAlertType.success,
            message:
                'أوشكت على إنهاء الهدف! أنجزت $percent%. دفعة بسيطة وتصل للقمة 🚀',
            daysLeft: daysLeft,
            progressPercent: percent,
          ),
        );
      } else if (daysLeft <= 7 && percent < 50) {
        alerts.add(
          GoalAlert(
            goalId: goal.id,
            goalTitle: goal.title,
            type: GoalAlertType.warning,
            message:
                'متبقي أسبوع واحد ($daysLeft أيام) على موعد الهدف وإنجازك الحالي $percent%. خطط لجلسات إضافية هذا الأسبوع.',
            daysLeft: daysLeft,
            progressPercent: percent,
          ),
        );
      }
    }

    return alerts;
  }
}
