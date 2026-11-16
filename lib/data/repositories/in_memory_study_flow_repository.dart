import 'study_flow_repository.dart';
import '../models/user_profile.dart';
import '../models/task_model.dart';
import '../models/homework_model.dart';
import '../models/goal_model.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/stats_model.dart';
import '../models/pomodoro_settings.dart';
import '../models/initial_data.dart';

class InMemoryStudyFlowRepository implements IStudyFlowRepository {
  UserProfile? _profile = InitialData.initialProfile;
  List<TaskModel> _tasks = List.from(InitialData.tasks);
  List<HomeworkModel> _homework = List.from(InitialData.homework);
  List<GoalModel> _goals = List.from(InitialData.goals);
  List<HabitModel> _habits = List.from(InitialData.habits);
  List<NoteModel> _notes = List.from(InitialData.notes);
  StudyStats _stats = InitialData.stats;
  PomodoroSettings _pomodoro = InitialData.pomodoro;

  @override
  Future<UserProfile?> getProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> clearProfile() async {
    _profile = null;
  }

  @override
  Future<List<TaskModel>> getTasks() async => List.unmodifiable(_tasks);

  @override
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
  }

  @override
  Future<List<HomeworkModel>> getHomework() async =>
      List.unmodifiable(_homework);

  @override
  Future<void> addHomework(HomeworkModel homework) async {
    _homework.add(homework);
  }

  @override
  Future<void> updateHomework(HomeworkModel homework) async {
    final index = _homework.indexWhere((h) => h.id == homework.id);
    if (index != -1) {
      _homework[index] = homework;
    }
  }

  @override
  Future<void> deleteHomework(String id) async {
    _homework.removeWhere((h) => h.id == id);
  }

  @override
  Future<List<GoalModel>> getGoals() async => List.unmodifiable(_goals);

  @override
  Future<void> addGoal(GoalModel goal) async {
    _goals.add(goal);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<List<HabitModel>> getHabits() async => List.unmodifiable(_habits);

  @override
  Future<void> addHabit(HabitModel habit) async {
    _habits.add(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
  }

  @override
  Future<List<NoteModel>> getNotes() async => List.unmodifiable(_notes);

  @override
  Future<void> addNote(NoteModel note) async {
    _notes.removeWhere((entry) => entry.id == note.id);
    _notes.add(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
  }

  @override
  Future<StudyStats> getStats() async => _stats;

  @override
  Future<void> updateStats(StudyStats stats) async {
    _stats = stats;
  }

  @override
  Future<PomodoroSettings> getPomodoroSettings() async => _pomodoro;

  @override
  Future<void> updatePomodoroSettings(PomodoroSettings settings) async {
    _pomodoro = settings;
  }

  @override
  Future<void> clearAllData() async {
    _profile = null;
    _tasks = List.from(InitialData.tasks);
    _homework = List.from(InitialData.homework);
    _goals = List.from(InitialData.goals);
    _habits = List.from(InitialData.habits);
    _notes = List.from(InitialData.notes);
    _stats = InitialData.stats;
    _pomodoro = InitialData.pomodoro;
  }
}
