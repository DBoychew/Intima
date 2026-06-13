/// Видът на медията към съобщение.
enum MediaKind { none, image, video }

/// Едно чат съобщение така, както лежи на сървъра — в явен вид
/// (без E2E криптиране; вижда се и от модерацията). Виж
/// docs/design/PARTNER_MODE.md и Privacy Policy.
class Message {
  const Message({
    required this.id,
    required this.coupleId,
    required this.author,
    required this.createdAt,
    this.body,
    this.mediaPath,
    this.mediaKind = MediaKind.none,
  });

  final String id;
  final String coupleId;

  /// Анонимното auth id на автора.
  final String author;
  final String? body;

  /// Път до медията в Storage (или локален път при тестовия бекенд).
  final String? mediaPath;
  final MediaKind mediaKind;
  final DateTime createdAt;
}

/// Бекендът на партньорския чат. Реалната имплементация е Supabase;
/// InMemoryPartnerBackend е за тестове и локална разработка.
abstract class PartnerBackend {
  /// Идентичността, с която този клиент пише на сървъра. null =
  /// бекендът няма собствена (тестове) → ползва се локално id.
  Future<String?> identity() async => null;

  /// Кани: регистрира еднократен код.
  Future<void> createPairing(String code);

  /// Приема покана по код; връща couple_id или null при невалиден код.
  Future<String?> joinPairing(String code);

  /// Канещият проверява дали поканата е приета → couple_id или null.
  Future<String?> pairingCouple(String code);

  /// Двойките, в които участва текущият потребител.
  Future<List<String>> myCouples();

  /// Праща съобщение; при медия [mediaLocalPath] се качва и пътят се
  /// записва в реда.
  Future<void> sendMessage({
    required String coupleId,
    required String author,
    String? body,
    String? mediaLocalPath,
    MediaKind mediaKind = MediaKind.none,
  });

  /// Съобщенията на двойката след [since] (null = всички), хронологично.
  Future<List<Message>> messages(String coupleId, {DateTime? since});

  /// URL за показване на медия (подписан при Supabase); null при липса.
  Future<String?> mediaUrl(String? mediaPath);

  /// Couple Match: отбелязва/маха интерес към поза (само за текущия член).
  Future<void> setPoseInterest(String coupleId, String poseId, bool wanted);

  /// Само взаимните пози (и двамата искат).
  Future<List<String>> poseMatches(String coupleId);

  /// Едностранно прекъсване — спира канала и трие съдържанието.
  Future<void> dissolve(String coupleId);
}

/// In-memory сървър за тестове — държи се като реалния, но в паметта.
class InMemoryPartnerBackend extends PartnerBackend {
  InMemoryPartnerBackend();

  final _pairings = <String, String?>{}; // code -> couple_id (null = чака)
  final _pairingInviter = <String, String>{}; // code -> inviter device
  final _couples = <String, List<String>>{}; // couple_id -> [a, b]
  final _messages = <String, List<Message>>{};
  // coupleId → member → {poseId}
  final _interests = <String, Map<String, Set<String>>>{};
  final _dissolved = <String>{};
  var _nextCouple = 0;
  var _nextMsg = 0;

  /// Кой „извиква" в момента (тестовете го сменят между устройствата).
  String currentDevice = 'device';

  @override
  Future<String?> identity() async => currentDevice;

  @override
  Future<void> createPairing(String code) async {
    _pairings[code] = null;
    _pairingInviter[code] = currentDevice;
  }

  @override
  Future<String?> joinPairing(String code) async {
    if (!_pairings.containsKey(code) || _pairings[code] != null) return null;
    final inviter = _pairingInviter[code]!;
    if (inviter == currentDevice) return null;
    final id = 'couple-${_nextCouple++}';
    _couples[id] = [inviter, currentDevice];
    _messages[id] = [];
    _pairings[code] = id;
    return id;
  }

  @override
  Future<String?> pairingCouple(String code) async => _pairings[code];

  @override
  Future<List<String>> myCouples() async => [
        for (final e in _couples.entries)
          if (e.value.contains(currentDevice) &&
              !_dissolved.contains(e.key))
            e.key,
      ];

  @override
  Future<void> sendMessage({
    required String coupleId,
    required String author,
    String? body,
    String? mediaLocalPath,
    MediaKind mediaKind = MediaKind.none,
  }) async {
    if (_dissolved.contains(coupleId)) {
      throw StateError('Връзката е прекъсната');
    }
    _messages.putIfAbsent(coupleId, () => []).add(Message(
          id: 'm${_nextMsg++}',
          coupleId: coupleId,
          author: author,
          body: body,
          mediaPath: mediaLocalPath,
          mediaKind: mediaKind,
          createdAt: DateTime.fromMillisecondsSinceEpoch(_nextMsg * 1000),
        ));
  }

  @override
  Future<List<Message>> messages(String coupleId, {DateTime? since}) async {
    if (_dissolved.contains(coupleId)) return const [];
    return [
      for (final m in _messages[coupleId] ?? const <Message>[])
        if (since == null || m.createdAt.isAfter(since)) m,
    ];
  }

  @override
  Future<String?> mediaUrl(String? mediaPath) async => mediaPath;

  @override
  Future<void> setPoseInterest(
      String coupleId, String poseId, bool wanted) async {
    if (_dissolved.contains(coupleId)) return;
    final set = _interests
        .putIfAbsent(coupleId, () => {})
        .putIfAbsent(currentDevice, () => {});
    if (wanted) {
      set.add(poseId);
    } else {
      set.remove(poseId);
    }
  }

  @override
  Future<List<String>> poseMatches(String coupleId) async {
    if (_dissolved.contains(coupleId)) return const [];
    final byMember = _interests[coupleId];
    if (byMember == null || byMember.length < 2) return const [];
    final counts = <String, int>{};
    for (final s in byMember.values) {
      for (final p in s) {
        counts[p] = (counts[p] ?? 0) + 1;
      }
    }
    return [
      for (final e in counts.entries)
        if (e.value >= 2) e.key,
    ];
  }

  @override
  Future<void> dissolve(String coupleId) async {
    _dissolved.add(coupleId);
    _messages.remove(coupleId);
    _interests.remove(coupleId);
  }

  /// Само за тестове: каквото сървърът „вижда" за двойката.
  List<Message> storedMessages(String coupleId) =>
      List.unmodifiable(_messages[coupleId] ?? const []);
}
