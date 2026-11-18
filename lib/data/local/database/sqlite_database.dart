import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../models/user_profile.dart';
import '../../models/task_model.dart';
import '../../models/homework_model.dart';
import '../../models/goal_model.dart';
import '../../models/habit_model.dart';
import '../../models/note_model.dart';
import 'app_database.dart';
import 'record_table.dart';
part 'sqlite_database.g.dart';

/// SQLite commits precede visible success. No production in-memory fallback.
@DriftDatabase(tables: [AppRecords])
class EnoteDatabase extends _$EnoteDatabase implements IAppDatabase {
  EnoteDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'enote'));
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = FULL');
    },
  );
  @override
  Future<void> init() async {
    await customSelect('SELECT 1').get();
  }

  Future<List<Map<String, dynamic>>> _read(String kind) async {
    final rows = await (select(
      appRecords,
    )..where((r) => r.kind.equals(kind))).get();
    return rows
        .map((r) => jsonDecode(r.payload) as Map<String, dynamic>)
        .toList();
  }

  Future<void> _put(String kind, String id, Map<String, dynamic> json) =>
      transaction(() async {
        await into(appRecords).insertOnConflictUpdate(
          AppRecordsCompanion.insert(
            kind: kind,
            recordId: id,
            payload: jsonEncode(json),
          ),
        );
      });
  Future<void> _remove(String kind, String id) => transaction(() async {
    await (delete(
      appRecords,
    )..where((r) => r.kind.equals(kind) & r.recordId.equals(id))).go();
  });
  @override
  Future<UserProfile?> getProfile() async {
    final rows = await _read('profile');
    return rows.isEmpty ? null : UserProfile.fromJson(rows.single);
  }

  @override
  Future<void> saveProfile(UserProfile p) =>
      _put('profile', 'profile', p.toJson());
  @override
  Future<void> updateProfile(UserProfile p) => saveProfile(p);
  @override
  Future<void> clearProfile() => _remove('profile', 'profile');
  @override
  Future<List<TaskModel>> getTasks() async =>
      (await _read('tasks')).map(TaskModel.fromJson).toList();
  @override
  Future<void> insertTask(TaskModel t) => _put('tasks', t.id, t.toJson());
  @override
  Future<void> updateTask(TaskModel t) => insertTask(t);
  @override
  Future<void> deleteTask(String id) => _remove('tasks', id);
  @override
  Future<List<HomeworkModel>> getHomework() async =>
      (await _read('homework')).map(HomeworkModel.fromJson).toList();
  @override
  Future<void> insertHomework(HomeworkModel h) =>
      _put('homework', h.id, h.toJson());
  @override
  Future<void> updateHomework(HomeworkModel h) => insertHomework(h);
  @override
  Future<void> deleteHomework(String id) => _remove('homework', id);
  @override
  Future<List<GoalModel>> getGoals() async =>
      (await _read('goals')).map(GoalModel.fromJson).toList();
  @override
  Future<void> insertGoal(GoalModel g) => _put('goals', g.id, g.toJson());
  @override
  Future<void> updateGoal(GoalModel g) => insertGoal(g);
  @override
  Future<void> deleteGoal(String id) => _remove('goals', id);
  @override
  Future<List<HabitModel>> getHabits() async =>
      (await _read('habits')).map(HabitModel.fromJson).toList();
  @override
  Future<void> insertHabit(HabitModel h) => _put('habits', h.id, h.toJson());
  @override
  Future<void> updateHabit(HabitModel h) => insertHabit(h);
  @override
  Future<void> deleteHabit(String id) => _remove('habits', id);
  @override
  Future<void> toggleHabitCompletion(
    String id,
    String dateKey,
    bool completed,
  ) => transaction(() async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == id);
    if (index < 0) throw StateError('Habit not found');
    final habit = habits[index];
    await updateHabit(
      habit.copyWith(history: {...habit.history, dateKey: completed}),
    );
  });
  @override
  Future<List<NoteModel>> getNotes() async =>
      (await _read('notes')).map(NoteModel.fromJson).toList();
  @override
  Future<void> insertNote(NoteModel n) => _put('notes', n.id, n.toJson());
  @override
  Future<void> deleteNote(String id) => _remove('notes', id);
  @override
  Future<Map<String, dynamic>?> readDocument(String key) async {
    final rows = await (select(
      appRecords,
    )..where((r) => r.kind.equals('settings') & r.recordId.equals(key))).get();
    return rows.isEmpty
        ? null
        : jsonDecode(rows.single.payload) as Map<String, dynamic>;
  }

  @override
  Future<void> writeDocument(String key, Map<String, dynamic> value) =>
      _put('settings', key, value);
  @override
  Future<void> clearAllTables() => transaction(() async {
    await delete(appRecords).go();
  });
}
