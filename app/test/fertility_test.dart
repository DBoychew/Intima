import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/core/fertility.dart';

void main() {
  group('pregnancyChance', () {
    test('пик около овулацията, спад след нея', () {
      expect(pregnancyChance(0).level, FertilityLevel.veryHigh);
      expect(pregnancyChance(-1).level, FertilityLevel.veryHigh);
      expect(pregnancyChance(-2).level, FertilityLevel.high);
      expect(pregnancyChance(-3).level, FertilityLevel.moderate);
      expect(pregnancyChance(-4).level, FertilityLevel.low);
      expect(pregnancyChance(-5).level, FertilityLevel.low);
      expect(pregnancyChance(-6).level, FertilityLevel.negligible);
      expect(pregnancyChance(1).level, FertilityLevel.low);
      expect(pregnancyChance(2).level, FertilityLevel.negligible);
      expect(pregnancyChance(5).level, FertilityLevel.negligible);
    });

    test('денят на овулацията носи най-висок процент', () {
      expect(pregnancyChance(0).percentApprox,
          greaterThan(pregnancyChance(-3).percentApprox));
      expect(pregnancyChance(-6).percentApprox, 0);
      expect(pregnancyChance(2).percentApprox, 0);
    });
  });

  group('CycleSettings.daysFromOvulation', () {
    test('null без отбелязана менструация', () {
      expect(CycleSettings().daysFromOvulation(DateTime(2026, 6, 12)), isNull);
    });

    test('овулация ≈ 14 дни преди следващата менструация', () {
      final s = CycleSettings();
      s.cycleLength = 28;
      s.lastPeriodStart = DateTime(2026, 6, 1);
      // Следваща менструация ≈ 29 юни → овулация ≈ 15 юни.
      expect(s.daysFromOvulation(DateTime(2026, 6, 15)), 0);
      expect(s.daysFromOvulation(DateTime(2026, 6, 13)), -2);
      expect(s.daysFromOvulation(DateTime(2026, 6, 16)), 1);
    });

    test('избира най-близката овулация през няколко цикъла', () {
      final s = CycleSettings();
      s.cycleLength = 30;
      s.lastPeriodStart = DateTime(2026, 1, 1);
      // Овулациите са на ~16 ден от всеки цикъл; проверяваме 3-ти цикъл.
      final ov3 = DateTime(2026, 1, 1)
          .add(const Duration(days: 30 * 3 - 14)); // 3-та бъдеща овулация
      expect(s.daysFromOvulation(ov3), 0);
    });
  });
}
