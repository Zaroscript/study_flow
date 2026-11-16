enum GoalAlertType { danger, warning, success, info }

class GoalAlert {
  final String goalId;
  final String goalTitle;
  final GoalAlertType type;
  final String message;
  final int daysLeft;
  final int progressPercent;

  const GoalAlert({
    required this.goalId,
    required this.goalTitle,
    required this.type,
    required this.message,
    required this.daysLeft,
    required this.progressPercent,
  });
}
