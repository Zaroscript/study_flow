import '../models/user_profile.dart';
import '../models/task_model.dart';
import '../models/homework_model.dart';
import '../models/goal_model.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/stats_model.dart';
import '../models/pomodoro_settings.dart';
import 'study_flow_repository.dart';
import '../local/database/app_database.dart';

class DriftStudyFlowRepository implements IStudyFlowRepository {
  final IAppDatabase _database;

  PomodoroSettings _pomodoroSettings = const PomodoroSettings();
  int _studyMinutes = 0;

  DriftStudyFlowRepository(this._database);

  @override
  Future<UserProfile?> getProfile() async {
    return await _database.getProfile();
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _database.saveProfile(profile);
  }

  @override
  Future<void> clearProfile() async {
    await _database.clearProfile();
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    return await _database.getTasks();
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _database.insertTask(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _database.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _database.deleteTask(id);
  }

  @override
  Future<List<HomeworkModel>> getHomework() async {
    return await _database.getHomework();
  }

  @override
  Future<void> addHomework(HomeworkModel homework) async {
    await _database.insertHomework(homework);
  }

  @override
  Future<void> updateHomework(HomeworkModel homework) async {
    await _database.updateHomework(homework);
  }

  @override
  Future<void> deleteHomework(String id) async {
    await _database.deleteHomework(id);
  }

  @override
  Future<List<GoalModel>> getGoals() async {
    return await _database.getGoals();
  }

  @override
  Future<void> addGoal(GoalModel goal) async {
    await _database.insertGoal(goal);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await _database.updateGoal(goal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _database.deleteGoal(id);
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    return await _database.getHabits();
  }

  @override
  Future<void> addHabit(HabitModel habit) async {
    await _database.insertHabit(habit);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    await _database.updateHabit(habit);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _database.deleteHabit(id);
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    return await _database.getNotes();
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await _database.insertNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _database.deleteNote(id);
  }

  @override
  Future<StudyStats> getStats() async {
    final tasks = await _database.getTasks();
    final completed = tasks.where((t) => t.completed).length;
    final score = tasks.isEmpty
        ? 85
        : ((completed / tasks.length) * 100).round();

    return StudyStats(
      studyTimeMinutes: _studyMinutes,
      tasksCompleted: completed,
      focusScore: score > 0 ? score : 85,
    );
  }

  @override
  Future<void> updateStats(StudyStats stats) async {
    _studyMinutes = stats.studyTimeMinutes;
  }

  @override
  Future<PomodoroSettings> getPomodoroSettings() async {
    return _pomodoroSettings;
  }

  @override
  Future<void> updatePomodoroSettings(PomodoroSettings settings) async {
    _pomodoroSettings = settings;
  }

  @override
  Future<void> clearAllData() async {
    await _database.clearAllTables();
    _studyMinutes = 0;
    _pomodoroSettings = const PomodoroSettings();
  }
}
