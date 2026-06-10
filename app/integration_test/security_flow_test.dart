import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intima/core/cycle_settings.dart';
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

    await app.main();
    await tester.pumpAndSettle();

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
  });
}
