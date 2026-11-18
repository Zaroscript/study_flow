import '../models/user_profile.dart';
import '../models/task_model.dart';
import '../models/homework_model.dart';
import '../models/goal_model.dart';
import '../models/habit_model.dart';
import '../models/note_model.dart';
import '../models/stats_model.dart';
import '../models/pomodoro_settings.dart';

abstract class IStudyFlowRepository {
  Future<Map<String, dynamic>?> getFeatureState(String key);
  Future<void> saveFeatureState(String key, Map<String, dynamic> value);
  Future<UserProfile?> getProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> clearProfile();

  Future<List<TaskModel>> getTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);

  Future<List<HomeworkModel>> getHomework();
  Future<void> addHomework(HomeworkModel homework);
  Future<void> updateHomework(HomeworkModel homework);
  Future<void> deleteHomework(String id);

  Future<List<GoalModel>> getGoals();
  Future<void> addGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);

  Future<List<HabitModel>> getHabits();
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> deleteHabit(String id);

  Future<List<NoteModel>> getNotes();
  Future<void> addNote(NoteModel note);
  Future<void> deleteNote(String id);

  Future<StudyStats> getStats();
  Future<void> updateStats(StudyStats stats);

  Future<PomodoroSettings> getPomodoroSettings();
  Future<void> updatePomodoroSettings(PomodoroSettings settings);

  Future<void> clearAllData();
}
