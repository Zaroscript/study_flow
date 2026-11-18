import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/data/local/database/sqlite_database.dart';
import 'package:study_flow/data/models/task_model.dart';
import 'package:study_flow/data/models/habit_model.dart';
import 'package:study_flow/data/models/note_model.dart';
import 'package:study_flow/data/models/user_profile.dart';
import 'package:study_flow/data/repositories/drift_study_flow_repository.dart';
import 'package:study_flow/features/common/providers/study_flow_state_provider.dart';
import 'package:study_flow/features/materials/providers/materials_provider.dart';
import 'package:study_flow/features/rewards/providers/rewards_provider.dart';

void main() {
  test('SQLite survives close/reopen, keeps habit history, upserts notes and fully resets', () async {
    final directory = await Directory.systemTemp.createTemp('enote-storage-');
    final file = File('${directory.path}/test.sqlite');
    EnoteDatabase? database;
    try {
      database = EnoteDatabase(NativeDatabase(file));
      await database.init();
      final repository = DriftStudyFlowRepository(database);
      await repository.saveProfile(
        const UserProfile(name: 'Student', grade: 'المرحلة الثانوية'),
      );
      await repository.addTask(
        const TaskModel(
          id: 'task',
          title: 'User text العربية',
          category: 'study',
          startTime: '09:00',
          endTime: '10:00',
          date: '2026-11-17',
        ),
      );
      await repository.addHabit(
        const HabitModel(
          id: 'habit',
          name: 'Read',
          history: {'2026-11-16': true},
        ),
      );
      await database.toggleHabitCompletion('habit', '2026-11-17', true);
      const note = NoteModel(
        id: 'note',
        title: 'My note',
        content: 'Original',
        date: '2026-11-17',
      );
      await repository.addNote(note);
      await repository.addNote(note.copyWith(content: 'Edited'));
      final library = MaterialsNotifier(repository);
      final rewards = RewardsNotifier(repository);
      library.addFolder('My real subject', 'blue');
      rewards.addXP(50);
      await library.flush();
      await rewards.flush();
      library.dispose();
      rewards.dispose();
      await database.close();
      database = EnoteDatabase(NativeDatabase(file));
      await database.init();
      final reopened = DriftStudyFlowRepository(database);
      expect((await reopened.getProfile())!.name, 'Student');
      expect((await reopened.getTasks()).single.title, 'User text العربية');
      expect((await reopened.getHabits()).single.history, {
        '2026-11-16': true,
        '2026-11-17': true,
      });
      expect((await reopened.getNotes()).single.content, 'Edited');
      expect(
        (await reopened.getFeatureState('materials'))!['folders'],
        hasLength(1),
      );
      expect((await reopened.getFeatureState('rewards'))!['currentXP'], 50);
      await reopened.clearAllData();
      await database.close();
      database = EnoteDatabase(NativeDatabase(file));
      await database.init();
      expect(await database.getProfile(), isNull);
      expect(await database.getTasks(), isEmpty);
      expect(await database.getHabits(), isEmpty);
      expect(await database.getNotes(), isEmpty);
      expect(await database.readDocument('materials'), isNull);
      expect(await database.readDocument('rewards'), isNull);
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'a mutation queued during hydration cannot overwrite saved tasks',
    () async {
      final database = EnoteDatabase(NativeDatabase.memory());
      await database.init();
      final repository = DriftStudyFlowRepository(database);
      const first = TaskModel(
        id: 'a',
        title: 'Saved',
        category: 'study',
        startTime: '09:00',
        endTime: '10:00',
        date: '2026-11-17',
      );
      await repository.addTask(first);
      final notifier = TasksNotifier(repository);
      await Future.wait([
        notifier.addTask(first.copyWith(id: 'b')),
        notifier.toggleTaskCompletion('a'),
      ]);
      expect(notifier.state.map((t) => t.id), ['a', 'b']);
      expect(notifier.state.first.completed, isTrue);
      expect((await repository.getTasks()).length, 2);
      notifier.dispose();
      await database.close();
    },
  );
}
