import 'package:drift/drift.dart';

import '../core/cycle_settings.dart';
import 'database.dart';
import 'db_manager.dart';

/// Връзката между UI модела [CycleSettings] и реда CyclePrefs в базата:
/// зарежда при старт и записва автоматично при всяка промяна.
///
/// Държи [DbManager], а не конкретна база — при GDPR изтриване старата
/// връзка се затваря и записите трябва да отиват в новата.
class CyclePrefsRepository {
  CyclePrefsRepository(this._manager);

  final DbManager _manager;
  bool _hydrated = false;

  Future<void> hydrate() async {
    final row = await _manager.db.loadCyclePrefs();
    if (row != null) {
      cycleSettings
        ..cycleLength = row.cycleLength
        ..periodLength = row.periodLength
        ..notifyPeriod = row.notifyPeriod
        ..notifyOvulation = row.notifyOvulation;
    }
    if (!_hydrated) {
      cycleSettings.addListener(_persist);
      _hydrated = true;
    }
  }

  Future<void> _persist() => _manager.db.saveCyclePrefs(
        CyclePrefsCompanion.insert(
          id: const Value(1),
          cycleLength: Value(cycleSettings.cycleLength),
          periodLength: Value(cycleSettings.periodLength),
          notifyPeriod: Value(cycleSettings.notifyPeriod),
          notifyOvulation: Value(cycleSettings.notifyOvulation),
        ),
      );
}
