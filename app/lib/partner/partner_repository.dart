import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../security/secure_store.dart';
import 'couple_crypto.dart';
import 'sync_backend.dart';

enum PartnerStatus { none, inviting, linked }

/// Текуща покана при канещия — кодът за казване + SAS, щом другата
/// страна приеме.
class PendingInvite {
  const PendingInvite(this.code);

  final String code;
}

/// Оркестрира Partner Mode от двете страни на сдвояването и пази
/// състоянието в защитеното хранилище. Бекендът е абстракция —
/// тестовете ползват InMemorySyncBackend, продукцията Supabase.
class PartnerRepository {
  PartnerRepository(this._backend, {String? deviceIdOverride})
      : _deviceIdOverride = deviceIdOverride;

  static const _keyKey = 'partner_couple_key';
  static const _idKey = 'partner_couple_id';
  static const _deviceKey = 'partner_device_id';

  final SyncBackend _backend;

  /// За тестове: две „устройства" в един процес делят едно хранилище.
  final String? _deviceIdOverride;

  PartnerStatus _status = PartnerStatus.none;
  PartnerStatus get status => _status;

  SecretKey? _coupleKey;
  String? _coupleId;
  String? get coupleId => _coupleId;

  // Живее само по време на сдвояване.
  SimpleKeyPair? _pendingPair;
  String? _pendingCode;

  Future<void> init() async {
    final stored = await SecureStore.read(_keyKey);
    _coupleId = await SecureStore.read(_idKey);
    if (stored != null && _coupleId != null) {
      _coupleKey = SecretKey(base64Decode(stored));
      _status = PartnerStatus.linked;
    }
  }

  Future<String> _deviceId() async {
    if (_deviceIdOverride != null) return _deviceIdOverride;
    var id = await SecureStore.read(_deviceKey);
    if (id == null) {
      final rng = Random.secure();
      id = List.generate(16, (_) => rng.nextInt(16).toRadixString(16)).join();
      await SecureStore.write(_deviceKey, id);
    }
    return id;
  }

  /// Авторът, който се записва на сървъра: auth идентичността на
  /// бекенда (нужна за RLS) или локалното id при тестовия mock.
  Future<String> _author() async =>
      (await _backend.identity()) ?? await _deviceId();

  /// Страна А: създава покана и връща кода, който се казва на глас.
  Future<PendingInvite> invite() async {
    _pendingPair = await CoupleCrypto.newKeyPair();
    _pendingCode = CoupleCrypto.inviteCode();
    await _backend.createPairing(
      _pendingCode!,
      await CoupleCrypto.publicKeyBytes(_pendingPair!),
    );
    _status = PartnerStatus.inviting;
    return PendingInvite(_pendingCode!);
  }

  /// Страна А: проверява дали поканата е приета; при да — връща SAS
  /// емоджитата за гласовата проверка.
  Future<List<String>?> inviteAccepted() async {
    final code = _pendingCode;
    final pair = _pendingPair;
    if (code == null || pair == null) return null;
    final state = await _backend.pairingState(code);
    final pubB = state?.pubB;
    if (pubB == null) return null;
    _coupleKey = await CoupleCrypto.sharedKey(pair, pubB);
    return CoupleCrypto.verificationEmojis(_coupleKey!);
  }

  /// Страна Б: приема покана по код; връща SAS емоджитата или null
  /// при непознат/изтекъл код.
  Future<List<String>?> accept(String code) async {
    _pendingPair = await CoupleCrypto.newKeyPair();
    _pendingCode = code.toUpperCase().trim();
    final pubA = await _backend.joinPairing(
      _pendingCode!,
      await CoupleCrypto.publicKeyBytes(_pendingPair!),
    );
    if (pubA == null) return null;
    _coupleKey = await CoupleCrypto.sharedKey(_pendingPair!, pubA);
    return CoupleCrypto.verificationEmojis(_coupleKey!);
  }

  /// И двете страни: емоджитата съвпаднаха → връзката е официална.
  Future<void> confirm() async {
    final key = _coupleKey;
    final code = _pendingCode;
    if (key == null || code == null) {
      throw StateError('Няма активно сдвояване');
    }
    _coupleId = await _backend.completePairing(code);
    await SecureStore.write(
        _keyKey, base64Encode(await key.extractBytes()));
    await SecureStore.write(_idKey, _coupleId!);
    _status = PartnerStatus.linked;
    _pendingPair = null;
    _pendingCode = null;
  }

  /// Отказ от текущото сдвояване (емоджитата не съвпаднаха / отказ).
  /// Поканата на сървъра изтича сама след 15 минути.
  void cancelPending() {
    _pendingPair = null;
    _pendingCode = null;
    if (_status != PartnerStatus.linked) {
      _coupleKey = null;
      _status = PartnerStatus.none;
    }
  }

  /// Споделя бележка — на сървъра пристига само шифрован блок.
  Future<void> shareNote(String text, {DateTime? at}) async {
    final key = _requireLinked();
    final sealed = await CoupleCrypto.seal({
      'text': text,
      'at': (at ?? DateTime.now()).toIso8601String(),
    }, key);
    await _backend.push(SharedItem(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      coupleId: _coupleId!,
      author: await _author(),
      kind: SharedKind.note,
      sealed: sealed,
      createdAt: DateTime.now(),
    ));
  }

  /// Изтегля и декриптира споделеното; чужди/повредени блокове се
  /// пропускат тихо (по-добре липсваща бележка от крив текст).
  Future<List<({String author, bool mine, dynamic payload, SharedKind kind})>>
      inbox({DateTime? since}) async {
    final key = _requireLinked();
    final me = await _author();
    final items = await _backend.pull(_coupleId!, since: since);
    final result =
        <({String author, bool mine, dynamic payload, SharedKind kind})>[];
    for (final item in items) {
      try {
        result.add((
          author: item.author,
          mine: item.author == me,
          payload: await CoupleCrypto.open(item.sealed, key),
          kind: item.kind,
        ));
      } catch (_) {
        // Невалиден блок — игнорираме.
      }
    }
    return result;
  }

  /// Едностранно прекъсване: спира канала и чисти локалните ключове.
  Future<void> unlink() async {
    if (_coupleId != null) await _backend.dissolve(_coupleId!);
    await SecureStore.delete(_keyKey);
    await SecureStore.delete(_idKey);
    _coupleKey = null;
    _coupleId = null;
    _status = PartnerStatus.none;
  }

  SecretKey _requireLinked() {
    final key = _coupleKey;
    if (key == null || _coupleId == null) {
      throw StateError('Няма свързан партньор');
    }
    return key;
  }
}
