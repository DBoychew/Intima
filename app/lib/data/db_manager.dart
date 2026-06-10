import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../security/secure_store.dart';
import 'database.dart';

/// Държи живата връзка към криптираната база и операциите по жизнения ѝ
/// цикъл: отваряне, експорт и пълно изтриване (GDPR).
/// Уведомява слушателите при пълно изтриване, за да се презаредят екраните.
class DbManager extends ChangeNotifier {
  IntimaDatabase? _db;

  IntimaDatabase get db {
    final db = _db;
    if (db == null) {
      throw StateError('Базата не е отворена — извикай open() първо.');
    }
    return db;
  }

  Future<void> open() async {
    if (_db != null) return;
    final file = await databaseFile();
    _db = IntimaDatabase(openEncryptedDatabase(file, await _obtainKey()));
  }

  /// Само за тестове — инжектира готова (напр. in-memory) база.
  @visibleForTesting
  Future<void> openForTesting(IntimaDatabase db) async {
    await _db?.close();
    _db = db;
  }

  /// 256-битов произволен ключ, създаден веднъж и пазен в OS keystore-а.
  Future<String> _obtainKey() async {
    final existing = await SecureStore.read(SecureStore.dbKey);
    if (existing != null) return existing;
    final rnd = Random.secure();
    final key = List.generate(
      32,
      (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await SecureStore.write(SecureStore.dbKey, key);
    return key;
  }

  /// Експорт: копие на криптирания файл (AES-256, без ключа в него).
  Future<File> exportCopy() async {
    final file = await databaseFile();
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final stamp = '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return file.copy(p.join(dir.path, 'intima-backup-$stamp.db'));
  }

  /// GDPR: затваря базата, трие файла и всички ключове от keystore-а,
  /// после отваря чиста база с нов ключ. Необратимо.
  Future<void> wipeEverything() async {
    await _db?.close();
    _db = null;
    final file = await databaseFile();
    if (await file.exists()) await file.delete();
    await SecureStore.wipeAll();
    await open();
    notifyListeners();
  }
}

final dbManager = DbManager();
