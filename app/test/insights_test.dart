import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/data/calendar_repository.dart' show dateKey;
import 'package:intima/data/database.dart';
import 'package:intima/data/insights_repository.dart';

DayLogRow log(
  String date, {
  int? mood,
  double? libido,
  double? energy,
  bool period = false,
  String symptoms = '[]',
}) =>
    DayLogRow(
      date: date,
      mood: mood,
      libido: libido,
      energy: energy,
      isPeriod: period,
      symptoms: symptoms,
    );

IntimateMomentRow moment(String date,
        {int orgasms = 1, String positions = '[]'}) =>
    IntimateMomentRow(
      id: 0,
      date: date,
      arousal: 0.6,
      orgasms: orgasms,
      positions: positions,
      note: '',
    );

void main() {
  group('periodRunStarts и cycleLengths', () {
    test('намира началата на сериите, вкл. през граница на месец', () {
      final starts = periodRunStarts([
        log('2026-03-30', period: true),
        log('2026-03-31', period: true),
        log('2026-04-01', period: true),
        log('2026-04-27', period: true),
        log('2026-04-28', period: true),
        log('2026-05-26', period: true),
      ]);
      expect(starts, [
        DateTime(2026, 3, 30),
        DateTime(2026, 4, 27),
        DateTime(2026, 5, 26),
      ]);
      expect(cycleLengths(starts), [28, 29]);
    });

    test('игнорира неправдоподобни интервали (пропуснат месец)', () {
      final starts = [
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 8), // 7 дни — твърде кратко
        DateTime(2026, 4, 1), // 83 дни — пропуснато отбелязване
        DateTime(2026, 4, 29),
      ];
      expect(cycleLengths(starts), [28]);
    });

    test('статистика: средно, мин и макс', () {
      final stats = computeCycleStats([
        DateTime(2026, 1, 1),
        DateTime(2026, 1, 29), // 28
        DateTime(2026, 2, 28), // 30
      ]);
      expect(stats.count, 2);
      expect(stats.average, 29);
      expect(stats.min, 28);
      expect(stats.max, 30);
    });
  });

  group('phaseOf', () {
    final starts = [DateTime(2026, 5, 1)];
    CyclePhase? phase(int day) => phaseOf(
          DateTime(2026, 5, day),
          starts,
          cycleLength: 28,
          periodLength: 5,
        );

    test('фазите следват деня от цикъла', () {
      expect(phase(1), CyclePhase.menstrual); // ден 0
      expect(phase(5), CyclePhase.menstrual); // ден 4
      expect(phase(6), CyclePhase.follicular); // ден 5
      expect(phase(13), CyclePhase.ovulation); // ден 12 (овулация 14±2)
      expect(phase(17), CyclePhase.ovulation); // ден 16
      expect(phase(18), CyclePhase.luteal); // ден 17
      expect(phase(28), CyclePhase.luteal); // ден 27
      expect(phase(29), isNull); // отвъд цикъла — не гадаем
    });

    test('без начало преди датата няма фаза', () {
      expect(
        phaseOf(DateTime(2026, 4, 30), starts,
            cycleLength: 28, periodLength: 5),
        isNull,
      );
    });
  });

  group('computeInsights', () {
    test('пълна картина: цикъл, настроение, тренд, рекап', () {
      final now = DateTime(2026, 6, 12);
      final data = computeInsights(
        logs: [
          log('2026-04-15', period: true, mood: 1),
          log('2026-04-16', period: true, mood: 2),
          log('2026-05-13', period: true, mood: 1,
              symptoms: '["ПМС","Главоболие"]'),
          log('2026-05-20', mood: 3, libido: 0.5, energy: 0.6),
          log('2026-05-27', mood: 4, libido: 0.8,
              symptoms: '["ПМС"]'), // ден 14 — овулация
          log('2026-06-05', mood: 4, libido: 0.7, energy: 0.9),
        ],
        moments: [
          moment('2026-05-27', orgasms: 2, positions: '["Лъжички"]'),
          moment('2026-06-05', positions: '["Лъжички","Отгоре"]'),
          moment('2026-06-08', positions: '["Отгоре"]'),
          moment('2026-06-08', positions: '["Отгоре"]'),
        ],
        entries: [
          DiaryEntryRow(
            id: 1,
            title: 'Запис',
            body: '…',
            date: DateTime(2026, 6, 1),
            mood: 4,
            tags: '[]',
            hasPhoto: false,
            photos: '[]',
            videos: '[]',
            audios: '[]',
          ),
        ],
        now: now,
        fallbackCycleLength: 28,
        periodLength: 5,
      );

      expect(data.isEmpty, isFalse);
      expect(data.cycle.count, 1);
      expect(data.cycle.average, 28);

      // Менструалните дни взимат менструалната фаза.
      expect(data.moodByPhase[CyclePhase.menstrual], closeTo(4 / 3, 0.001));
      expect(data.moodSamples[CyclePhase.menstrual], 3);
      // 20 май е ден 7 → фоликуларна; 27 май е ден 14 → овулация.
      expect(data.moodByPhase[CyclePhase.follicular], 3);
      expect(data.moodByPhase[CyclePhase.ovulation], 4);

      // Трендът покрива 6 месеца и завършва с текущия.
      expect(data.trend.length, 6);
      expect(data.trend.last.month, DateTime(2026, 6));
      expect(data.trend.last.avgLibido, 0.7);
      expect(data.trend.last.moments, 3);
      final may = data.trend[4];
      expect(may.avgLibido, closeTo(0.65, 0.001));
      expect(may.moments, 1);

      // Рекапитулация на последните 30 дни (от 13 май нататък).
      expect(data.recap.diaryEntries, 1);
      expect(data.recap.moments, 4);
      expect(data.recap.orgasms, 5);
      expect(data.recap.topSymptom, 'ПМС');
      expect(data.recap.topPosition, 'Отгоре');
    });

    test('празна база дава празни инсайти', () {
      final data = computeInsights(
        logs: const [],
        moments: const [],
        entries: const [],
        now: DateTime(2026, 6, 12),
        fallbackCycleLength: 28,
        periodLength: 5,
      );
      expect(data.isEmpty, isTrue);
      expect(data.cycle.count, 0);
      expect(data.recap.hasData, isFalse);
    });

    test('с една менструация фазите ползват настройката за дължина', () {
      final data = computeInsights(
        logs: [
          log('2026-06-01', period: true, mood: 1),
          log('2026-06-08', mood: 4), // ден 7 → фоликуларна
        ],
        moments: const [],
        entries: const [],
        now: DateTime(2026, 6, 12),
        fallbackCycleLength: 28,
        periodLength: 5,
      );
      expect(data.cycle.count, 0);
      expect(data.moodByPhase[CyclePhase.follicular], 4);
    });
  });

  test('InsightsRepository чете реалната база', () async {
    final db = IntimaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final today = DateTime(2026, 6, 12);
    await db.upsertDayLog(DayLogsCompanion.insert(
      date: dateKey(today),
      mood: const Value(4),
      libido: const Value(0.7),
    ));
    final data = computeInsights(
      logs: await db.allDayLogs(),
      moments: await db.allMoments(),
      entries: await db.allDiaryEntries(),
      now: today,
      fallbackCycleLength: 28,
      periodLength: 5,
    );
    expect(data.isEmpty, isFalse);
    expect(data.recap.avgMood, 4);
  });
}
