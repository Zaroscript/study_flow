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
import '../../../data/local/database/sqlite_database.dart';
import '../../../data/repositories/study_flow_repository.dart';
import '../../../data/repositories/drift_study_flow_repository.dart';
import 'persistent_notifier.dart';

final preferencesServiceProvider = Provider<IPreferencesService>(
  (ref) => throw StateError('Preferences must be initialized in bootstrap'),
);
final appDatabaseProvider = Provider<IAppDatabase>((ref) {
  final database = EnoteDatabase();
  ref.onDispose(() {
    database.close();
  });
  return database;
});
final studyFlowRepositoryProvider = Provider<IStudyFlowRepository>(
  (ref) => DriftStudyFlowRepository(ref.watch(appDatabaseProvider)),
);

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>(
  (ref) => ProfileNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class ProfileNotifier extends PersistentNotifier<UserProfile?> {
  final IStudyFlowRepository _repo;
  ProfileNotifier(this._repo) : super(null, _repo.getProfile);
  Future<void> saveProfile(UserProfile p) => change((_) async {
    await _repo.saveProfile(p);
    return p;
  });
  Future<void> clearProfile() => change((_) async {
    await _repo.clearProfile();
    return null;
  });
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>(
  (ref) => TasksNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class TasksNotifier extends PersistentNotifier<List<TaskModel>> {
  final IStudyFlowRepository _repo;
  TasksNotifier(this._repo) : super(const [], _repo.getTasks);
  Future<void> addTask(TaskModel item) => change((current) async {
    await _repo.addTask(item);
    return [...current.where((x) => x.id != item.id), item];
  });
  Future<void> deleteTask(String id) => change((current) async {
    await _repo.deleteTask(id);
    return current.where((x) => x.id != id).toList();
  });
  Future<void> toggleTaskCompletion(String id) => change((current) async {
    final next = <TaskModel>[];
    for (final task in current) {
      if (task.id == id) {
        final updated = task.copyWith(completed: !task.completed);
        await _repo.updateTask(updated);
        next.add(updated);
      } else {
        next.add(task);
      }
    }
    return next;
  });
}

final homeworkProvider =
    StateNotifierProvider<HomeworkNotifier, List<HomeworkModel>>(
      (ref) => HomeworkNotifier(ref.watch(studyFlowRepositoryProvider)),
    );

class HomeworkNotifier extends PersistentNotifier<List<HomeworkModel>> {
  final IStudyFlowRepository _repo;
  HomeworkNotifier(this._repo) : super(const [], _repo.getHomework);
  Future<void> addHomework(HomeworkModel item) => change((current) async {
    await _repo.addHomework(item);
    return [...current.where((x) => x.id != item.id), item];
  });
  Future<void> deleteHomework(String id) => change((current) async {
    await _repo.deleteHomework(id);
    return current.where((x) => x.id != id).toList();
  });
  Future<void> toggleStatus(String id) => change((current) async {
    final next = <HomeworkModel>[];
    for (final item in current) {
      if (item.id == id) {
        final updated = item.copyWith(
          status: item.status == 'completed' ? 'pending' : 'completed',
        );
        await _repo.updateHomework(updated);
        next.add(updated);
      } else {
        next.add(item);
      }
    }
    return next;
  });
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, List<GoalModel>>(
  (ref) => GoalsNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class GoalsNotifier extends PersistentNotifier<List<GoalModel>> {
  final IStudyFlowRepository _repo;
  GoalsNotifier(this._repo) : super(const [], _repo.getGoals);
  Future<void> addGoal(GoalModel item) => change((current) async {
    await _repo.addGoal(item);
    return [...current.where((x) => x.id != item.id), item];
  });
  Future<void> deleteGoal(String id) => change((current) async {
    await _repo.deleteGoal(id);
    return current.where((x) => x.id != id).toList();
  });
  Future<void> incrementGoal(String id) => change((current) async {
    final next = <GoalModel>[];
    for (final goal in current) {
      if (goal.id == id) {
        final updated = goal.copyWith(
          current: (goal.current + 1).clamp(0, goal.target),
        );
        await _repo.updateGoal(updated);
        next.add(updated);
      } else {
        next.add(goal);
      }
    }
    return next;
  });
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<HabitModel>>(
  (ref) => HabitsNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class HabitsNotifier extends PersistentNotifier<List<HabitModel>> {
  final IStudyFlowRepository _repo;
  HabitsNotifier(this._repo) : super(const [], _repo.getHabits);
  Future<void> addHabit(HabitModel item) => change((current) async {
    await _repo.addHabit(item);
    return [...current.where((x) => x.id != item.id), item];
  });
  Future<void> deleteHabit(String id) => change((current) async {
    await _repo.deleteHabit(id);
    return current.where((x) => x.id != id).toList();
  });
  Future<void> toggleHabit(String id, String day) => change((current) async {
    final next = <HabitModel>[];
    for (final habit in current) {
      if (habit.id == id) {
        final updated = habit.copyWith(
          history: {...habit.history, day: !(habit.history[day] ?? false)},
        );
        await _repo.updateHabit(updated);
        next.add(updated);
      } else {
        next.add(habit);
      }
    }
    return next;
  });
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<NoteModel>>(
  (ref) => NotesNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class NotesNotifier extends PersistentNotifier<List<NoteModel>> {
  final IStudyFlowRepository _repo;
  NotesNotifier(this._repo) : super(const [], _repo.getNotes);
  Future<void> addNote(NoteModel item) => change((current) async {
    await _repo.addNote(item);
    return [...current.where((x) => x.id != item.id), item];
  });
  Future<void> deleteNote(String id) => change((current) async {
    await _repo.deleteNote(id);
    return current.where((x) => x.id != id).toList();
  });
  Future<void> updateNote(NoteModel item) => change((current) async {
    await _repo.addNote(item);
    return current.map((x) => x.id == item.id ? item : x).toList();
  });
}

final statsProvider = StateNotifierProvider<StatsNotifier, StudyStats>(
  (ref) => StatsNotifier(ref.watch(studyFlowRepositoryProvider)),
);

class StatsNotifier extends PersistentNotifier<StudyStats> {
  final IStudyFlowRepository _repo;
  StatsNotifier(this._repo)
    : super(const StudyStats(focusScore: 0), _repo.getStats);
  Future<void> addStudyMinutes(int minutes) => change((current) async {
    if (minutes < 0) throw ArgumentError('Invalid minutes');
    final next = current.copyWith(
      studyTimeMinutes: current.studyTimeMinutes + minutes,
    );
    await _repo.updateStats(next);
    return next;
  });
}

final pomodoroSettingsProvider =
    StateNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>(
      (ref) => PomodoroSettingsNotifier(ref.watch(studyFlowRepositoryProvider)),
    );

class PomodoroSettingsNotifier extends PersistentNotifier<PomodoroSettings> {
  final IStudyFlowRepository _repo;
  PomodoroSettingsNotifier(this._repo)
    : super(const PomodoroSettings(), _repo.getPomodoroSettings);
  Future<void> updateSettings(PomodoroSettings settings) => change((_) async {
    if (settings.study < 1 ||
        settings.study > 120 ||
        settings.breakDuration < 1 ||
        settings.breakDuration > 30 ||
        settings.longBreak < 1 ||
        settings.longBreak > 60) {
      throw ArgumentError('Invalid timer durations');
    }
    await _repo.updatePomodoroSettings(settings);
    return settings;
  });
}
