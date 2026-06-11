import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Запис в дневника.
@DataClassName('DiaryEntryRow')
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mood => integer().nullable()();

  /// JSON списък от тагове, напр. `["нас","вечеря"]`.
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  BoolColumn get hasPhoto => boolean().withDefault(const Constant(false))();

  /// Път до снимката в private storage на приложението (v2).
  /// Заменена от [photos] във v3 — пазим я само заради миграцията.
  TextColumn get photoPath => text().nullable()();

  /// JSON списък с пътища до снимките в private storage (v3).
  TextColumn get photos => text().withDefault(const Constant('[]'))();
}

/// Дневен запис от календара — най-много един на дата.
@DataClassName('DayLogRow')
class DayLogs extends Table {
  /// Ключ 'YYYY-MM-DD' — избягва часови зони и улеснява заявки по месец.
  TextColumn get date => text()();
  IntColumn get mood => integer().nullable()();
  RealColumn get libido => real().nullable()();
  RealColumn get energy => real().nullable()();
  BoolColumn get isPeriod => boolean().withDefault(const Constant(false))();

  /// JSON списък от симптоми, напр. `["ПМС","Главоболие"]`.
  TextColumn get symptoms => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Интимен момент — на ден може да има няколко.
@DataClassName('IntimateMomentRow')
class IntimateMoments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  RealColumn get arousal => real().withDefault(const Constant(0.6))();
  IntColumn get orgasms => integer().withDefault(const Constant(1))();

  /// JSON списък от пози.
  TextColumn get positions => text().withDefault(const Constant('[]'))();
  TextColumn get note => text().withDefault(const Constant(''))();
}

/// Настройки на цикъла — единичен ред с id = 1.
@DataClassName('CyclePrefsRow')
class CyclePrefs extends Table {
  IntColumn get id => integer()();
  IntColumn get cycleLength => integer().withDefault(const Constant(28))();
  IntColumn get periodLength => integer().withDefault(const Constant(5))();
  BoolColumn get notifyPeriod => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyOvulation =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastPeriodStart => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [DiaryEntries, DayLogs, IntimateMoments, CyclePrefs])
class IntimaDatabase extends _$IntimaDatabase {
  IntimaDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(diaryEntries, diaryEntries.photoPath);
          }
          if (from < 3) {
            await m.addColumn(diaryEntries, diaryEntries.photos);
            // Единичната снимка от v2 става списък с един елемент.
            await customStatement(
              'UPDATE diary_entries SET photos = json_array(photo_path) '
              'WHERE photo_path IS NOT NULL',
            );
          }
        },
      );

  // --- Дневник ---
  Future<List<DiaryEntryRow>> allDiaryEntries() =>
      (select(diaryEntries)..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> insertDiaryEntry(DiaryEntriesCompanion entry) =>
      into(diaryEntries).insert(entry);

  Future<bool> updateDiaryEntry(DiaryEntryRow entry) =>
      update(diaryEntries).replace(entry);

  Future<int> deleteDiaryEntry(int id) =>
      (delete(diaryEntries)..where((t) => t.id.equals(id))).go();

  // --- Календар ---
  Future<DayLogRow?> dayLog(String date) =>
      (select(dayLogs)..where((t) => t.date.equals(date))).getSingleOrNull();

  /// Записите за месец — ключовете започват с 'YYYY-MM-'.
  Future<List<DayLogRow>> monthLogs(String yearMonthPrefix) =>
      (select(dayLogs)..where((t) => t.date.like('$yearMonthPrefix%'))).get();

  Future<void> upsertDayLog(DayLogsCompanion log) =>
      into(dayLogs).insertOnConflictUpdate(log);

  /// Маркира само менструалния флаг за [date], без да пипа
  /// останалите полета на евентуален съществуващ запис.
  Future<void> setPeriodFlag(String date, bool value) async {
    final existing = await dayLog(date);
    if (existing != null) {
      await (update(dayLogs)..where((t) => t.date.equals(date)))
          .write(DayLogsCompanion(isPeriod: Value(value)));
    } else if (value) {
      await into(dayLogs).insert(
        DayLogsCompanion.insert(date: date, isPeriod: const Value(true)),
      );
    }
  }

  /// Всички менструални дни, най-новите първи — за извличане на
  /// началото на последния цикъл.
  Future<List<DayLogRow>> allPeriodLogs() => (select(dayLogs)
        ..where((t) => t.isPeriod.equals(true))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();

  // --- Интимни моменти ---
  Future<List<IntimateMomentRow>> momentsOn(String date) =>
      (select(intimateMoments)..where((t) => t.date.equals(date))).get();

  Future<List<IntimateMomentRow>> monthMoments(String yearMonthPrefix) =>
      (select(intimateMoments)
            ..where((t) => t.date.like('$yearMonthPrefix%')))
          .get();

  Future<int> insertMoment(IntimateMomentsCompanion moment) =>
      into(intimateMoments).insert(moment);

  Future<void> replaceMomentsOn(
    String date,
    List<IntimateMomentsCompanion> moments,
  ) =>
      transaction(() async {
        await (delete(intimateMoments)..where((t) => t.date.equals(date)))
            .go();
        for (final m in moments) {
          await into(intimateMoments).insert(m);
        }
      });

  // --- Настройки на цикъла ---
  Future<CyclePrefsRow?> loadCyclePrefs() =>
      (select(cyclePrefs)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> saveCyclePrefs(CyclePrefsCompanion prefs) =>
      into(cyclePrefs).insertOnConflictUpdate(
        prefs.copyWith(id: const Value(1)),
      );
}

/// Отваря криптираната база с [hexKey] (64 hex знака като парола).
///
/// Ползваме SQLite3MultipleCiphers (билднат от `package:sqlite3` чрез
/// `hooks.user_defines` в pubspec.yaml) в SQLCipher-съвместим режим —
/// AES-256 + HMAC. Хвърля, ако шифриращата библиотека липсва, за да не
/// запишем некриптиран файл по погрешка.
QueryExecutor openEncryptedDatabase(File file, String hexKey) {
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      final cipher = db.select('PRAGMA cipher;');
      if (cipher.isEmpty) {
        throw UnsupportedError(
          'SQLite3MultipleCiphers не е наличен — отказваме да пишем '
          'некриптирани данни.',
        );
      }
      db.execute("PRAGMA cipher = 'sqlcipher';");
      db.execute("PRAGMA key = '$hexKey';");
    },
  );
}

/// Пътят до файла на базата.
Future<File> databaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'intima.db'));
}
