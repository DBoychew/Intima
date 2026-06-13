import '../core/cycle_settings.dart';
import '../security/app_lock.dart';
import 'calendar_repository.dart' show dateKey, parseDateKey, decodeStringList;
import 'database.dart';
import 'db_manager.dart';

/// Инсайти и статистики (Premium) — всичко се изчислява локално от
/// криптираната база; нито един байт не напуска устройството.

/// Реално измерените цикли: интервалите между началата на
/// последователни менструации.
class CycleStats {
  const CycleStats({
    required this.count,
    this.average,
    this.min,
    this.max,
  });

  /// Брой измерени интервала (0 = нужни са поне две менструации).
  final int count;
  final double? average;
  final int? min;
  final int? max;
}

enum CyclePhase { menstrual, follicular, ovulation, luteal }

/// Тенденция за един календарен месец.
class MonthTrend {
  const MonthTrend({
    required this.month,
    this.avgLibido,
    this.avgEnergy,
    required this.moments,
  });

  /// Първо число на месеца.
  final DateTime month;
  final double? avgLibido;
  final double? avgEnergy;
  final int moments;

  bool get hasData => avgLibido != null || avgEnergy != null || moments > 0;
}

/// Рекапитулация на последните 30 дни.
class Recap {
  const Recap({
    this.diaryEntries = 0,
    this.moments = 0,
    this.orgasms = 0,
    this.avgMood,
    this.topSymptom,
    this.topPosition,
  });

  final int diaryEntries;
  final int moments;
  final int orgasms;
  final double? avgMood;
  final String? topSymptom;
  final String? topPosition;

  bool get hasData =>
      diaryEntries > 0 || moments > 0 || avgMood != null;
}

/// Локални корелации (Фаза 9) — изчислени изцяло на устройството.
class Correlations {
  const Correlations({
    this.moodFertileDelta,
    this.intimacyInFertilePct,
    this.libidoEnergyTrend,
  });

  /// Средно настроение във фертилния прозорец минус извън него (−4..4).
  final double? moodFertileDelta;

  /// Дял на интимните моменти във фертилния прозорец (0..1).
  final double? intimacyInFertilePct;

  /// Тенденция либидо↔енергия: +1 вървят заедно, −1 обратно, 0 неясно.
  final int? libidoEnergyTrend;

  bool get hasAny =>
      moodFertileDelta != null ||
      intimacyInFertilePct != null ||
      libidoEnergyTrend != null;
}

/// Корелации от реалните данни; [isFertile] решава кои дни са във
/// фертилния прозорец (подава се cycleSettings.isFertile).
Correlations computeCorrelations({
  required List<DayLogRow> logs,
  required List<IntimateMomentRow> moments,
  required bool Function(DateTime) isFertile,
}) {
  double fSum = 0, nSum = 0;
  var fN = 0, nN = 0;
  final libido = <double>[];
  final energy = <double>[];
  for (final l in logs) {
    final date = parseDateKey(l.date);
    if (l.mood != null) {
      if (isFertile(date)) {
        fSum += l.mood!;
        fN++;
      } else {
        nSum += l.mood!;
        nN++;
      }
    }
    if (l.libido != null && l.energy != null) {
      libido.add(l.libido!);
      energy.add(l.energy!);
    }
  }

  double? moodDelta;
  if (fN > 0 && nN > 0) moodDelta = fSum / fN - nSum / nN;

  double? intimacyPct;
  if (moments.isNotEmpty) {
    final inFertile =
        moments.where((m) => isFertile(parseDateKey(m.date))).length;
    intimacyPct = inFertile / moments.length;
  }

  int? trend;
  if (libido.length >= 4) {
    final ml = libido.reduce((a, b) => a + b) / libido.length;
    final me = energy.reduce((a, b) => a + b) / energy.length;
    var cov = 0.0;
    for (var i = 0; i < libido.length; i++) {
      cov += (libido[i] - ml) * (energy[i] - me);
    }
    trend = cov > 0.001 ? 1 : (cov < -0.001 ? -1 : 0);
  }

  return Correlations(
    moodFertileDelta: moodDelta,
    intimacyInFertilePct: intimacyPct,
    libidoEnergyTrend: trend,
  );
}

class InsightsData {
  const InsightsData({
    required this.cycle,
    required this.moodByPhase,
    required this.moodSamples,
    required this.trend,
    required this.recap,
    this.correlations = const Correlations(),
  });

  static const empty = InsightsData(
    cycle: CycleStats(count: 0),
    moodByPhase: {},
    moodSamples: {},
    trend: [],
    recap: Recap(),
  );

  final CycleStats cycle;

  /// Средно настроение (0–4) по фаза — само фази с данни.
  final Map<CyclePhase, double> moodByPhase;
  final Map<CyclePhase, int> moodSamples;

  /// Последните 6 месеца, хронологично.
  final List<MonthTrend> trend;
  final Recap recap;
  final Correlations correlations;

  bool get isEmpty =>
      cycle.count == 0 &&
      moodByPhase.isEmpty &&
      !recap.hasData &&
      trend.every((m) => !m.hasData);
}

/// Началата на менструалните серии, хронологично.
List<DateTime> periodRunStarts(Iterable<DayLogRow> logs) {
  final periodDays = {
    for (final l in logs)
      if (l.isPeriod) l.date,
  };
  final starts = <DateTime>[];
  for (final key in periodDays.toList()..sort()) {
    final day = parseDateKey(key);
    final prev = dateKey(day.subtract(const Duration(days: 1)));
    if (!periodDays.contains(prev)) starts.add(day);
  }
  return starts;
}

/// Дължини на циклите от началата на сериите; интервали извън
/// 15–60 дни се пропускат (пропуснато отбелязване, не реален цикъл).
List<int> cycleLengths(List<DateTime> starts) => [
      for (var i = 1; i < starts.length; i++)
        starts[i].difference(starts[i - 1]).inDays,
    ].where((d) => d >= 15 && d <= 60).toList();

CycleStats computeCycleStats(List<DateTime> starts) {
  final lengths = cycleLengths(starts);
  if (lengths.isEmpty) return const CycleStats(count: 0);
  lengths.sort();
  return CycleStats(
    count: lengths.length,
    average: lengths.reduce((a, b) => a + b) / lengths.length,
    min: lengths.first,
    max: lengths.last,
  );
}

/// Фазата на [day] спрямо последното начало на менструация преди него.
/// null при липса на начало или ако денят е отвъд очаквания цикъл
/// (фазата би била гадаене).
CyclePhase? phaseOf(
  DateTime day,
  List<DateTime> starts, {
  required int cycleLength,
  required int periodLength,
}) {
  DateTime? lastStart;
  for (final s in starts) {
    if (s.isAfter(day)) break;
    lastStart = s;
  }
  if (lastStart == null) return null;
  final dayInCycle = day.difference(lastStart).inDays;
  if (dayInCycle >= cycleLength) return null;
  if (dayInCycle < periodLength) return CyclePhase.menstrual;
  final ovulationDay = cycleLength - 14;
  if ((dayInCycle - ovulationDay).abs() <= 2) return CyclePhase.ovulation;
  return dayInCycle < ovulationDay
      ? CyclePhase.follicular
      : CyclePhase.luteal;
}

/// Чистата изчислителна част — host-тестваема без база и UI.
InsightsData computeInsights({
  required List<DayLogRow> logs,
  required List<IntimateMomentRow> moments,
  required List<DiaryEntryRow> entries,
  required DateTime now,
  required int fallbackCycleLength,
  required int periodLength,
  bool Function(DateTime)? isFertile,
}) {
  final starts = periodRunStarts(logs);
  final cycle = computeCycleStats(starts);
  final cycleLength = cycle.average?.round() ?? fallbackCycleLength;

  // Настроение по фази.
  final moodSum = <CyclePhase, double>{};
  final moodCount = <CyclePhase, int>{};
  for (final log in logs) {
    final mood = log.mood;
    if (mood == null) continue;
    final phase = log.isPeriod
        ? CyclePhase.menstrual
        : phaseOf(parseDateKey(log.date), starts,
            cycleLength: cycleLength, periodLength: periodLength);
    if (phase == null) continue;
    moodSum[phase] = (moodSum[phase] ?? 0) + mood;
    moodCount[phase] = (moodCount[phase] ?? 0) + 1;
  }
  final moodByPhase = {
    for (final e in moodSum.entries) e.key: e.value / moodCount[e.key]!,
  };

  // Тенденции за последните 6 месеца (включително текущия).
  final trend = <MonthTrend>[];
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final prefix = '${month.year}-${month.month.toString().padLeft(2, '0')}-';
    double libidoSum = 0, energySum = 0;
    var libidoN = 0, energyN = 0;
    for (final log in logs.where((l) => l.date.startsWith(prefix))) {
      if (log.libido != null) {
        libidoSum += log.libido!;
        libidoN++;
      }
      if (log.energy != null) {
        energySum += log.energy!;
        energyN++;
      }
    }
    trend.add(MonthTrend(
      month: month,
      avgLibido: libidoN == 0 ? null : libidoSum / libidoN,
      avgEnergy: energyN == 0 ? null : energySum / energyN,
      moments: moments.where((m) => m.date.startsWith(prefix)).length,
    ));
  }

  // Рекапитулация на последните 30 дни.
  final cutoff = now.subtract(const Duration(days: 30));
  final cutoffKey = dateKey(cutoff);
  final recentMoments =
      moments.where((m) => m.date.compareTo(cutoffKey) >= 0).toList();
  final symptomCounts = <String, int>{};
  double recapMoodSum = 0;
  var recapMoodN = 0;
  for (final log in logs.where((l) => l.date.compareTo(cutoffKey) >= 0)) {
    for (final s in decodeStringList(log.symptoms)) {
      symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
    }
    if (log.mood != null) {
      recapMoodSum += log.mood!;
      recapMoodN++;
    }
  }
  final positionCounts = <String, int>{};
  for (final m in recentMoments) {
    for (final p in decodeStringList(m.positions)) {
      positionCounts[p] = (positionCounts[p] ?? 0) + 1;
    }
  }
  String? topOf(Map<String, int> counts) => counts.isEmpty
      ? null
      : (counts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .first
          .key;

  final recap = Recap(
    diaryEntries: entries.where((e) => e.date.isAfter(cutoff)).length,
    moments: recentMoments.length,
    orgasms: recentMoments.fold(0, (sum, m) => sum + m.orgasms),
    avgMood: recapMoodN == 0 ? null : recapMoodSum / recapMoodN,
    topSymptom: topOf(symptomCounts),
    topPosition: topOf(positionCounts),
  );

  final correlations = isFertile == null
      ? const Correlations()
      : computeCorrelations(
          logs: logs, moments: moments, isFertile: isFertile);

  return InsightsData(
    cycle: cycle,
    moodByPhase: moodByPhase,
    moodSamples: moodCount,
    trend: trend,
    recap: recap,
    correlations: correlations,
  );
}

class InsightsRepository {
  InsightsRepository(this._manager);

  final DbManager _manager;

  Future<InsightsData> compute({DateTime? now}) async {
    // Stealth копието е празно.
    if (appLock.decoyActive) return InsightsData.empty;
    return computeInsights(
      logs: await _manager.db.allDayLogs(),
      moments: await _manager.db.allMoments(),
      entries: await _manager.db.allDiaryEntries(),
      now: now ?? DateTime.now(),
      fallbackCycleLength: cycleSettings.cycleLength,
      periodLength: cycleSettings.periodLength,
      isFertile: cycleSettings.isFertile,
    );
  }
}

final insightsRepository = InsightsRepository(dbManager);
