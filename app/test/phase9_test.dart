import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/journaling.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/insights_repository.dart';

DayLogRow log(String date,
        {int? mood, double? libido, double? energy, bool period = false}) =>
    DayLogRow(
      date: date,
      mood: mood,
      libido: libido,
      energy: energy,
      isPeriod: period,
      symptoms: '[]',
    );

IntimateMomentRow moment(String date) => IntimateMomentRow(
      id: 0,
      date: date,
      arousal: 0.6,
      orgasms: 1,
      positions: '[]',
      note: '',
    );

void main() {
  group('computeCorrelations (Фаза 9, локално)', () {
    bool fertile15to17(DateTime d) => d.day >= 15 && d.day <= 17;

    test('настроение по-добро във фертилните дни + дял интимност', () {
      final logs = [
        log('2026-06-16', mood: 4),
        log('2026-06-17', mood: 4),
        log('2026-06-02', mood: 2),
        log('2026-06-03', mood: 2),
      ];
      final moments = [moment('2026-06-16'), moment('2026-06-02')];
      final c = computeCorrelations(
          logs: logs, moments: moments, isFertile: fertile15to17);
      expect(c.moodFertileDelta, closeTo(2.0, 0.001));
      expect(c.intimacyInFertilePct, 0.5);
    });

    test('либидо и енергия вървят заедно → тенденция +1', () {
      final logs = [
        log('2026-06-01', libido: 0.2, energy: 0.2),
        log('2026-06-02', libido: 0.4, energy: 0.5),
        log('2026-06-03', libido: 0.8, energy: 0.7),
        log('2026-06-04', libido: 0.9, energy: 0.95),
      ];
      final c = computeCorrelations(
          logs: logs, moments: const [], isFertile: (_) => false);
      expect(c.libidoEnergyTrend, 1);
    });

    test('празни данни → няма корелации', () {
      final c = computeCorrelations(
          logs: const [], moments: const [], isFertile: (_) => false);
      expect(c.hasAny, isFalse);
    });
  });

  group('suggestPromptKind (Фаза 9)', () {
    test('менструацията надделява над фазата', () {
      expect(suggestPromptKind(isPeriod: true, daysFromOvulation: 0),
          PromptKind.menstrual);
    });

    test('фаза по дни от овулацията', () {
      expect(suggestPromptKind(daysFromOvulation: 0), PromptKind.ovulation);
      expect(suggestPromptKind(daysFromOvulation: -1), PromptKind.ovulation);
      expect(suggestPromptKind(daysFromOvulation: 1), PromptKind.ovulation);
      expect(suggestPromptKind(daysFromOvulation: -3), PromptKind.follicular);
      expect(suggestPromptKind(daysFromOvulation: 5), PromptKind.luteal);
      expect(suggestPromptKind(daysFromOvulation: null), PromptKind.neutral);
    });
  });
}
