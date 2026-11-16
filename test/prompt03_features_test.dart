import '../lib/data/models/goal_model.dart';
import '../lib/data/models/goal_notification_model.dart';
import '../lib/data/models/material_item_model.dart';
import '../lib/data/models/task_model.dart';
import '../lib/data/models/user_rewards_model.dart';
import '../lib/features/goals/services/goals_smart_service.dart';
import '../lib/features/planner/services/smart_task_service.dart';

void main() {
  print('========================================================');
  print('🎯 StudyFlow Prompt 03 — Smart Systems Automated Tests 🎯');
  print('========================================================\n');

  testRewardsSystem();
  testMaterialLibrarySystem();
  testGoalsNotifierSystem();
  testSmartTaskSystem();

  print('\n========================================================');
  print('🌟 ALL PROMPT 03 SMART SYSTEM TESTS PASSED SUCCESSFULLY! 🌟');
  print('========================================================');
}

void testRewardsSystem() {
  print('Running Rewards & Gamification Tests...');

  // Level 1: 0 - 499 XP
  var rewards = const UserRewards(currentXP: 250);
  assert(rewards.level == 1, 'Expected level 1 for 250 XP');
  assert(rewards.levelTitle.contains('مبتدئ شغوف'), 'Incorrect title for Level 1');
  assert((rewards.levelProgress - 0.5).abs() < 0.01, 'Progress should be 50%');

  // Level 2: 500 - 1499 XP
  rewards = const UserRewards(currentXP: 1000);
  assert(rewards.level == 2, 'Expected level 2 for 1000 XP');
  assert(rewards.levelTitle.contains('باحث مجتهد'), 'Incorrect title for Level 2');
  assert((rewards.levelProgress - 0.5).abs() < 0.01, 'Progress should be 50% in Level 2');

  // Level 3: 1500 - 2999 XP
  rewards = const UserRewards(currentXP: 2250);
  assert(rewards.level == 3, 'Expected level 3 for 2250 XP');
  assert(rewards.levelTitle.contains('متفوق واعد'), 'Incorrect title for Level 3');

  // Level 4: 3000 - 5999 XP
  rewards = const UserRewards(currentXP: 4500);
  assert(rewards.level == 4, 'Expected level 4 for 4500 XP');

  // Level 5: 6000+ XP
  rewards = const UserRewards(currentXP: 8000);
  assert(rewards.level == 5, 'Expected level 5 for 8000 XP');
  assert(rewards.levelTitle.contains('أسطورة دراسية'), 'Incorrect title for Level 5');

  // Badge testing
  const badge = BadgeItem(
    id: 'streak_3',
    title: 'المواظب النشط',
    description: '3 أيام متتالية من المذاكرة',
    icon: 'Flame',
    isUnlocked: false,
    xpReward: 100,
  );

  final unlockedBadge = badge.copyWith(isUnlocked: true, unlockedDate: '2026-11-15');
  assert(unlockedBadge.isUnlocked == true, 'Badge should be unlocked');
  assert(unlockedBadge.unlockedDate == '2026-11-15', 'Date mismatch');

  print('  ✓ Level progression & XP thresholds: PASSED');
  print('  ✓ Level title and progress computation: PASSED');
  print('  ✓ Badges unlocking and rewarding: PASSED');
}

void testMaterialLibrarySystem() {
  print('Running Material & Books Library Tests...');

  const folder = MaterialFolder(
    id: 'subj_math',
    name: 'رياضيات بحتة',
    color: '#4F46E5',
    icon: 'Calculate',
    filesCount: 3,
  );

  final jsonFolder = folder.toJson();
  final restoredFolder = MaterialFolder.fromJson(jsonFolder);
  assert(restoredFolder.id == folder.id, 'Folder ID mismatch');
  assert(restoredFolder.name == folder.name, 'Folder Name mismatch');
  assert(restoredFolder.filesCount == 3, 'Files count mismatch');

  const item = MaterialItem(
    id: 'mat_1',
    folderId: 'subj_math',
    subject: 'رياضيات بحتة',
    title: 'كتاب التفاضل والتكامل',
    type: MaterialType.book,
    totalPages: 200,
    readPages: 50,
    dateAdded: '2026-11-15',
  );

  assert(item.readingPercentage == 25, 'Expected 25% reading percentage');
  assert((item.readingProgress - 0.25).abs() < 0.001, 'Expected 0.25 progress ratio');

  final updatedItem = item.copyWith(readPages: 200);
  assert(updatedItem.readingPercentage == 100, 'Expected 100% on completion');
  assert(updatedItem.readingProgress == 1.0, 'Expected 1.0 ratio');

  // Serialization test
  final itemJson = updatedItem.toJson();
  final fromJsonItem = MaterialItem.fromJson(itemJson);
  assert(fromJsonItem.title == 'كتاب التفاضل والتكامل', 'Title serialization error');
  assert(fromJsonItem.type == MaterialType.book, 'MaterialType serialization error');
  assert(fromJsonItem.readPages == 200, 'ReadPages serialization error');

  print('  ✓ Folder model & JSON serialization: PASSED');
  print('  ✓ Material items reading progress & percentages: PASSED');
  print('  ✓ Progress update & copyWith immutability: PASSED');
}

void testGoalsNotifierSystem() {
  print('Running Goals Smart Notifier Tests...');

  final now = DateTime.now();
  final twoDaysLater = now.add(const Duration(days: 2)).toIso8601String().substring(0, 10);
  final sixDaysLater = now.add(const Duration(days: 6)).toIso8601String().substring(0, 10);
  final pastDate = now.subtract(const Duration(days: 2)).toIso8601String().substring(0, 10);

  final List<GoalModel> goals = [
    // 1. Completed goal
    const GoalModel(
      id: 'g1',
      title: 'إنهاء الباب الأول فيزياء',
      color: 'indigo',
      deadline: '2026-12-01',
      target: 4,
      current: 4,
    ),
    // 2. Urgent deadline with low progress
    GoalModel(
      id: 'g2',
      title: 'واجب البرمجة المعقد',
      color: 'blue',
      deadline: twoDaysLater,
      target: 10,
      current: 2,
    ),
    // 3. Almost done
    const GoalModel(
      id: 'g3',
      title: 'قراءة مراجع التاريخ',
      color: 'yellow',
      deadline: '2026-12-25',
      target: 100,
      current: 85,
    ),
    // 4. Overdue goal
    GoalModel(
      id: 'g4',
      title: 'تسليم بحث الجغرافيا',
      color: 'red',
      deadline: pastDate,
      target: 5,
      current: 1,
    ),
    // 5. Warning pace (due within week, progress < 50%)
    GoalModel(
      id: 'g5',
      title: 'مراجعة الكيمياء العضوية',
      color: 'green',
      deadline: sixDaysLater,
      target: 10,
      current: 3,
    ),
  ];

  final alerts = GoalsSmartService.analyzeGoals(goals);

  // Check g1 (completed -> info)
  final g1Alert = alerts.firstWhere((a) => a.goalId == 'g1');
  assert(g1Alert.type == GoalAlertType.info, 'g1 should have info alert for completion');

  // Check g2 (urgent -> danger)
  final g2Alert = alerts.firstWhere((a) => a.goalId == 'g2');
  assert(g2Alert.type == GoalAlertType.danger, 'g2 should be urgent danger');

  // Check g3 (almost done -> success)
  final g3Alert = alerts.firstWhere((a) => a.goalId == 'g3');
  assert(g3Alert.type == GoalAlertType.success, 'g3 should be success near completion');

  // Check g4 (overdue -> danger)
  final g4Alert = alerts.firstWhere((a) => a.goalId == 'g4');
  assert(g4Alert.type == GoalAlertType.danger, 'g4 overdue should be danger');

  // Check g5 (due in <= 7 days, progress < 50% -> warning)
  final g5Alert = alerts.firstWhere((a) => a.goalId == 'g5');
  assert(g5Alert.type == GoalAlertType.warning, 'g5 should be warning pace');

  print('  ✓ Complete goal 100% notification: PASSED');
  print('  ✓ Urgent deadline alert (<= 3 days): PASSED');
  print('  ✓ Approaching completion alert (>= 80%): PASSED');
  print('  ✓ Overdue deadline warning: PASSED');
  print('  ✓ 7-day pacing alert: PASSED');
}

void testSmartTaskSystem() {
  print('Running Smart Task System Tests...');

  const today = '2026-11-15';
  final List<TaskModel> tasks = [
    const TaskModel(
      id: 't1',
      title: 'حل مسائل التفاضل المتأخرة',
      date: '2026-11-13',
      startTime: '10:00',
      endTime: '11:00',
      priority: 'high',
      category: 'study',
      completed: false,
    ),
    const TaskModel(
      id: 't2',
      title: 'مراجعة الأحياء القديمة المنجزة',
      date: '2026-11-14',
      startTime: '12:00',
      endTime: '13:00',
      priority: 'medium',
      category: 'lesson',
      completed: true, // already done
    ),
    const TaskModel(
      id: 't3',
      title: 'واجب اللغة الإنجليزية لليوم',
      date: '2026-11-15',
      startTime: '14:00',
      endTime: '15:00',
      priority: 'medium',
      category: 'homework',
      completed: false,
    ),
    const TaskModel(
      id: 't4',
      title: 'قراءة ملخص الكيمياء للغد',
      date: '2026-11-16',
      startTime: '16:00',
      endTime: '17:00',
      priority: 'low',
      category: 'reading',
      completed: false,
    ),
  ];

  // Rollover detection
  final rollovers = SmartTaskService.getPendingRolloverTasks(tasks, today);
  assert(rollovers.length == 1, 'Should find exactly 1 pending rollover task');
  assert(rollovers.first.id == 't1', 't1 should be the pending rollover task');

  // Eisenhower classification
  assert(
    SmartTaskService.classifyTask(tasks[0]) == SmartTaskQuadrant.urgentImportant,
    'High priority task should be urgentImportant',
  );
  assert(
    SmartTaskService.classifyTask(tasks[2]) == SmartTaskQuadrant.importantNotUrgent,
    'Medium priority task should be importantNotUrgent',
  );
  assert(
    SmartTaskService.classifyTask(tasks[3]) == SmartTaskQuadrant.routineQuickWin,
    'Low priority task should be routineQuickWin',
  );

  // Energy advice
  final studyAdvice = SmartTaskService.getEnergyAdvice('study');
  assert(studyAdvice.contains('طاقة عالية'), 'Study should have high energy advice');

  final homeworkAdvice = SmartTaskService.getEnergyAdvice('homework');
  assert(homeworkAdvice.contains('تركيز عملي'), 'Homework should have practical focus advice');

  final readingAdvice = SmartTaskService.getEnergyAdvice('reading');
  assert(readingAdvice.contains('هدوء واستيعاب'), 'Reading should have evening calm advice');

  print('  ✓ Automatic past-incomplete task rollover detection: PASSED');
  print('  ✓ Eisenhower quadrant matrix classification: PASSED');
  print('  ✓ Category-based energy slot study advice: PASSED');
}
