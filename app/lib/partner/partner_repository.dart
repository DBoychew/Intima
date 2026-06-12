import 'dart:convert';
import 'dart:math';

import '../security/app_lock.dart';
import '../security/secure_store.dart';
import 'sync_backend.dart';

/// Един партньор (двойка) от гледна точка на този потребител.
class Partner {
  const Partner({required this.coupleId, this.nickname});

  final String coupleId;
  final String? nickname;
}

/// Едно съобщение, готово за показване в чата.
class ChatMessage {
  const ChatMessage({
    required this.author,
    required this.mine,
    required this.createdAt,
    this.body,
    this.mediaUrl,
    this.mediaKind = MediaKind.none,
  });

  final String author;
  final bool mine;
  final String? body;
  final String? mediaUrl;
  final MediaKind mediaKind;
  final DateTime createdAt;
}

/// Оркестрира Partner Mode: сдвояване с код, няколко партньора и чат
/// със снимки/видео. БЕЗ E2E криптиране — съдържанието се пази на
/// сървъра в явен вид (оповестено в Privacy Policy; виж PARTNER_MODE.md).
class PartnerRepository {
  PartnerRepository(this._backend, {String? deviceIdOverride})
      : _deviceIdOverride = deviceIdOverride;

  static const _deviceKey = 'partner_device_id';
  static const _nicknamesKey = 'partner_nicknames';

  final PartnerBackend _backend;

  /// За тестове: две „устройства" в един процес делят едно хранилище.
  final String? _deviceIdOverride;

  List<Partner> _partners = const [];
  List<Partner> get partners => _partners;
  bool get hasPartners => _partners.isNotEmpty;

  // Текуща покана при канещия.
  String? _pendingCode;
  String? get pendingCode => _pendingCode;

  Map<String, String> _nicknames = const {};

  /// Зарежда партньорите от сървъра (мрежата се пипа само тук, когато
  /// потребителката отвори екрана „Партньор").
  Future<void> init() async {
    _nicknames = _readNicknames(await SecureStore.read(_nicknamesKey));
    await refreshPartners();
  }

  Future<void> refreshPartners() async {
    // Stealth копието не разкрива партньори.
    if (appLock.decoyActive) {
      _partners = const [];
      return;
    }
    final ids = await _backend.myCouples();
    _partners = [
      for (final id in ids) Partner(coupleId: id, nickname: _nicknames[id]),
    ];
  }

  Map<String, String> _readNicknames(String? json) => json == null
      ? {}
      : (jsonDecode(json) as Map).map((k, v) => MapEntry('$k', '$v'));

  Future<String> _author() async =>
      (await _backend.identity()) ?? await _deviceId();

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

  /// 8-знаков еднократен код от недвусмислена азбука (без 0/O, 1/I/l).
  static String _inviteCode({Random? random}) {
    const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rng = random ?? Random.secure();
    return List.generate(8, (_) => alphabet[rng.nextInt(alphabet.length)])
        .join();
  }

  /// Страна А: създава покана; връща кода, който се казва на партньора.
  Future<String> invite() async {
    _pendingCode = _inviteCode();
    // В stealth кодът е инертен — нищо реално не се създава.
    if (appLock.decoyActive) return _pendingCode!;
    await _backend.createPairing(_pendingCode!);
    return _pendingCode!;
  }

  /// Страна А: проверява дали поканата е приета → новата двойка или null.
  Future<Partner?> pollInvite() async {
    final code = _pendingCode;
    if (code == null || appLock.decoyActive) return null;
    final coupleId = await _backend.pairingCouple(code);
    if (coupleId == null) return null;
    _pendingCode = null;
    await refreshPartners();
    return _partners.firstWhere((p) => p.coupleId == coupleId,
        orElse: () => Partner(coupleId: coupleId));
  }

  void cancelInvite() => _pendingCode = null;

  /// Страна Б: приема покана по код → новата двойка или null при
  /// невалиден/изтекъл код.
  Future<Partner?> accept(String code) async {
    if (appLock.decoyActive) return null;
    final coupleId = await _backend.joinPairing(code.toUpperCase().trim());
    if (coupleId == null) return null;
    await refreshPartners();
    return _partners.firstWhere((p) => p.coupleId == coupleId,
        orElse: () => Partner(coupleId: coupleId));
  }

  Future<void> setNickname(String coupleId, String nickname) async {
    final next = Map<String, String>.from(_nicknames);
    if (nickname.trim().isEmpty) {
      next.remove(coupleId);
    } else {
      next[coupleId] = nickname.trim();
    }
    _nicknames = next;
    await SecureStore.write(_nicknamesKey, jsonEncode(next));
    await refreshPartners();
  }

  Future<void> sendText(String coupleId, String text) =>
      _send(coupleId, body: text);

  Future<void> sendImage(String coupleId, String path) =>
      _send(coupleId, mediaLocalPath: path, mediaKind: MediaKind.image);

  Future<void> sendVideo(String coupleId, String path) =>
      _send(coupleId, mediaLocalPath: path, mediaKind: MediaKind.video);

  Future<void> _send(
    String coupleId, {
    String? body,
    String? mediaLocalPath,
    MediaKind mediaKind = MediaKind.none,
  }) async {
    await _backend.sendMessage(
      coupleId: coupleId,
      author: await _author(),
      body: body,
      mediaLocalPath: mediaLocalPath,
      mediaKind: mediaKind,
    );
  }

  /// Чат историята на двойката, хронологично, с готови URL-и за медията.
  Future<List<ChatMessage>> chat(String coupleId, {DateTime? since}) async {
    if (appLock.decoyActive) return const [];
    final me = await _author();
    final raw = await _backend.messages(coupleId, since: since);
    return [
      for (final m in raw)
        ChatMessage(
          author: m.author,
          mine: m.author == me,
          body: m.body,
          mediaUrl: await _backend.mediaUrl(m.mediaPath),
          mediaKind: m.mediaKind,
          createdAt: m.createdAt,
        ),
    ];
  }

  /// Прекъсва връзката с конкретен партньор.
  Future<void> unlink(String coupleId) async {
    await _backend.dissolve(coupleId);
    await setNickname(coupleId, '');
    await refreshPartners();
  }
}
