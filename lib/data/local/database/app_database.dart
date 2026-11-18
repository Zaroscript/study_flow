import '../../models/user_profile.dart';
import '../../models/task_model.dart';
import '../../models/homework_model.dart';
import '../../models/goal_model.dart';
import '../../models/habit_model.dart';
import '../../models/note_model.dart';

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

  Future<Map<String, dynamic>?> readDocument(String key);
  Future<void> writeDocument(String key, Map<String, dynamic> value);

  // Danger zone
  Future<void> clearAllTables();
}
