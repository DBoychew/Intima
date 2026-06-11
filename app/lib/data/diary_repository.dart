import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'calendar_repository.dart' show decodeStringList;
import 'database.dart';
import 'db_manager.dart';

/// Дневникът върху криптираната база + снимки в private storage.
class DiaryRepository {
  DiaryRepository(this._manager);

  final DbManager _manager;

  Future<List<DiaryEntryRow>> all() => _manager.db.allDiaryEntries();

  Future<void> create({
    required String title,
    required String body,
    required DateTime date,
    required int? mood,
    required List<String> tags,
    required List<String> photos,
  }) =>
      _manager.db.insertDiaryEntry(DiaryEntriesCompanion.insert(
        title: title,
        body: body,
        date: date,
        mood: Value(mood),
        tags: Value(jsonEncode(tags)),
        hasPhoto: Value(photos.isNotEmpty),
        photos: Value(jsonEncode(photos)),
      ));

  Future<void> update(DiaryEntryRow row) =>
      _manager.db.updateDiaryEntry(row);

  Future<void> delete(DiaryEntryRow row) async {
    for (final path in decodeStringList(row.photos)) {
      await deletePhotoFile(path);
    }
    await _manager.db.deleteDiaryEntry(row.id);
  }

  /// Копира снимка в private storage (никога в общата галерия)
  /// и връща пътя до копието.
  Future<String> importPhoto(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final photos = Directory(p.join(dir.path, 'photos'));
    await photos.create(recursive: true);
    final name = 'diary_${DateTime.now().millisecondsSinceEpoch}'
        '${p.extension(sourcePath)}';
    final copy = await File(sourcePath).copy(p.join(photos.path, name));
    return copy.path;
  }

  Future<void> deletePhotoFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// „Спомен от преди време" — най-скорошният запис отпреди поне
  /// [minDays] дни; null ако още няма такъв.
  Future<DiaryEntryRow?> memory({int minDays = 30, DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: minDays));
    for (final row in await all()) {
      if (row.date.isBefore(cutoff)) return row;
    }
    return null;
  }
}

/// Дали записът отговаря на търсене (заглавие, текст или таг).
bool entryMatches(DiaryEntryRow row, String query) {
  final q = query.toLowerCase();
  return row.title.toLowerCase().contains(q) ||
      row.body.toLowerCase().contains(q) ||
      decodeStringList(row.tags).any((t) => t.toLowerCase().contains(q));
}

final diaryRepository = DiaryRepository(dbManager);
