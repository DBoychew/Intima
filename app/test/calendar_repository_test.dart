import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/cycle_settings.dart';
import 'package:intima/data/calendar_repository.dart';
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';

void main() {
  // Всеки тест има собствена in-memory база — предупреждението не важи.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late CalendarRepository repo;

  setUp(() async {
    await dbManager.openForTesting(IntimaDatabase(NativeDatabase.memory()));
    repo = CalendarRepository(dbManager);
    cycleSettings.resetToDefaults();
  });

  test('saveQuickLog: пълен запис и четене обратно по месец', () async {
    await repo.saveQuickLog(
      date: DateTime(2026, 6, 10),
      mood: 3,
      period: true,
      libido: 0.7,
      energy: 0.4,
      symptoms: ['ПМС', 'Главоболие'],
      moments: const [
        MomentDraft(arousal: 0.8, orgasms: 2, positions: ['Лъжички'], note: '💜'),
        MomentDraft(),
      ],
    );

    final data = await repo.month(2026, 6);
    expect(data.isPeriod(10), isTrue);
    expect(data.hasIntimacy(10), isTrue);
    expect(data.momentsByDay[10], hasLength(2));
    expect(data.logs[10]!.mood, 3);
    expect(decodeStringList(data.logs[10]!.symptoms), ['ПМС', 'Главоболие']);

    // Презапис на същия ден — моментите се заменят, не се трупат.
    await repo.saveQuickLog(
      date: DateTime(2026, 6, 10),
      mood: 4,
      period: false,
      libido: 0.5,
      energy: 0.5,
      symptoms: const [],
      moments: const [MomentDraft()],
    );
    final updated = await repo.month(2026, 6);
    expect(updated.isPeriod(10), isFalse);
    expect(updated.momentsByDay[10], hasLength(1));
    expect(updated.logs[10]!.mood, 4);
  });

  test('refreshLastPeriodStart намира началото на последната серия',
      () async {
    // Стар цикъл: 3–7 май; нов цикъл: 1–4 юни.
    for (final day in [3, 4, 5, 6, 7]) {
      await repo.saveQuickLog(
        date: DateTime(2026, 5, day),
        mood: null,
        period: true,
        libido: 0.5,
        energy: 0.5,
        symptoms: const [],
        moments: const [],
      );
    }
    for (final day in [1, 2, 3, 4]) {
      await repo.saveQuickLog(
        date: DateTime(2026, 6, day),
        mood: null,
        period: true,
        libido: 0.5,
        energy: 0.5,
        symptoms: const [],
        moments: const [],
      );
    }

    expect(cycleSettings.lastPeriodStart, DateTime(2026, 6, 1));
    // Предикция: 1 юни + 28 = 29 юни.
    expect(cycleSettings.nextPeriodStart, DateTime(2026, 6, 29));
  });

  test('без менструални дни предикциите се изключват', () async {
    await repo.saveQuickLog(
      date: DateTime(2026, 6, 10),
      mood: 2,
      period: false,
      libido: 0.5,
      energy: 0.5,
      symptoms: const [],
      moments: const [],
    );
    expect(cycleSettings.lastPeriodStart, isNull);
  });

  test('границата между месеци не чупи серията (28–31 май + 1 юни)',
      () async {
    for (final date in [
      DateTime(2026, 5, 30),
      DateTime(2026, 5, 31),
      DateTime(2026, 6, 1),
    ]) {
      await repo.saveQuickLog(
        date: date,
        mood: null,
        period: true,
        libido: 0.5,
        energy: 0.5,
        symptoms: const [],
        moments: const [],
      );
    }
    expect(cycleSettings.lastPeriodStart, DateTime(2026, 5, 30));
  });
}
