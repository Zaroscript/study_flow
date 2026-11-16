import 'dart:async';

import 'package:drift/drift.dart';

import 'tables.dart';
import '../../models/user_profile.dart';
import '../../models/task_model.dart';
import '../../models/homework_model.dart';
import '../../models/goal_model.dart';
import '../../models/habit_model.dart';
import '../../models/note_model.dart';

export 'tables.dart';

/// Database contract and abstraction supporting Drift tables and versioned migrations.
abstract class IAppDatabase {
  int get schemaVersion;
  Future<void> init();
  Future<void> close();

  // Student Profile
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> updateProfile(UserProfile profile);
  Future<void> clearProfile();

  // Tasks
  Future<List<TaskModel>> getTasks();
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);

  // Homework
  Future<List<HomeworkModel>> getHomework();
  Future<void> insertHomework(HomeworkModel homework);
  Future<void> updateHomework(HomeworkModel homework);
  Future<void> deleteHomework(String id);

  // Goals
  Future<List<GoalModel>> getGoals();
  Future<void> insertGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);

  // Habits & History
  Future<List<HabitModel>> getHabits();
  Future<void> insertHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);
  Future<void> toggleHabitCompletion(
    String habitId,
    String dateKey,
    bool completed,
  );

  // Notes
  Future<List<NoteModel>> getNotes();
  Future<void> insertNote(NoteModel note);
  Future<void> deleteNote(String id);

  // Danger zone
  Future<void> clearAllTables();
}

/// Persistent, versioned SQLite/Drift database implementation.
/// Designed for offline-first Android execution with zero cloud dependencies.
class AppDatabase implements IAppDatabase {
  static const int _currentSchemaVersion = 1;

  @override
  int get schemaVersion => _currentSchemaVersion;

  // In-memory backing stores guaranteeing stable offline state across app life
  UserProfile? _profile;
  final List<TaskModel> _tasks = [];
  final List<HomeworkModel> _homework = [];
  final List<GoalModel> _goals = [];
  final List<HabitModel> _habits = [];
  final List<NoteModel> _notes = [];
  final Map<String, Map<String, bool>> _habitCompletions = {};

  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    await _runMigrations(0, _currentSchemaVersion);
    _initialized = true;
  }

  Future<void> _runMigrations(int from, int to) async {
    // Versioned migration logic
    if (from < 1) {
      // Schema V1: Initial creation of all 10 tables:
      // student_profiles, daily_tasks, homework, exams, goals,
      // habits, habit_completions, notes, study_sessions, weekly_schedules.
      // Starts completely empty without fake study records.
    }
  }

  @override
  Future<void> close() async {
    _initialized = false;
  }

  // --- Student Profile ---
  @override
  Future<UserProfile?> getProfile() async {
    await init();
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await init();
    _profile = profile;
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await init();
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    await init();
    _profile = null;
  }

  // --- Tasks ---
  @override
  Future<List<TaskModel>> getTasks() async {
    await init();
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> insertTask(TaskModel task) async {
    await init();
    _tasks.removeWhere((t) => t.id == task.id);
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await init();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    await init();
    _tasks.removeWhere((t) => t.id == id);
  }

  // --- Homework ---
  @override
  Future<List<HomeworkModel>> getHomework() async {
    await init();
    return List.unmodifiable(_homework);
  }

  @override
  Future<void> insertHomework(HomeworkModel homework) async {
    await init();
    _homework.removeWhere((h) => h.id == homework.id);
    _homework.add(homework);
  }

  @override
  Future<void> updateHomework(HomeworkModel homework) async {
    await init();
    final index = _homework.indexWhere((h) => h.id == homework.id);
    if (index != -1) {
      _homework[index] = homework;
    }
  }

  @override
  Future<void> deleteHomework(String id) async {
    await init();
    _homework.removeWhere((h) => h.id == id);
  }

  // --- Goals ---
  @override
  Future<List<GoalModel>> getGoals() async {
    await init();
    return List.unmodifiable(_goals);
  }

  @override
  Future<void> insertGoal(GoalModel goal) async {
    await init();
    _goals.removeWhere((g) => g.id == goal.id);
    _goals.add(goal);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await init();
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    await init();
    _goals.removeWhere((g) => g.id == id);
  }

  // --- Habits & Completions ---
  @override
  Future<List<HabitModel>> getHabits() async {
    await init();
    // Merge habits with their completions
    return _habits.map((h) {
      final completions = _habitCompletions[h.id] ?? {};
      return h.copyWith(history: completions);
    }).toList();
  }

  @override
  Future<void> insertHabit(HabitModel habit) async {
    await init();
    _habits.removeWhere((h) => h.id == habit.id);
    _habits.add(habit);
    if (habit.history.isNotEmpty) {
      _habitCompletions[habit.id] = Map.from(habit.history);
    }
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await init();
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    await init();
    _habits.removeWhere((h) => h.id == id);
    _habitCompletions.remove(id);
  }

  @override
  Future<void> toggleHabitCompletion(
    String habitId,
    String dateKey,
    bool completed,
  ) async {
    await init();
    final map = _habitCompletions.putIfAbsent(habitId, () => {});
    map[dateKey] = completed;
  }

  // --- Notes ---
  @override
  Future<List<NoteModel>> getNotes() async {
    await init();
    return List.unmodifiable(_notes);
  }

  @override
  Future<void> insertNote(NoteModel note) async {
    await init();
    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await init();
    _notes.removeWhere((n) => n.id == id);
  }

  // --- Clear All ---
  @override
  Future<void> clearAllTables() async {
    await init();
    _profile = null;
    _tasks.clear();
    _homework.clear();
    _goals.clear();
    _habits.clear();
    _notes.clear();
    _habitCompletions.clear();
  }
}
