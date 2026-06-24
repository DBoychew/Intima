import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../partner/supabase_backend.dart';

/// Качва копие на снимките от ЛИЧНИЯ дневник на сървъра.
///
/// Снимките се пазят и локално (водещото копие за показване), а тук —
/// в частен bucket, видим само за собственика (и за модерацията през
/// dashboard-а). Оповестено в Privacy Policy и Play Data Safety.
abstract class DiaryMediaSync {
  /// Качва локалния файл на сървъра (под папката на потребителя).
  Future<void> upload(String localPath);

  /// Маха копието на този файл от сървъра.
  Future<void> remove(String localPath);

  /// GDPR: маха всички сървърни копия на потребителя.
  Future<void> removeAllForUser();
}

/// Празна имплементация — тестове и локална разработка (никаква мрежа).
class NoopDiaryMediaSync implements DiaryMediaSync {
  const NoopDiaryMediaSync();

  @override
  Future<void> upload(String localPath) async {}

  @override
  Future<void> remove(String localPath) async {}

  @override
  Future<void> removeAllForUser() async {}
}

/// Реалната имплементация върху Supabase Storage. Всичко е best-effort:
/// локалното копие е водещо, така че мрежов проблем никога не чупи
/// записа в дневника.
class SupabaseDiaryMediaSync implements DiaryMediaSync {
  const SupabaseDiaryMediaSync();

  static const _bucket = 'diary-media';

  /// Пътят на сървъра е `<uid>/<име на файла>` — RLS пуска всеки само
  /// в собствената му папка (виж supabase/schema.sql).
  Future<String?> _serverPath(SupabaseClient client, String localPath) async {
    final uid = client.auth.currentUser?.id;
    if (uid == null) return null;
    return '$uid/${p.basename(localPath)}';
  }

  @override
  Future<void> upload(String localPath) async {
    if (!partnerSyncConfigured) return;
    try {
      await SupabaseBackend.ensureInitialized();
      final client = Supabase.instance.client;
      final path = await _serverPath(client, localPath);
      if (path == null) return;
      await client.storage.from(_bucket).upload(
            path,
            File(localPath),
            fileOptions: const FileOptions(upsert: true),
          );
    } catch (_) {
      // Best-effort: локалното копие остава непокътнато.
    }
  }

  @override
  Future<void> remove(String localPath) async {
    if (!partnerSyncConfigured) return;
    try {
      await SupabaseBackend.ensureInitialized();
      final client = Supabase.instance.client;
      final path = await _serverPath(client, localPath);
      if (path == null) return;
      await client.storage.from(_bucket).remove([path]);
    } catch (_) {}
  }

  @override
  Future<void> removeAllForUser() async {
    if (!partnerSyncConfigured) return;
    try {
      await SupabaseBackend.ensureInitialized();
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;
      final objects = await client.storage.from(_bucket).list(path: uid);
      if (objects.isEmpty) return;
      await client.storage
          .from(_bucket)
          .remove([for (final o in objects) '$uid/${o.name}']);
    } catch (_) {}
  }
}
