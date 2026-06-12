import 'dart:convert';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'couple_crypto.dart';
import 'partner_repository.dart';
import 'sync_backend.dart';

/// Конфигурацията на Supabase проекта. И двете стойности са публични
/// по дизайн (anon ключът се разпространява с APK-то — сигурността е
/// в RLS политиките и в E2E криптирането), затова стоят като defaults;
/// --dart-define ги препокрива при нужда (напр. staging проект).
const supabaseUrl = String.fromEnvironment(
  'INTIMA_SUPABASE_URL',
  defaultValue: 'https://kwgiomqkvqixpgpcezbd.supabase.co',
);
const supabaseAnonKey = String.fromEnvironment(
  'INTIMA_SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_Rki1_v8onz7nfKJZ_ij52Q_2Lo9VGUC',
);

bool get partnerSyncConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

/// Реалният сървър — говори единствено с RPC функциите и таблиците
/// от supabase/schema.sql. Тук влизат само публични ключове и
/// шифровани блокчета; декриптирането живее в CoupleCrypto.
class SupabaseBackend extends SyncBackend {
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
  Future<void> createPairing(String code, Uint8List pubA) async {
    await ensureInitialized();
    await _db.rpc('create_pairing', params: {
      'p_code': code,
      'p_pub_a': base64Encode(pubA),
    });
  }

  @override
  Future<Uint8List?> joinPairing(String code, Uint8List pubB) async {
    await ensureInitialized();
    final result = await _db.rpc('join_pairing', params: {
      'p_code': code,
      'p_pub_b': base64Encode(pubB),
    });
    return result == null ? null : base64Decode(result as String);
  }

  @override
  Future<PairingState?> pairingState(String code) async {
    await ensureInitialized();
    final pubB = await _db.rpc('pairing_state', params: {'p_code': code});
    // pub_a не е нужен на канещата страна — тя си има ключовете.
    return PairingState(
      pubA: Uint8List(0),
      pubB: pubB == null ? null : base64Decode(pubB as String),
    );
  }

  @override
  Future<String> completePairing(String code) async {
    await ensureInitialized();
    final result =
        await _db.rpc('complete_pairing', params: {'p_code': code});
    return result as String;
  }

  @override
  Future<void> push(SharedItem item) async {
    await ensureInitialized();
    // Репозиторито вече е сложило auth uid-а като автор (identity()).
    await _db.from('shared_items').insert({
      'couple_id': item.coupleId,
      'author': item.author,
      'kind': item.kind.index,
      'nonce': base64Encode(item.sealed.nonce),
      'cipher': base64Encode(item.sealed.cipherText),
      'mac': base64Encode(item.sealed.mac),
    });
  }

  @override
  Future<List<SharedItem>> pull(String coupleId, {DateTime? since}) async {
    await ensureInitialized();
    var query = _db.from('shared_items').select().eq('couple_id', coupleId);
    if (since != null) {
      query = query.gt('created_at', since.toUtc().toIso8601String());
    }
    final rows = await query.order('created_at', ascending: true);
    return [
      for (final row in rows)
        SharedItem(
          id: row['id'] as String,
          coupleId: row['couple_id'] as String,
          author: row['author'] as String,
          kind: SharedKind.values[(row['kind'] as num).toInt()],
          sealed: SealedBox(
            nonce: base64Decode(row['nonce'] as String),
            cipherText: base64Decode(row['cipher'] as String),
            mac: base64Decode(row['mac'] as String),
          ),
          createdAt: DateTime.parse(row['created_at'] as String),
        ),
    ];
  }

  @override
  Future<void> dissolve(String coupleId) async {
    await ensureInitialized();
    await _db.rpc('dissolve_couple', params: {'p_couple': coupleId});
  }
}

/// Глобалната инстанция за UI-я — реалният сървър.
final partnerRepository = PartnerRepository(SupabaseBackend());
