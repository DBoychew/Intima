import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/data_version.dart';
import '../security/app_lock.dart';
import 'calendar_repository.dart' show decodeStringList;
import 'database.dart';
import 'db_manager.dart';
import 'diary_media_sync.dart';

/// Дневникът върху криптираната база + снимки в private storage.
/// Снимките се качват и на сървъра през [DiaryMediaSync] (по подразбиране
/// no-op — тестовете и локалната разработка остават офлайн).
class DiaryRepository {
  DiaryRepository(
    this._manager, {
    DiaryMediaSync mediaSync = const NoopDiaryMediaSync(),
  }) : _mediaSync = mediaSync;

  final DbManager _manager;
  final DiaryMediaSync _mediaSync;

  Future<List<DiaryEntryRow>> all() async {
    // Stealth копието е празно.
    if (appLock.decoyActive) return const [];
    return _manager.db.allDiaryEntries();
  }

  Future<void> create({
    required String title,
    required String body,
    required DateTime date,
    required int? mood,
    required List<String> tags,
    required List<String> photos,
    List<String> videos = const [],
    List<String> audios = const [],
  }) async {
    // В stealth копието нищо не се записва.
    if (appLock.decoyActive) return;
    await _manager.db.insertDiaryEntry(DiaryEntriesCompanion.insert(
      title: title,
      body: body,
      date: date,
      mood: Value(mood),
      tags: Value(jsonEncode(tags)),
      hasPhoto: Value(photos.isNotEmpty),
      photos: Value(jsonEncode(photos)),
      videos: Value(jsonEncode(videos)),
      audios: Value(jsonEncode(audios)),
    ));
    bumpDataVersion();
  }

  Future<void> update(DiaryEntryRow row) async {
    if (appLock.decoyActive) return;
    await _manager.db.updateDiaryEntry(row);
    bumpDataVersion();
  }

  Future<void> delete(DiaryEntryRow row) async {
    if (appLock.decoyActive) return;
    // Сървърни копия има за снимките и видеата (не за аудиото).
    final synced = [
      ...decodeStringList(row.photos),
      ...decodeStringList(row.videos),
    ];
    for (final path in [...synced, ...decodeStringList(row.audios)]) {
      await deletePhotoFile(path);
    }
    for (final path in synced) {
      unawaited(_mediaSync.remove(path));
    }
    await _manager.db.deleteDiaryEntry(row.id);
    bumpDataVersion();
  }

  /// Копира снимка в private storage (никога в общата галерия) и връща
  /// пътя до копието. Качва и копие на сървъра (фоново, best-effort).
  Future<String> importPhoto(String sourcePath) async {
    final local = await _importMedia(sourcePath, 'photos');
    if (!appLock.decoyActive) unawaited(_mediaSync.upload(local));
    return local;
  }

  /// Копира видео в private storage (v4, Premium). Качва и копие на
  /// сървъра (фоново, best-effort).
  Future<String> importVideo(String sourcePath) async {
    final local = await _importMedia(sourcePath, 'videos');
    if (!appLock.decoyActive) unawaited(_mediaSync.upload(local));
    return local;
  }

  /// Копира аудио бележка в private storage (v5, Premium).
  Future<String> importAudio(String sourcePath) =>
      _importMedia(sourcePath, 'audios');

  Future<String> _importMedia(String sourcePath, String subdir) async {
    // В stealth копието не копираме нищо — показваме оригинала.
    if (appLock.decoyActive) return sourcePath;
    final dir = await getApplicationDocumentsDirectory();
    final target = Directory(p.join(dir.path, subdir));
    await target.create(recursive: true);
    final name = 'diary_${DateTime.now().millisecondsSinceEpoch}'
        '${p.extension(sourcePath)}';
    final copy = await File(sourcePath).copy(p.join(target.path, name));
    return copy.path;
  }

  Future<void> deletePhotoFile(String? path) async {
    // В stealth никога не пипаме файлове (пътят може да е чужд оригинал).
    if (path == null || appLock.decoyActive) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Трие медия локално И сървърното ѝ копие — за единично премахване на
  /// снимка или видео от редактора. (Аудиото не се качва на сървъра.)
  Future<void> deleteSyncedMedia(String path) async {
    await deletePhotoFile(path);
    if (!appLock.decoyActive) unawaited(_mediaSync.remove(path));
  }

  /// GDPR: маха всички сървърни копия на снимките и видеата от дневника.
  Future<void> removeAllServerMedia() => _mediaSync.removeAllForUser();

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

final diaryRepository =
    DiaryRepository(dbManager, mediaSync: const SupabaseDiaryMediaSync());
