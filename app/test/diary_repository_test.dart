import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/data/calendar_repository.dart' show decodeStringList;
import 'package:intima/data/database.dart';
import 'package:intima/data/db_manager.dart';
import 'package:intima/data/diary_repository.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late DiaryRepository repo;

  setUp(() async {
    await dbManager.openForTesting(IntimaDatabase(NativeDatabase.memory()));
    repo = DiaryRepository(dbManager);
  });

  Future<void> seed(String title, DateTime date,
      {List<String> tags = const [], List<String> photos = const []}) {
    return repo.create(
      title: title,
      body: 'Текст за $title',
      date: date,
      mood: 3,
      tags: tags,
      photos: photos,
    );
  }

  test('създаване, хронологичен ред, редакция, изтриване', () async {
    await seed('Стар', DateTime(2026, 6, 1));
    await seed('Нов', DateTime(2026, 6, 9));

    var all = await repo.all();
    expect(all.map((e) => e.title), ['Нов', 'Стар']);

    await repo.update(all.first.copyWith(title: 'Нов 💜'));
    all = await repo.all();
    expect(all.first.title, 'Нов 💜');

    await repo.delete(all.last);
    expect(await repo.all(), hasLength(1));
  });

  test('търсенето хваща заглавие, текст и таг', () async {
    await seed('Вечерята', DateTime(2026, 6, 8), tags: ['нас']);
    final row = (await repo.all()).single;

    expect(entryMatches(row, 'вечеря'), isTrue); // заглавие
    expect(entryMatches(row, 'текст за'), isTrue); // тяло
    expect(entryMatches(row, 'нас'), isTrue); // таг
    expect(entryMatches(row, 'липсва'), isFalse);
  });

  test('няколко снимки на запис се пазят и четат обратно', () async {
    await seed('Със снимки', DateTime(2026, 6, 9),
        photos: ['/p/a.jpg', '/p/b.jpg']);
    final row = (await repo.all()).single;
    expect(row.hasPhoto, isTrue);
    expect(decodeStringList(row.photos), ['/p/a.jpg', '/p/b.jpg']);

    // Изтриването на запис със снимки не гърми при липсващи файлове.
    await repo.delete(row);
    expect(await repo.all(), isEmpty);
  });

  test('спомен: най-скорошният запис отпреди поне 30 дни', () async {
    final now = DateTime(2026, 6, 10);
    await seed('Вчера', DateTime(2026, 6, 9));
    await seed('Преди месец и нещо', DateTime(2026, 5, 5));
    await seed('Преди година', DateTime(2025, 6, 1));

    final memory = await repo.memory(now: now);
    expect(memory!.title, 'Преди месец и нещо');

    // Без достатъчно стари записи няма спомен.
    final fresh = await repo.memory(now: DateTime(2026, 6, 5), minDays: 365);
    expect(fresh?.title, 'Преди година');
  });
}
