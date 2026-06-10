import 'package:flutter/foundation.dart';

/// Настройки и предикции на цикъла — споделени между календара и
/// настройките. In-memory за прототипа; персистират във Фаза 3.
class CycleSettings extends ChangeNotifier {
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _notifyPeriod = true;
  bool _notifyOvulation = true;

  /// Начало на последната отбелязана менструация (мок за прототипа).
  final lastPeriodStart = DateTime(2026, 6, 3);

  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get notifyPeriod => _notifyPeriod;
  bool get notifyOvulation => _notifyOvulation;

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

  /// Началото на k-тия следващ цикъл (k = 1 е следващият).
  DateTime predictedPeriodStart(int k) =>
      lastPeriodStart.add(Duration(days: cycleLength * k));

  DateTime get nextPeriodStart => predictedPeriodStart(1);

  /// Овулация ≈ 14 дни преди следващата менструация.
  DateTime get ovulation =>
      nextPeriodStart.subtract(const Duration(days: 14));

  /// Фертилен прозорец: овулация ± 2 дни —
  /// проверяваме следващите три цикъла, за да личи и при навигация напред.
  bool isFertile(DateTime d) {
    for (var k = 1; k <= 3; k++) {
      final ov = predictedPeriodStart(k).subtract(const Duration(days: 14));
      if (d.difference(ov).inDays.abs() <= 2) return true;
    }
    return false;
  }

  /// Дали [d] попада в очаквана (предиктирана) менструация —
  /// проверяваме следващите три цикъла напред.
  bool isPredictedPeriod(DateTime d) {
    for (var k = 1; k <= 3; k++) {
      final diff = d.difference(predictedPeriodStart(k)).inDays;
      if (diff >= 0 && diff < periodLength) return true;
    }
    return false;
  }
}

final cycleSettings = CycleSettings();
