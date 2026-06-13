import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'partner_repository.dart';
import 'sync_backend.dart';

/// Конфигурацията на Supabase проекта. Стойностите са публични по
/// дизайн (публичният ключ пътува с APK-то — сигурността е в RLS);
/// --dart-define ги препокрива при нужда.
const supabaseUrl = String.fromEnvironment(
  'INTIMA_SUPABASE_URL',
  defaultValue: 'https://kwgiomqkvqixpgpcezbd.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'INTIMA_SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_Rki1_v8onz7nfKJZ_ij52Q_2Lo9VGUC',
);

const _bucket = 'partner-media';

bool get partnerSyncConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

/// Реалният сървър. Партньорският чат и медията се пазят в явен вид
/// (без E2E) — оповестено в Privacy Policy; модерацията ги преглежда
/// през Supabase dashboard.
class SupabaseBackend extends PartnerBackend {
  static bool _initialized = false;

  /// Лениво: мрежата се пипа чак когато потребителката отвори
  /// партньорските функции, не при стартиране на приложението.
  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
    _initialized = true;
    // Анонимна идентичност — без имейл, без телефон, без име.
    if (Supabase.instance.client.auth.currentUser == null) {
      await Supabase.instance.client.auth.signInAnonymously();
    }
  }

  SupabaseClient get _db => Supabase.instance.client;

  @override
  Future<String?> identity() async {
    await ensureInitialized();
    return _db.auth.currentUser!.id;
  }

  @override
  Future<void> createPairing(String code) async {
    await ensureInitialized();
    await _db.rpc('create_pairing', params: {'p_code': code});
  }

  @override
  Future<String?> joinPairing(String code) async {
    await ensureInitialized();
    final result = await _db.rpc('join_pairing', params: {'p_code': code});
    return result as String?;
  }

  @override
  Future<String?> pairingCouple(String code) async {
    await ensureInitialized();
    final result = await _db.rpc('pairing_couple', params: {'p_code': code});
    return result as String?;
  }

  @override
  Future<List<String>> myCouples() async {
    await ensureInitialized();
    final rows = await _db.from('couples').select('id');
    return [for (final r in rows) r['id'] as String];
  }

  @override
  Future<void> sendMessage({
    required String coupleId,
    required String author,
    String? body,
    String? mediaLocalPath,
    MediaKind mediaKind = MediaKind.none,
  }) async {
    await ensureInitialized();
    String? mediaPath;
    if (mediaLocalPath != null) {
      final ext = p.extension(mediaLocalPath);
      mediaPath = '$coupleId/${DateTime.now().microsecondsSinceEpoch}$ext';
      await _db.storage
          .from(_bucket)
          .upload(mediaPath, File(mediaLocalPath));
    }
    await _db.from('messages').insert({
      'couple_id': coupleId,
      'author': author,
      'body': body,
      'media_path': mediaPath,
      'media_kind': mediaKind.index,
    });
  }

  @override
  Future<List<Message>> messages(String coupleId, {DateTime? since}) async {
    await ensureInitialized();
    var query = _db.from('messages').select().eq('couple_id', coupleId);
    if (since != null) {
      query = query.gt('created_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('created_at', ascending: true);
    return [
      for (final row in rows)
        Message(
          id: row['id'] as String,
          coupleId: row['couple_id'] as String,
          author: row['author'] as String,
          body: row['body'] as String?,
          mediaPath: row['media_path'] as String?,
          mediaKind: MediaKind.values[(row['media_kind'] as num).toInt()],
          createdAt: DateTime.parse(row['created_at'] as String),
        ),
    ];
  }

  @override
  Future<String?> mediaUrl(String? mediaPath) async {
    if (mediaPath == null) return null;
    await ensureInitialized();
    // Подписан URL с кратък живот — само за показване в чата.
    return _db.storage.from(_bucket).createSignedUrl(mediaPath, 60 * 60);
  }

  @override
  Future<void> setPoseInterest(
      String coupleId, String poseId, bool wanted) async {
    await ensureInitialized();
    final uid = _db.auth.currentUser!.id;
    if (wanted) {
      await _db.from('pose_interests').upsert({
        'couple_id': coupleId,
        'member': uid,
        'pose_id': poseId,
      });
    } else {
      await _db
          .from('pose_interests')
          .delete()
          .eq('couple_id', coupleId)
          .eq('member', uid)
          .eq('pose_id', poseId);
    }
  }

  @override
  Future<List<String>> poseMatches(String coupleId) async {
    await ensureInitialized();
    final res = await _db.rpc('pose_matches', params: {'p_couple': coupleId});
    return [for (final e in res as List) e as String];
  }

  @override
  Future<void> dissolve(String coupleId) async {
    await ensureInitialized();
    await _db.rpc('dissolve_couple', params: {'p_couple': coupleId});
  }
}

/// Глобалната инстанция за UI-я — реалният сървър.
final partnerRepository = PartnerRepository(SupabaseBackend());

/// Вход през външен доставчик (Facebook/Google). Изисква доставчикът
/// да е настроен в Supabase (Dashboard → Authentication → Providers).
/// Instagram и TikTok не се поддържат от Supabase auth.
Future<void> signInWithProvider(OAuthProvider provider) async {
  await SupabaseBackend.ensureInitialized();
  await Supabase.instance.client.auth.signInWithOAuth(provider);
}
