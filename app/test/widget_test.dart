import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';
import 'package:intima/data/diary_repository.dart';
import 'package:intima/features/calendar/calendar_screen.dart';
import 'package:intima/features/diary/diary_editor_screen.dart';
import 'package:intima/features/diary/diary_screen.dart';
import 'package:intima/main.dart';
import 'package:intima/theme/app_theme.dart';

void main() {
  testWidgets('Onboarding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IntimaApp());
    await tester.pumpAndSettle();

    expect(find.text('Само твое.'), findsOneWidget);
    expect(find.text('Продължи'), findsOneWidget);
  });

  testWidgets('Calendar arrows move across year boundaries', (
    WidgetTester tester,
  ) async {
    // Реален календар = реална база; in-memory с малко период-дни.
    await dbManager.openForTesting(IntimaDatabase(NativeDatabase.memory()));
    cycleSettings.resetToDefaults();
    for (final day in ['2026-06-03', '2026-06-04', '2026-06-05']) {
      await dbManager.db.upsertDayLog(
        DayLogsCompanion.insert(date: day, isPeriod: const Value(true)),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: CalendarScreen(todayOverride: DateTime(2026, 6, 30)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Юни 2026'), findsOneWidget);

    // Легендата и прогнозата са под мрежата — скролваме до тях.
    await tester.scrollUntilVisible(
      find.text('Очаквана'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Очаквана'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Следващ цикъл — около'),
      100,
      scrollable: find.byType(Scrollable).first,
    );

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
    }
    expect(find.text('Януари 2027'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    expect(find.text('Декември 2026'), findsOneWidget);
  });

  testWidgets('Diary editor: шаблони, тагове и действия', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const DiaryEditorScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Добави снимка'), findsOneWidget);
    expect(find.text('Нов таг'), findsOneWidget);

    // Шаблонът с начален текст го вмъква при празно поле.
    await tester.tap(find.text('Благодарност'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Днес съм благодарна за'), findsOneWidget);

    await tester.tap(find.text('Нов таг'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'пътуване');
    await tester.tap(find.text('Добави'));
    await tester.pumpAndSettle();

    expect(find.text('#пътуване'), findsOneWidget);
  });

  testWidgets('Editor: тап отваря viewer, X иска потвърждение', (
    WidgetTester tester,
  ) async {
    final row = DiaryEntryRow(
      id: 1,
      title: 'Тест',
      body: 'Текст',
      date: DateTime(2026, 6, 10),
      mood: 3,
      tags: '[]',
      hasPhoto: true,
      photos: '["/няма/такава.png"]',
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: DiaryEditorScreen(initial: row)),
    );
    await tester.pumpAndSettle();

    // Тап върху thumbnail-а отваря пълноекранния viewer.
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // X иска потвърждение; „Отказ" запазва снимката.
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Премахване на снимката?'), findsOneWidget);
    await tester.tap(find.text('Отказ'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Diary списък: записи от базата, търсене и спомен', (
    WidgetTester tester,
  ) async {
    await dbManager.openForTesting(IntimaDatabase(NativeDatabase.memory()));
    await diaryRepository.create(
      title: 'Вечерята с Н.',
      body: 'Най-хубавата вечер от месеци.',
      date: DateTime(2026, 6, 8),
      mood: 4,
      tags: ['нас'],
      photos: const [],
    );
    await diaryRepository.create(
      title: 'Стар спомен',
      body: 'Отдавнашен запис.',
      date: DateTime(2026, 3, 1),
      mood: 2,
      tags: const [],
      photos: const [],
    );

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const DiaryScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Вечерята с Н.'), findsOneWidget);
    expect(find.text('Спомен от преди време'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'нас');
    await tester.pumpAndSettle();
    expect(find.text('Вечерята с Н.'), findsOneWidget);
    expect(find.text('Стар спомен'), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'няма такова');
    await tester.pumpAndSettle();
    expect(find.textContaining('Нищо не открихме'), findsOneWidget);
  });
}
