import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/homework_model.dart';
import '../../../data/models/goal_model.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/note_model.dart';
import '../../../data/models/stats_model.dart';
import '../../../data/models/pomodoro_settings.dart';
import '../../../data/local/preferences/preferences_service.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/repositories/study_flow_repository.dart';
import '../../../data/repositories/drift_study_flow_repository.dart';

/// Preferences Service Provider
final preferencesServiceProvider = Provider<IPreferencesService>((ref) {
  final service = SharedPreferencesService();
  return service;
});

/// Local Database Provider
final appDatabaseProvider = Provider<IAppDatabase>((ref) {
  return AppDatabase();
});

/// Local Repository Provider (Drift + SQLite)
final studyFlowRepositoryProvider = Provider<IStudyFlowRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftStudyFlowRepository(db);
});

/// Profile Notifier
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((
  ref,
) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return ProfileNotifier(repo);
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final IStudyFlowRepository _repo;

  ProfileNotifier(this._repo) : super(null) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repo.saveProfile(profile);
    state = profile;
  }

  Future<void> clearProfile() async {
    await _repo.clearProfile();
    state = null;
  }
}

/// Tasks Notifier (Starts empty without fake study records)
final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((
  ref,
) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return TasksNotifier(repo);
});

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  final IStudyFlowRepository _repo;

  TasksNotifier(this._repo) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    final updated = state.map((task) {
      if (task.id == id) {
        final newStatus = !task.completed;
        final updatedTask = task.copyWith(completed: newStatus);
        _repo.updateTask(updatedTask);
        return updatedTask;
      }
      return task;
    }).toList();
    state = updated;
  }

  Future<void> addTask(TaskModel task) async {
    await _repo.addTask(task);
    state = [...state, task];
  }

  Future<void> deleteTask(String id) async {
    await _repo.deleteTask(id);
    state = state.where((task) => task.id != id).toList();
  }
}

/// Homework Notifier (Starts empty without fake records)
final homeworkProvider =
    StateNotifierProvider<HomeworkNotifier, List<HomeworkModel>>((ref) {
      final repo = ref.watch(studyFlowRepositoryProvider);
      return HomeworkNotifier(repo);
    });

class HomeworkNotifier extends StateNotifier<List<HomeworkModel>> {
  final IStudyFlowRepository _repo;

  HomeworkNotifier(this._repo) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getHomework();
  }

  Future<void> toggleStatus(String id) async {
    final updated = state.map((hw) {
      if (hw.id == id) {
        final newStatus = hw.status == 'completed' ? 'pending' : 'completed';
        final updatedHw = hw.copyWith(status: newStatus);
        _repo.updateHomework(updatedHw);
        return updatedHw;
      }
      return hw;
    }).toList();
    state = updated;
  }

  Future<void> addHomework(HomeworkModel homework) async {
    await _repo.addHomework(homework);
    state = [...state, homework];
  }

  Future<void> deleteHomework(String id) async {
    await _repo.deleteHomework(id);
    state = state.where((hw) => hw.id != id).toList();
  }
}

/// Goals Notifier (Starts empty)
final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>((
  ref,
) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return GoalsNotifier(repo);
});

class GoalsNotifier extends StateNotifier<List<GoalModel>> {
  final IStudyFlowRepository _repo;

  GoalsNotifier(this._repo) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getGoals();
  }

  Future<void> incrementGoal(String id) async {
    final updated = state.map((goal) {
      if (goal.id == id) {
        final newCurrent = (goal.current + 1).clamp(0, goal.target);
        final updatedGoal = goal.copyWith(current: newCurrent);
        _repo.updateGoal(updatedGoal);
        return updatedGoal;
      }
      return goal;
    }).toList();
    state = updated;
  }

  Future<void> addGoal(GoalModel goal) async {
    await _repo.addGoal(goal);
    state = [...state, goal];
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    state = state.where((g) => g.id != id).toList();
  }
}

/// Habits Notifier (Starts empty)
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<HabitModel>>((
  ref,
) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return HabitsNotifier(repo);
});

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  final IStudyFlowRepository _repo;

  HabitsNotifier(this._repo) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getHabits();
  }

  Future<void> toggleHabit(String habitId, String dateKey) async {
    final updated = state.map((habit) {
      if (habit.id == habitId) {
        final currentVal = habit.history[dateKey] ?? false;
        final updatedHistory = Map<String, bool>.from(habit.history)
          ..[dateKey] = !currentVal;
        final updatedHabit = habit.copyWith(history: updatedHistory);
        _repo.updateHabit(updatedHabit);
        return updatedHabit;
      }
      return habit;
    }).toList();
    state = updated;
  }

  Future<void> addHabit(HabitModel habit) async {
    await _repo.addHabit(habit);
    state = [...state, habit];
  }

  Future<void> deleteHabit(String id) async {
    await _repo.deleteHabit(id);
    state = state.where((h) => h.id != id).toList();
  }
}

/// Notes Notifier (Starts empty)
final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>((
  ref,
) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return NotesNotifier(repo);
});

class NotesNotifier extends StateNotifier<List<NoteModel>> {
  final IStudyFlowRepository _repo;

  NotesNotifier(this._repo) : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getNotes();
  }

  Future<void> addNote(NoteModel note) async {
    await _repo.addNote(note);
    state = [...state, note];
  }

  Future<void> updateNote(NoteModel note) async {
    await _repo.addNote(note);
    state = state.map((entry) => entry.id == note.id ? note : entry).toList();
  }

  Future<void> deleteNote(String id) async {
    await _repo.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}

/// Stats Notifier
final statsProvider = StateNotifierProvider<StatsNotifier, StudyStats>((ref) {
  final repo = ref.watch(studyFlowRepositoryProvider);
  return StatsNotifier(repo);
});

class StatsNotifier extends StateNotifier<StudyStats> {
  final IStudyFlowRepository _repo;

  StatsNotifier(this._repo) : super(const StudyStats()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getStats();
  }

  Future<void> addStudyMinutes(int minutes) async {
    final updated = state.copyWith(
      studyTimeMinutes: state.studyTimeMinutes + minutes,
    );
    await _repo.updateStats(updated);
    state = updated;
  }
}

/// Pomodoro Settings Notifier
final pomodoroSettingsProvider =
    StateNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>((ref) {
      final repo = ref.watch(studyFlowRepositoryProvider);
      return PomodoroSettingsNotifier(repo);
    });

class PomodoroSettingsNotifier extends StateNotifier<PomodoroSettings> {
  final IStudyFlowRepository _repo;

  PomodoroSettingsNotifier(this._repo) : super(const PomodoroSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await _repo.getPomodoroSettings();
  }

  Future<void> updateSettings(PomodoroSettings settings) async {
    if (settings.study < 1 ||
        settings.study > 120 ||
        settings.breakDuration < 1 ||
        settings.breakDuration > 30 ||
        settings.longBreak < 1 ||
        settings.longBreak > 60) {
      throw ArgumentError('Invalid timer durations');
    }
    await _repo.updatePomodoroSettings(settings);
    state = settings;
  }
}
