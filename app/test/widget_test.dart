import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';
import 'package:intima/features/calendar/calendar_screen.dart';
import 'package:intima/features/diary/diary_editor_screen.dart';
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

  testWidgets('Diary editor shows clear photo and tag actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const DiaryEditorScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Добави снимка'), findsOneWidget);
    expect(find.text('Нов таг'), findsOneWidget);

    await tester.tap(find.text('Добави снимка'));
    await tester.pump();

    expect(find.text('Премахни снимка'), findsOneWidget);

    await tester.tap(find.text('Нов таг'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'пътуване');
    await tester.tap(find.text('Добави'));
    await tester.pumpAndSettle();

    expect(find.text('#пътуване'), findsOneWidget);
  });
}
