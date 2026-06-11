import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/calendar_repository.dart' show dateKey;
import '../data/database.dart';
import '../data/db_manager.dart';

/// Билд за скрийншоти на Play листинга:
///   flutter build apk --debug --dart-define=INTIMA_SCREENSHOTS=true
/// Изключва FLAG_SECURE и пълни красиви demo данни. НИКОГА в release.
const screenshotMode = bool.fromEnvironment('INTIMA_SCREENSHOTS');

Future<void> seedDemoData() async {
  final db = dbManager.db;
  if ((await db.allDiaryEntries()).isNotEmpty) return;

  final now = DateTime.now();
  DateTime daysAgo(int d) => now.subtract(Duration(days: d));

  // Менструация преди ~9 дни (5 дни) → жива прогноза в календара.
  for (var i = 9; i >= 5; i--) {
    await db.upsertDayLog(DayLogsCompanion.insert(
      date: dateKey(daysAgo(i)),
      isPeriod: const Value(true),
      mood: Value(i == 9 ? 1 : 2),
      libido: const Value(0.3),
      energy: const Value(0.4),
      symptoms: Value(jsonEncode(i >= 8 ? ['ПМС'] : <String>[])),
    ));
  }
  // Няколко обикновени дни + днес.
  await db.upsertDayLog(DayLogsCompanion.insert(
    date: dateKey(daysAgo(3)),
    mood: const Value(3),
    libido: const Value(0.6),
    energy: const Value(0.7),
  ));
  await db.upsertDayLog(DayLogsCompanion.insert(
    date: dateKey(now),
    mood: const Value(4),
    libido: const Value(0.7),
    energy: const Value(0.8),
  ));
  // Интимни моменти.
  for (final d in [daysAgo(3), daysAgo(1)]) {
    await db.insertMoment(IntimateMomentsCompanion.insert(
      date: dateKey(d),
      arousal: const Value(0.8),
      orgasms: const Value(1),
      positions: Value(jsonEncode(['Лъжички'])),
    ));
  }

  // Дневник.
  Future<void> entry(String title, String body, int ago, int mood,
      List<String> tags) {
    return db.insertDiaryEntry(DiaryEntriesCompanion.insert(
      title: title,
      body: body,
      date: daysAgo(ago),
      mood: Value(mood),
      tags: Value(jsonEncode(tags)),
    ));
  }

  await entry(
      'Вечерята с Н. 💜',
      'Най-хубавата вечер от месеци. Говорихме си до късно и се смяхме '
          'като в началото. Искам да запомня този ден.',
      1,
      4,
      ['нас', 'вечеря']);
  await entry(
      'Благодарност',
      'Днес съм благодарна за спокойствието, за чая сутринта и за '
          'прегръдката без повод.',
      3,
      3,
      ['благодарност']);
  await entry(
      'Малко умора',
      'Дълга седмица. Утре ще е по-добре — обещах си вана и книга.',
      6,
      2,
      []);
}
