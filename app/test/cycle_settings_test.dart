import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';

void main() {
  group('CycleSettings', () {
    CycleSettings withData() =>
        CycleSettings()..lastPeriodStart = DateTime(2026, 6, 3);

    test('без отбелязана менструация няма предикции', () {
      final s = CycleSettings();
      expect(s.lastPeriodStart, isNull);
      expect(s.nextPeriodStart, isNull);
      expect(s.ovulation, isNull);
      expect(s.isFertile(DateTime(2026, 6, 17)), isFalse);
      expect(s.isPredictedPeriod(DateTime(2026, 7, 1)), isFalse);
    });

    test('предвижда следващата менструация по дължината на цикъла', () {
      final s = withData();
      expect(s.nextPeriodStart, DateTime(2026, 7, 1));

      s.cycleLength = 30;
      expect(s.nextPeriodStart, DateTime(2026, 7, 3));
    });

    test('ограничава стойностите до разумни граници', () {
      final s = CycleSettings();
      s.cycleLength = 50;
      expect(s.cycleLength, 40);
      s.cycleLength = 10;
      expect(s.cycleLength, 21);
      s.periodLength = 15;
      expect(s.periodLength, 10);
    });

    test('маркира очакваните дни от менструацията', () {
      final s = withData();
      expect(s.isPredictedPeriod(DateTime(2026, 7, 1)), isTrue);
      expect(s.isPredictedPeriod(DateTime(2026, 7, 5)), isTrue);
      expect(s.isPredictedPeriod(DateTime(2026, 7, 6)), isFalse);
      // Втори цикъл напред: 1 юли + 28 = 29 юли.
      expect(s.isPredictedPeriod(DateTime(2026, 7, 29)), isTrue);
    });

    test('фертилният прозорец е около овулацията', () {
      final s = withData();
      // Овулация ≈ 1 юли - 14 дни = 17 юни.
      expect(s.isFertile(DateTime(2026, 6, 17)), isTrue);
      expect(s.isFertile(DateTime(2026, 6, 15)), isTrue);
      expect(s.isFertile(DateTime(2026, 6, 12)), isFalse);
      // И за следващия цикъл: 29 юли - 14 = 15 юли.
      expect(s.isFertile(DateTime(2026, 7, 15)), isTrue);
    });

    test('reset връща и lastPeriodStart към null', () {
      final s = withData();
      s.resetToDefaults();
      expect(s.lastPeriodStart, isNull);
      expect(s.nextPeriodStart, isNull);
    });

    test('уведомява слушателите при промяна', () {
      final s = CycleSettings();
      var notified = 0;
      s.addListener(() => notified++);
      s.cycleLength = 29;
      s.periodLength = 4;
      s.lastPeriodStart = DateTime(2026, 6, 3);
      expect(notified, 3);
    });
  });
}
