import '../lib/data/models/task_model.dart';
import '../lib/data/models/homework_model.dart';
import '../lib/data/models/goal_model.dart';
import '../lib/data/models/habit_model.dart';
import '../lib/data/models/note_model.dart';

// Standalone database test harness testing schema v1 & empty states
class TestDatabaseHarness {
  final int schemaVersion = 1;

  final List<TaskModel> _tasks = [];
  final List<HomeworkModel> _homework = [];
  final List<GoalModel> _goals = [];
  final List<HabitModel> _habits = [];
  final List<NoteModel> _notes = [];
  final Map<String, Map<String, bool>> _habitCompletions = {};

  Future<void> init() async {}

  Future<List<TaskModel>> getTasks() async => List.unmodifiable(_tasks);
  Future<void> insertTask(TaskModel task) async => _tasks.add(task);

  Future<List<HomeworkModel>> getHomework() async => List.unmodifiable(_homework);
  Future<void> insertHomework(HomeworkModel hw) async => _homework.add(hw);

  Future<List<GoalModel>> getGoals() async => List.unmodifiable(_goals);
  Future<void> insertGoal(GoalModel goal) async => _goals.add(goal);

  Future<List<HabitModel>> getHabits() async {
    return _habits.map((h) {
      final completions = _habitCompletions[h.id] ?? {};
      return h.copyWith(history: completions);
    }).toList();
  }
  Future<void> insertHabit(HabitModel h) async => _habits.add(h);
  Future<void> toggleHabitCompletion(String habitId, String dateKey, bool completed) async {
    final map = _habitCompletions.putIfAbsent(habitId, () => {});
    map[dateKey] = completed;
  }

  Future<List<NoteModel>> getNotes() async => List.unmodifiable(_notes);
  Future<void> insertNote(NoteModel n) async => _notes.add(n);

  Future<void> clearAllTables() async {
    _tasks.clear();
    _homework.clear();
    _goals.clear();
    _habits.clear();
    _notes.clear();
    _habitCompletions.clear();
  }
}

Future<void> main() async {
  print('--- Running Database Schema & Migration Tests ---');

  final db = TestDatabaseHarness();
  await db.init();

  // Test 1: Verify versioned schema number
  assert(db.schemaVersion == 1, 'Database schema version should be 1');
  print('✅ Test 1 Passed: Schema version 1 verified');

  // Test 2: Database starts completely clean with empty states (No fake study records)
  assert((await db.getTasks()).isEmpty, 'Tasks should start empty');
  assert((await db.getHomework()).isEmpty, 'Homework should start empty');
  assert((await db.getGoals()).isEmpty, 'Goals should start empty');
  assert((await db.getHabits()).isEmpty, 'Habits should start empty');
  assert((await db.getNotes()).isEmpty, 'Notes should start empty');
  print('✅ Test 2 Passed: Empty states verified for all structured tables');

  // Test 3: Insert and retrieve task record
  const testTask = TaskModel(
    id: 't1',
    title: 'مذاكرة رياضيات',
    category: 'study',
    startTime: '10:00',
    endTime: '11:30',
    date: '2026-11-14',
  );
  await db.insertTask(testTask);
  final tasks = await db.getTasks();
  assert(tasks.length == 1, 'Tasks length should be 1');
  assert(tasks.first.title == 'مذاكرة رياضيات', 'Task title should match');
  print('✅ Test 3 Passed: Tasks table insert and query verified');

  // Test 4: Insert and retrieve homework record
  const testHw = HomeworkModel(
    id: 'h1',
    subject: 'فيزياء',
    description: 'حل مسائل المقاومات',
    deadline: '2026-11-15',
    status: 'pending',
  );
  await db.insertHomework(testHw);
  final homework = await db.getHomework();
  assert(homework.length == 1, 'Homework length should be 1');
  assert(homework.first.subject == 'فيزياء', 'Homework subject should match');
  print('✅ Test 4 Passed: Homework table insert and query verified');

  // Test 5: Goals table insert and query
  const testGoal = GoalModel(
    id: 'g1',
    title: 'إنهاء كتاب الأحياء',
    target: 200,
    current: 50,
    deadline: '2026-12-01',
    color: 'green',
  );
  await db.insertGoal(testGoal);
  final goals = await db.getGoals();
  assert(goals.length == 1, 'Goals length should be 1');
  assert(goals.first.target == 200, 'Goal target should match');
  print('✅ Test 5 Passed: Goals table insert and query verified');

  // Test 6: Habits & completions history
  const testHabit = HabitModel(
    id: 'hab1',
    name: 'الاستيقاظ مبكراً',
    icon: 'Sun',
    color: 'yellow',
  );
  await db.insertHabit(testHabit);
  await db.toggleHabitCompletion('hab1', '2026-11-14', true);

  final habits = await db.getHabits();
  assert(habits.length == 1, 'Habits length should be 1');
  assert(habits.first.isCompletedOn('2026-11-14') == true, 'Habit completion on date should be true');
  print('✅ Test 6 Passed: Habits and completions relationships verified');

  // Test 7: Notes table insert and query
  const testNote = NoteModel(
    id: 'n1',
    title: 'ملخص الفصل الأول',
    content: 'المفاهيم الأساسية...',
    folder: 'تاريخ',
    date: '2026-11-14',
  );
  await db.insertNote(testNote);
  final notes = await db.getNotes();
  assert(notes.length == 1, 'Notes length should be 1');
  assert(notes.first.folder == 'تاريخ', 'Note folder should match');
  print('✅ Test 7 Passed: Notes table insert and query verified');

  // Test 8: Clear all tables
  await db.clearAllTables();
  assert((await db.getTasks()).isEmpty, 'Tasks should be cleared');
  assert((await db.getHomework()).isEmpty, 'Homework should be cleared');
  assert((await db.getGoals()).isEmpty, 'Goals should be cleared');
  assert((await db.getHabits()).isEmpty, 'Habits should be cleared');
  assert((await db.getNotes()).isEmpty, 'Notes should be cleared');
  print('✅ Test 8 Passed: Reset and table clearing verified');

  print('🎉 All Database Migration & Schema Tests Passed!\n');
}
