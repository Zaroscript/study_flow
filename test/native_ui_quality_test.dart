import 'test_app.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_flow/core/utils/app_validators.dart';
import 'package:study_flow/core/widgets/app_button.dart';
import 'package:study_flow/core/widgets/app_progress_bar.dart';
import 'package:study_flow/core/widgets/page_header.dart';
import 'package:study_flow/data/models/note_model.dart';
import 'package:study_flow/data/repositories/in_memory_study_flow_repository.dart';
import 'package:study_flow/features/common/providers/study_flow_state_provider.dart';
import 'package:study_flow/features/notes/screens/notes_screen.dart';

void main() {
  test('time, date and goal numeric validation rejects invalid input', () {
    expect(AppValidators.required('  '), isNotNull);
    expect(AppValidators.integer('0', min: 1), isNotNull);
    expect(AppValidators.integer('121', min: 1, max: 120), isNotNull);
    expect(AppValidators.integer('25', min: 1, max: 120), isNull);
    expect(AppValidators.validTimeRange('09:00', '10:30'), isTrue);
    expect(AppValidators.validTimeRange('10:30', '09:00'), isFalse);
    expect(AppValidators.validTimeRange('09:00', '09:00'), isFalse);
    expect(AppValidators.time('12:99'), isNotNull);
    expect(AppValidators.date('2026-02-31'), isNotNull);
    expect(AppValidators.date('2026-11-15'), isNull);
  });

  test('editing a note replaces its record without duplicates', () async {
    final repo = InMemoryStudyFlowRepository();
    const note = NoteModel(
      id: 'quality-note',
      title: 'First',
      content: 'Original',
      date: '2026-11-15',
    );
    await repo.addNote(note);
    await repo.addNote(note.copyWith(content: 'Edited full content'));
    final matches = (await repo.getNotes())
        .where((entry) => entry.id == note.id)
        .toList();
    expect(matches, hasLength(1));
    expect(matches.single.content, 'Edited full content');
  });

  testWidgets('header and action fit a narrow screen at 200% text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      testApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 800),
              textScaler: TextScaler.linear(2),
            ),
            child: SizedBox(
              width: 320,
              child: PageHeader(
                title: 'الأهداف الدراسية طويلة العنوان',
                description: 'وصف واضح يتمدد مع حجم الخط',
                action: AppButton(text: 'إضافة هدف جديد', onPressed: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('إضافة هدف جديد'), findsOneWidget);
  });

  testWidgets(
    'loading buttons reject repeated taps and preserve a 48dp target',
    (tester) async {
      var count = 0;
      await tester.pumpWidget(
        testApp(
          home: Scaffold(
            body: AppButton(
              text: 'حفظ',
              isLoading: true,
              onPressed: () => count++,
            ),
          ),
        ),
      );
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
      expect(
        tester.getSize(find.byType(FilledButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(count, 0);
    },
  );

  testWidgets('one-percent progress is not displayed as complete', (
    tester,
  ) async {
    await tester.pumpWidget(
      testApp(home: const Scaffold(body: AppProgressBar(progress: .01))),
    );
    await tester.pumpAndSettle();
    final bar = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(bar.widthFactor, .01);
  });

  testWidgets(
    'notes can be created, searched and opened with their full content',
    (tester) async {
      final repo = InMemoryStudyFlowRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [studyFlowRepositoryProvider.overrideWithValue(repo)],
          child: testApp(home: const Scaffold(body: NotesScreen())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ملاحظة جديدة'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'اختبار الملاحظة',
      );
      final content = List.filled(20, 'محتوى طويل يجب الحفاظ عليه.').join('\n');
      await tester.enterText(find.byType(TextFormField).at(2), content);
      await tester.ensureVisible(find.text('حفظ الملاحظة'));
      await tester.tap(find.text('حفظ الملاحظة'));
      await tester.pumpAndSettle();
      final saved = (await repo.getNotes()).singleWhere(
        (note) => note.title == 'اختبار الملاحظة',
      );
      expect(saved.content, content);
      await tester.enterText(find.byType(TextField).first, 'اختبار');
      await tester.pumpAndSettle();
      await tester.tap(find.text('فتح وتعديل'));
      await tester.pumpAndSettle();
      final editor = tester.widget<TextFormField>(
        find.byType(TextFormField).at(2),
      );
      expect(editor.controller!.text, content);
      expect(tester.takeException(), isNull);
    },
  );
}
