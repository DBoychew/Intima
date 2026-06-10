import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/data/database.dart';

void main() {
  group('IntimaDatabase DAO', () {
    late IntimaDatabase db;

    setUp(() => db = IntimaDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('дневник: създаване, подредба, редакция, изтриване', () async {
      final id = await db.insertDiaryEntry(DiaryEntriesCompanion.insert(
        title: 'Вечерята с Н.',
        body: 'Най-хубавата вечер от месеци.',
        date: DateTime(2026, 6, 28),
        mood: const Value(4),
        tags: const Value('["нас","вечеря"]'),
      ));
      await db.insertDiaryEntry(DiaryEntriesCompanion.insert(
        title: 'По-нов запис',
        body: '…',
        date: DateTime(2026, 6, 30),
      ));

      var all = await db.allDiaryEntries();
      expect(all, hasLength(2));
      expect(all.first.title, 'По-нов запис'); // най-новите първи

      final edited =
          all.last.copyWith(title: 'Вечерята с Н. 💜', mood: const Value(5));
      expect(await db.updateDiaryEntry(edited), isTrue);

      await db.deleteDiaryEntry(id);
      all = await db.allDiaryEntries();
      expect(all, hasLength(1));
    });

    test('дневен запис: upsert по дата, заявка по месец', () async {
      await db.upsertDayLog(DayLogsCompanion.insert(
        date: '2026-06-10',
        mood: const Value(3),
        isPeriod: const Value(true),
      ));
      // Втори запис за същия ден — презаписва, не дублира.
      await db.upsertDayLog(DayLogsCompanion.insert(
        date: '2026-06-10',
        mood: const Value(4),
        libido: const Value(0.7),
      ));
      await db.upsertDayLog(DayLogsCompanion.insert(date: '2026-07-01'));

      final day = await db.dayLog('2026-06-10');
      expect(day!.mood, 4);
      expect(await db.monthLogs('2026-06-'), hasLength(1));
      expect(await db.monthLogs('2026-07-'), hasLength(1));
    });

    test('интимни моменти: няколко на ден, замяна наведнъж', () async {
      await db.insertMoment(IntimateMomentsCompanion.insert(
        date: '2026-06-17',
        arousal: const Value(0.8),
        orgasms: const Value(2),
        positions: const Value('["Лъжички"]'),
      ));
      await db.insertMoment(
          IntimateMomentsCompanion.insert(date: '2026-06-17'));
      expect(await db.momentsOn('2026-06-17'), hasLength(2));

      await db.replaceMomentsOn('2026-06-17', [
        IntimateMomentsCompanion.insert(date: '2026-06-17'),
      ]);
      expect(await db.momentsOn('2026-06-17'), hasLength(1));
    });

    test('настройки на цикъла: единичен ред с upsert', () async {
      expect(await db.loadCyclePrefs(), isNull);
      await db.saveCyclePrefs(CyclePrefsCompanion.insert(
        id: const Value(1),
        cycleLength: const Value(30),
      ));
      await db.saveCyclePrefs(CyclePrefsCompanion.insert(
        id: const Value(1),
        cycleLength: const Value(31),
        periodLength: const Value(6),
      ));
      final prefs = await db.loadCyclePrefs();
      expect(prefs!.cycleLength, 31);
      expect(prefs.periodLength, 6);
    });
  });

  group('Криптиране на диска (DoD Фаза 2)', () {
    test('файлът няма plaintext header и не се отваря с грешен ключ',
        () async {
      final dir = await Directory.systemTemp.createTemp('intima_enc_test');
      final file = File('${dir.path}${Platform.pathSeparator}enc.db');
      final key = 'a1' * 32;

      final db = IntimaDatabase(openEncryptedDatabase(file, key));
      await db.insertDiaryEntry(DiaryEntriesCompanion.insert(
        title: 'тайна',
        body: 'много лично съдържание',
        date: DateTime(2026, 6, 10),
      ));
      await db.close();

      // 1) Некриптиран SQLite файл започва с "SQLite format 3".
      final header =
          String.fromCharCodes((await file.readAsBytes()).take(15));
      expect(header, isNot('SQLite format 3'));

      // 2) Грешен ключ → базата е нечетима.
      final wrongKey = IntimaDatabase(openEncryptedDatabase(file, 'b2' * 32));
      await expectLater(wrongKey.allDiaryEntries(), throwsA(anything));
      await wrongKey.close();

      // 3) Верният ключ чете данните обратно.
      final again = IntimaDatabase(openEncryptedDatabase(file, key));
      final entries = await again.allDiaryEntries();
      expect(entries.single.title, 'тайна');
      await again.close();

      await dir.delete(recursive: true);
    });
  });
}
