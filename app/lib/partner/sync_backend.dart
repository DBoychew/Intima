import 'dart:typed_data';

import 'couple_crypto.dart';

/// Видът на споделеното нещо — единствената нешифрована семантика,
/// нужна за ефективен pull. Не издава съдържание.
enum SharedKind { note, calendarMark, nudge }

/// Шифрован запис така, както лежи на сървъра.
class SharedItem {
  const SharedItem({
    required this.id,
    required this.coupleId,
    required this.author,
    required this.kind,
    required this.sealed,
    required this.createdAt,
  });

  final String id;
  final String coupleId;

  /// Анонимното device id на автора.
  final String author;
  final SharedKind kind;
  final SealedBox sealed;
  final DateTime createdAt;
}

/// Текущото състояние на една покана на сървъра.
class PairingState {
  const PairingState({required this.pubA, this.pubB});

  final Uint8List pubA;
  final Uint8List? pubB;

  bool get completed => pubB != null;
}

/// Абстракцията към сървъра. Получава САМО публични ключове и
/// шифровани блокчета — нищо четимо. Реалната имплементация
/// (SupabaseBackend) чака проекта; InMemorySyncBackend е за тестове
/// и локална разработка.
abstract class SyncBackend {
  /// Идентичността, с която този клиент пише на сървъра — за
  /// различаване „мое/чуждо". null = бекендът няма собствена
  /// (тестове); тогава се ползва локалното device id.
  Future<String?> identity() async => null;

  /// Кани: регистрира [code] с публичния ключ на канещия.
  Future<void> createPairing(String code, Uint8List pubA);

  /// Приема: връща публичния ключ на канещия и записва [pubB];
  /// null при непознат/изтекъл код.
  Future<Uint8List?> joinPairing(String code, Uint8List pubB);

  /// Канещият проверява дали другата страна е приела.
  Future<PairingState?> pairingState(String code);

  /// Двамата потвърдиха SAS → кодът се унищожава, ражда се couple id.
  Future<String> completePairing(String code);

  Future<void> push(SharedItem item);

  /// Записите на двойката след [since] (null = всички).
  Future<List<SharedItem>> pull(String coupleId, {DateTime? since});

  /// Едностранно прекъсване — спира канала за двамата.
  Future<void> dissolve(String coupleId);
}

/// In-memory сървър за тестове: държи се като реалния, включително
/// еднократните кодове, но живее в паметта на процеса.
class InMemorySyncBackend extends SyncBackend {
  final _pairings = <String, PairingState>{};
  final _completed = <String, String>{};
  final _items = <String, List<SharedItem>>{};
  final _dissolved = <String>{};
  var _nextCoupleId = 0;

  @override
  Future<void> createPairing(String code, Uint8List pubA) async {
    _pairings[code] = PairingState(pubA: pubA);
  }

  @override
  Future<Uint8List?> joinPairing(String code, Uint8List pubB) async {
    final pairing = _pairings[code];
    if (pairing == null || pairing.completed) return null;
    _pairings[code] = PairingState(pubA: pairing.pubA, pubB: pubB);
    return pairing.pubA;
  }

  @override
  Future<PairingState?> pairingState(String code) async => _pairings[code];

  @override
  Future<String> completePairing(String code) async {
    // Идемпотентно: и двете страни потвърждават и получават едно id.
    final existing = _completed[code];
    if (existing != null) return existing;
    _pairings.remove(code);
    final id = 'couple-${_nextCoupleId++}';
    _completed[code] = id;
    _items[id] = [];
    return id;
  }

  @override
  Future<void> push(SharedItem item) async {
    if (_dissolved.contains(item.coupleId)) {
      throw StateError('Връзката е прекъсната');
    }
    _items.putIfAbsent(item.coupleId, () => []).add(item);
  }

  @override
  Future<List<SharedItem>> pull(String coupleId, {DateTime? since}) async {
    if (_dissolved.contains(coupleId)) return const [];
    return [
      for (final item in _items[coupleId] ?? const <SharedItem>[])
        if (since == null || item.createdAt.isAfter(since)) item,
    ];
  }

  @override
  Future<void> dissolve(String coupleId) async {
    _dissolved.add(coupleId);
    _items.remove(coupleId);
  }

  /// Само за тестове: каквото сървърът „вижда" за двойката.
  List<SharedItem> storedItems(String coupleId) =>
      List.unmodifiable(_items[coupleId] ?? const []);
}
