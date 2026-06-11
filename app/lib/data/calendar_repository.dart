import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/cycle_settings.dart';
import 'database.dart';
import 'db_manager.dart';

/// Ключ 'YYYY-MM-DD' — каноничният формат на датите в базата.
String dateKey(DateTime d) => '${d.year}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime parseDateKey(String key) => DateTime(
      int.parse(key.substring(0, 4)),
      int.parse(key.substring(5, 7)),
      int.parse(key.substring(8, 10)),
    );

List<String> decodeStringList(String? json) => json == null
    ? const []
    : (jsonDecode(json) as List).cast<String>();

/// Какво направи записът с менструалните маркери — за обратната връзка.
class QuickLogOutcome {
  const QuickLogOutcome({this.autoFilledDays = 0, this.clearedDays = 0});

  final int autoFilledDays;
  final int clearedDays;
}

/// Чернова на интимен момент — мостът между бързия запис и базата.
class MomentDraft {
  const MomentDraft({
    this.arousal = 0.6,
    this.orgasms = 1,
    this.positions = const [],
    this.note = '',
  });

  final double arousal;
  final int orgasms;
  final List<String> positions;
  final String note;
}

/// Данните за един месец, индексирани по ден от месеца.
class MonthData {
  const MonthData(this.logs, this.momentsByDay);

  static const empty = MonthData({}, {});

  final Map<int, DayLogRow> logs;
  final Map<int, List<IntimateMomentRow>> momentsByDay;

  bool isPeriod(int day) => logs[day]?.isPeriod ?? false;
  bool hasIntimacy(int day) => momentsByDay[day]?.isNotEmpty ?? false;
}

class CalendarRepository {
  CalendarRepository(this._manager);

  final DbManager _manager;

  Future<MonthData> month(int year, int monthNum) async {
    final prefix = '$year-${monthNum.toString().padLeft(2, '0')}-';
    final logs = await _manager.db.monthLogs(prefix);
    final moments = await _manager.db.monthMoments(prefix);

    int dayOf(String date) => int.parse(date.substring(8, 10));
    final byDay = <int, List<IntimateMomentRow>>{};
    for (final m in moments) {
      byDay.putIfAbsent(dayOf(m.date), () => []).add(m);
    }
    return MonthData(
      {for (final l in logs) dayOf(l.date): l},
      byDay,
    );
  }

  /// Записва целия бърз лог за деня и преизчислява предикциите.
  ///
  /// Менструалната логика е „умна":
  /// - Маркиране на начален ден → следващите дни се маркират автоматично
  ///   според „Дължина на менструацията" от настройките.
  /// - Махане на ден от серия → чисти цялата серия (грешно отбелязана),
  ///   освен ако денят е в последните 3 дни — тогава само съкращава края.
  Future<QuickLogOutcome> saveQuickLog({
    required DateTime date,
    required int? mood,
    required bool period,
    required double libido,
    required double energy,
    required List<String> symptoms,
    required List<MomentDraft> moments,
  }) async {
    final key = dateKey(date);
    final wasPeriod =
        (await _manager.db.dayLog(key))?.isPeriod ?? false;
    final startsNewRun =
        period && !wasPeriod && !await _isPeriodDay(date, delta: -1);

    await _manager.db.upsertDayLog(DayLogsCompanion.insert(
      date: key,
      mood: Value(mood),
      libido: Value(libido),
      energy: Value(energy),
      isPeriod: Value(period),
      symptoms: Value(jsonEncode(symptoms)),
    ));
    await _manager.db.replaceMomentsOn(key, [
      for (final m in moments)
        IntimateMomentsCompanion.insert(
          date: key,
          arousal: Value(m.arousal),
          orgasms: Value(m.orgasms),
          positions: Value(jsonEncode(m.positions)),
          note: Value(m.note),
        ),
    ]);

    var autoFilled = 0;
    var cleared = 0;
    if (startsNewRun) {
      for (var i = 1; i < cycleSettings.periodLength; i++) {
        await _manager.db.setPeriodFlag(
          dateKey(date.add(Duration(days: i))),
          true,
        );
        autoFilled++;
      }
    } else if (wasPeriod && !period) {
      cleared = await _clearRunAround(date);
    }

    await refreshLastPeriodStart();
    return QuickLogOutcome(autoFilledDays: autoFilled, clearedDays: cleared);
  }

  /// Маханият ден [date] вече е без маркер; чисти останалата част от
  /// серията му. Връща броя допълнително изчистени дни.
  Future<int> _clearRunAround(DateTime date) async {
    var before = 0;
    while (await _isPeriodDay(date, delta: -(before + 1))) {
      before++;
    }
    var after = 0;
    while (await _isPeriodDay(date, delta: after + 1)) {
      after++;
    }

    Future<void> clear(int delta) => _manager.db.setPeriodFlag(
          dateKey(date.add(Duration(days: delta))),
          false,
        );

    var cleared = 0;
    // В последните 3 дни на серията → само съкращаваме края.
    final shortensTail = after <= 2;
    if (!shortensTail) {
      for (var i = 1; i <= before; i++) {
        await clear(-i);
        cleared++;
      }
    }
    for (var i = 1; i <= after; i++) {
      await clear(i);
      cleared++;
    }
    return cleared;
  }

  Future<bool> _isPeriodDay(DateTime date, {required int delta}) async {
    final log =
        await _manager.db.dayLog(dateKey(date.add(Duration(days: delta))));
    return log?.isPeriod ?? false;
  }

  /// Намира първия ден на най-скорошната непрекъсната серия от
  /// менструални дни и обновява [CycleSettings.lastPeriodStart].
  Future<void> refreshLastPeriodStart() async {
    final rows = await _manager.db.allPeriodLogs();
    if (rows.isEmpty) {
      cycleSettings.lastPeriodStart = null;
      return;
    }
    var start = parseDateKey(rows.first.date);
    for (var i = 1; i < rows.length; i++) {
      final prev = parseDateKey(rows[i].date);
      if (start.difference(prev).inDays != 1) break;
      start = prev;
    }
    cycleSettings.lastPeriodStart = start;
  }
}

final calendarRepository = CalendarRepository(dbManager);
