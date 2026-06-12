import 'package:flutter/foundation.dart';

/// Настройки и предикции на цикъла — споделени между календара и
/// настройките. Стойностите персистират чрез CyclePrefsRepository;
/// [lastPeriodStart] се извлича от реалните записи (CalendarRepository).
class CycleSettings extends ChangeNotifier {
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _notifyPeriod = true;
  bool _notifyOvulation = true;
  DateTime? _lastPeriodStart;

  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get notifyPeriod => _notifyPeriod;
  bool get notifyOvulation => _notifyOvulation;

  /// Първият ден на последната отбелязана менструация.
  /// null = още няма отбелязана — предикциите са изключени.
  DateTime? get lastPeriodStart => _lastPeriodStart;

  set lastPeriodStart(DateTime? v) {
    if (v == _lastPeriodStart) return;
    _lastPeriodStart = v;
    notifyListeners();
  }

  set cycleLength(int v) {
    _cycleLength = v.clamp(21, 40);
    notifyListeners();
  }

  set periodLength(int v) {
    _periodLength = v.clamp(2, 10);
    notifyListeners();
  }

  set notifyPeriod(bool v) {
    _notifyPeriod = v;
    notifyListeners();
  }

  set notifyOvulation(bool v) {
    _notifyOvulation = v;
    notifyListeners();
  }

  /// Връща настройките по подразбиране — при GDPR изтриване.
  void resetToDefaults() {
    _cycleLength = 28;
    _periodLength = 5;
    _notifyPeriod = true;
    _notifyOvulation = true;
    _lastPeriodStart = null;
    notifyListeners();
  }

  /// Началото на k-тия следващ цикъл (k = 1 е следващият);
  /// null при липса на данни.
  DateTime? predictedPeriodStart(int k) =>
      _lastPeriodStart?.add(Duration(days: cycleLength * k));

  DateTime? get nextPeriodStart => predictedPeriodStart(1);

  /// Овулация ≈ 14 дни преди следващата менструация.
  DateTime? get ovulation =>
      nextPeriodStart?.subtract(const Duration(days: 14));

  /// Фертилен прозорец: овулация ± 2 дни —
  /// проверяваме следващите три цикъла, за да личи и при навигация напред.
  bool isFertile(DateTime d) {
    if (_lastPeriodStart == null) return false;
    for (var k = 1; k <= 3; k++) {
      final ov =
          predictedPeriodStart(k)!.subtract(const Duration(days: 14));
      if (d.difference(ov).inDays.abs() <= 2) return true;
    }
    return false;
  }

  /// Дни спрямо най-близката прогнозирана овулация (отрицателно =
  /// преди овулацията). null при липса на данни. Овулацията на цикъл,
  /// започващ на S, е ≈ S + cycleLength − 14.
  int? daysFromOvulation(DateTime d) {
    if (_lastPeriodStart == null) return null;
    final day = DateTime(d.year, d.month, d.day);
    int? best;
    for (var k = 0; k <= 4; k++) {
      final ov = _lastPeriodStart!
          .add(Duration(days: cycleLength * k - 14));
      final diff =
          day.difference(DateTime(ov.year, ov.month, ov.day)).inDays;
      if (best == null || diff.abs() < best.abs()) best = diff;
    }
    return best;
  }

  /// Дали [d] попада в очаквана (предиктирана) менструация —
  /// проверяваме следващите три цикъла напред.
  bool isPredictedPeriod(DateTime d) {
    if (_lastPeriodStart == null) return false;
    for (var k = 1; k <= 3; k++) {
      final diff = d.difference(predictedPeriodStart(k)!).inDays;
      if (diff >= 0 && diff < periodLength) return true;
    }
    return false;
  }
}

final cycleSettings = CycleSettings();
