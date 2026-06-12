import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// E2E криптографията на Partner Mode (виж docs/design/PARTNER_MODE.md).
/// Тук НЯМА мрежа — само ключове и шифроване; сървърът никога не
/// получава нищо от този файл освен публичните ключове.

/// Недвусмислена азбука за поканите — без 0/O, 1/I/l.
const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/// Емоджитата за гласовата проверка (SAS) — лесни за казване.
const sasEmojis = [
  '💜', '🌙', '🌸', '⭐', '🔥', '🌊', '🍀', '🎵',
  '☀️', '🦋', '🍓', '🌈', '💎', '🕊️', '🌿', '🎈',
];

final _x25519 = X25519();
final _aesGcm = AesGcm.with256bits();
final _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);

/// Шифрован блок така, както пътува към сървъра — само байтове.
class SealedBox {
  const SealedBox({
    required this.cipherText,
    required this.nonce,
    required this.mac,
  });

  final Uint8List cipherText;
  final Uint8List nonce;
  final Uint8List mac;

  /// За транспорт/тестове: base64(nonce).base64(cipher).base64(mac).
  String encode() => [
        base64Encode(nonce),
        base64Encode(cipherText),
        base64Encode(mac),
      ].join('.');

  static SealedBox decode(String value) {
    final parts = value.split('.');
    if (parts.length != 3) {
      throw const FormatException('Невалиден SealedBox формат');
    }
    return SealedBox(
      nonce: base64Decode(parts[0]),
      cipherText: base64Decode(parts[1]),
      mac: base64Decode(parts[2]),
    );
  }
}

class CoupleCrypto {
  /// Генерира X25519 двойка за това устройство.
  static Future<SimpleKeyPair> newKeyPair() => _x25519.newKeyPair();

  static Future<Uint8List> publicKeyBytes(SimpleKeyPair pair) async =>
      Uint8List.fromList((await pair.extractPublicKey()).bytes);

  /// Общият ключ на двойката: ECDH + HKDF. И двете страни го изчисляват
  /// локално от своя частен и чуждия публичен ключ — не пътува никъде.
  static Future<SecretKey> sharedKey(
    SimpleKeyPair myPair,
    Uint8List theirPublicKey,
  ) async {
    final shared = await _x25519.sharedSecretKey(
      keyPair: myPair,
      remotePublicKey:
          SimplePublicKey(theirPublicKey, type: KeyPairType.x25519),
    );
    return _hkdf.deriveKey(
      secretKey: shared,
      nonce: const [], // солта е празна: и двете страни я знаят еднакво
      info: utf8.encode('intima-couple-v1'),
    );
  }

  /// Шифрова JSON-сериализуем обект за партньорския канал.
  static Future<SealedBox> seal(Object payload, SecretKey key) async {
    final clear = utf8.encode(jsonEncode(payload));
    final box = await _aesGcm.encrypt(clear, secretKey: key);
    return SealedBox(
      cipherText: Uint8List.fromList(box.cipherText),
      nonce: Uint8List.fromList(box.nonce),
      mac: Uint8List.fromList(box.mac.bytes),
    );
  }

  /// Декриптира [SealedBox]; хвърля при грешен ключ или подменени данни.
  static Future<dynamic> open(SealedBox sealed, SecretKey key) async {
    final clear = await _aesGcm.decrypt(
      SecretBox(sealed.cipherText, nonce: sealed.nonce, mac: Mac(sealed.mac)),
      secretKey: key,
    );
    return jsonDecode(utf8.decode(clear));
  }

  /// Двете SAS емоджита за гласова проверка — еднакви на двата екрана
  /// само ако споделеният ключ е наистина общ (хваща MITM при поканата).
  static Future<List<String>> verificationEmojis(SecretKey key) async {
    final bytes = await key.extractBytes();
    final digest = await Sha256().hash(bytes);
    return [
      sasEmojis[digest.bytes[0] % sasEmojis.length],
      sasEmojis[digest.bytes[1] % sasEmojis.length],
    ];
  }

  /// Еднократен код за покана — 8 знака, четим на глас.
  static String inviteCode({Random? random}) {
    final rng = random ?? Random.secure();
    return List.generate(
      8,
      (_) => _codeAlphabet[rng.nextInt(_codeAlphabet.length)],
    ).join();
  }
}
