import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/core/notifications.dart';
import 'package:intima/data/calendar_repository.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';
import 'package:intima/main.dart' as app;
import 'package:intima/security/app_lock.dart';

/// Фаза 2 DoD на реално устройство: PIN заключване, персистентност на
/// настройките и пълно GDPR изтриване — през истинския UI.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> tapDigits(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.text(d).last);
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('PIN, заключване, персистентност и изтриване', (tester) async {
    // Чист старт — предишни ръчни сесии да не влияят.
    await const FlutterSecureStorage().deleteAll();
    final dbFile = await databaseFile();
    if (await dbFile.exists()) await dbFile.delete();

    app.main();
    // Boot екранът има безкраен spinner — pumpAndSettle би висял; чакаме
    // стъпките да минат и onboarding-ът да се появи.
    for (var i = 0;
        i < 120 && !tester.any(find.text('Само твое.'));
        i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    // --- Onboarding → календар ---
    expect(find.text('Само твое.'), findsOneWidget);
    await tester.tap(find.text('Продължи'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продължи'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Започни'));
    await tester.pumpAndSettle();
    expect(find.text('Юни 2026'), findsOneWidget);

    // --- Активиране на PIN от Настройки ---
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PIN заключване'));
    await tester.pumpAndSettle();
    expect(find.text('Избери PIN код'), findsOneWidget);
    await tapDigits(tester, '1234');
    expect(find.text('Потвърди PIN кода'), findsOneWidget);
    await tapDigits(tester, '1234');
    expect(appLock.pinEnabled, isTrue);

    // --- Заключване → грешен PIN → верен PIN ---
    appLock.lock();
    await tester.pumpAndSettle();
    expect(find.text('Въведи своя PIN'), findsOneWidget);

    await tapDigits(tester, '0000');
    expect(find.text('Грешен PIN — опитай отново'), findsOneWidget);

    await tapDigits(tester, '1234');
    expect(appLock.locked, isFalse);
    expect(find.text('Юни 2026'), findsOneWidget);

    // --- Настройките на цикъла се записват в криптираната база ---
    cycleSettings.cycleLength = 31;
    await tester.pump(const Duration(milliseconds: 500));
    final saved = await dbManager.db.loadCyclePrefs();
    expect(saved!.cycleLength, 31);

    // --- GDPR: Изтрий всичко ---
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Изтрий всичко'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // Още малко — елементът остава под долната навигация.
    await tester.drag(find.byType(ListView).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изтрий всичко'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изтрий'));
    await tester.pumpAndSettle();

    // Базата е нова: личните данни ги няма (само евентуални defaults).
    final after = await dbManager.db.loadCyclePrefs();
    expect(after?.cycleLength ?? 28, 28);
    expect(appLock.pinEnabled, isFalse);
    expect(find.text('Само твое.'), findsOneWidget);

    // --- Фаза 3: бърз запис на менструация → предикциите тръгват ---
    // Snackbar-ът от изтриването застъпва бутона — изчакваме да изчезне.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продължи'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продължи'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Започни'));
    await tester.pumpAndSettle();

    // Празна база → подсказка вместо прогноза.
    expect(find.textContaining('Следващ цикъл — около'), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Как си днес?'), findsOneWidget);
    await tester.tap(find.text('🥰'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.widgetWithText(FilterChip, 'Менструация'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Запази ✨'));
    await tester.pumpAndSettle();

    // Записът е в криптираната база и прогнозата е жива.
    final todayLog = await dbManager.db.dayLog(dateKey(DateTime.now()));
    expect(todayLog!.isPeriod, isTrue);
    expect(todayLog.mood, 4);
    expect(find.textContaining('Следващ цикъл — около'), findsOneWidget);

    // --- Фаза 4: дневник — създаване, търсене, изтриване ---
    await tester.tap(find.text('Дневник'));
    await tester.pumpAndSettle();
    // Изчакай snackbar-а „Записано ✨" — застъпва FAB-а.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton).last);
    await tester.pumpAndSettle();
    expect(find.text('Нов запис'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      'Интеграционен тест запис',
    );
    await tester.tap(find.text('🥰'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Запази'));
    await tester.pumpAndSettle();

    // Заглавие + preview на текста → поне едно съвпадение.
    expect(find.text('Интеграционен тест запис'), findsWidgets);

    // Търсене
    await tester.enterText(find.byType(TextField).first, 'интеграционен');
    await tester.pumpAndSettle();
    expect(find.text('Интеграционен тест запис'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    // Изтриване от редактора
    await tester.tap(find.text('Интеграционен тест запис').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изтрий'));
    await tester.pumpAndSettle();

    expect(find.text('Интеграционен тест запис'), findsNothing);
    expect(await dbManager.db.allDiaryEntries(), isEmpty);

    // --- Фаза 5: вечерното напомняне се насрочва ---
    await tester.tap(find.text('Настройки'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Вечерно напомняне'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Вечерно напомняне'));
    await tester.pumpAndSettle();
    expect(await Notifications.pendingCount(), greaterThan(0));
  });
}
