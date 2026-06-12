import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/partner/couple_crypto.dart';
import 'package:intima/partner/partner_repository.dart';
import 'package:intima/partner/sync_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('CoupleCrypto', () {
    test('двете страни извличат еднакъв общ ключ (ECDH)', () async {
      final ana = await CoupleCrypto.newKeyPair();
      final boris = await CoupleCrypto.newKeyPair();

      final keyA = await CoupleCrypto.sharedKey(
          ana, await CoupleCrypto.publicKeyBytes(boris));
      final keyB = await CoupleCrypto.sharedKey(
          boris, await CoupleCrypto.publicKeyBytes(ana));

      expect(await keyA.extractBytes(), await keyB.extractBytes());
      // SAS емоджитата също съвпадат — това сравняват на глас.
      expect(await CoupleCrypto.verificationEmojis(keyA),
          await CoupleCrypto.verificationEmojis(keyB));
    });

    test('seal/open кръг + грешен ключ е отхвърлен', () async {
      final ana = await CoupleCrypto.newKeyPair();
      final boris = await CoupleCrypto.newKeyPair();
      final key = await CoupleCrypto.sharedKey(
          ana, await CoupleCrypto.publicKeyBytes(boris));

      final sealed = await CoupleCrypto.seal(
          {'text': 'Мисля за теб 💜'}, key);
      final opened = await CoupleCrypto.open(sealed, key);
      expect(opened['text'], 'Мисля за теб 💜');

      // Кодиране за транспорт — кръгът също е верен.
      final decoded = SealedBox.decode(sealed.encode());
      expect((await CoupleCrypto.open(decoded, key))['text'],
          'Мисля за теб 💜');

      // Трета страна със собствен ключ не може да чете.
      final eve = await CoupleCrypto.newKeyPair();
      final wrongKey = await CoupleCrypto.sharedKey(
          eve, await CoupleCrypto.publicKeyBytes(ana));
      expect(() => CoupleCrypto.open(sealed, wrongKey), throwsA(anything));
    });

    test('кодът за покана е 8 знака от недвусмислената азбука', () {
      final code = CoupleCrypto.inviteCode(random: Random(42));
      expect(code.length, 8);
      expect(RegExp(r'^[ABCDEFGHJKMNPQRSTUVWXYZ23456789]+$').hasMatch(code),
          isTrue);
      // Различни генерации → различни кодове (детерминистично с seed).
      expect(CoupleCrypto.inviteCode(random: Random(1)),
          isNot(CoupleCrypto.inviteCode(random: Random(2))));
    });
  });

  group('Сдвояване и споделяне през mock сървъра', () {
    test('пълен флоу: покана → SAS → бележки в двете посоки', () async {
      final server = InMemorySyncBackend();
      final ana = PartnerRepository(server, deviceIdOverride: 'ana');
      final boris = PartnerRepository(server, deviceIdOverride: 'boris');

      // Ана кани, Борис приема с кода.
      final invite = await ana.invite();
      expect(ana.status, PartnerStatus.inviting);
      final sasBoris = await boris.accept(invite.code);
      final sasAna = await ana.inviteAccepted();

      // Емоджитата съвпадат → потвърждават и двамата.
      expect(sasAna, isNotNull);
      expect(sasAna, sasBoris);
      await ana.confirm();
      await boris.confirm();
      expect(ana.status, PartnerStatus.linked);
      expect(ana.coupleId, boris.coupleId);

      // Бележки в двете посоки.
      await ana.shareNote('Довечера в 8? 💜');
      await boris.shareNote('Да! Аз нося виното 🍷');

      final anaInbox = await ana.inbox();
      expect(anaInbox, hasLength(2));
      expect(anaInbox.map((m) => m.payload['text']),
          containsAll(['Довечера в 8? 💜', 'Да! Аз нося виното 🍷']));
      expect(anaInbox.firstWhere((m) => m.author == 'boris').payload['text'],
          'Да! Аз нося виното 🍷');
    });

    test('сървърът вижда само шифровани байтове', () async {
      final server = InMemorySyncBackend();
      final ana = PartnerRepository(server, deviceIdOverride: 'ana');
      final boris = PartnerRepository(server, deviceIdOverride: 'boris');
      final invite = await ana.invite();
      await boris.accept(invite.code);
      await ana.inviteAccepted();
      await ana.confirm();
      await boris.confirm();

      const secret = 'Много лично съдържание';
      await ana.shareNote(secret);

      final stored = server.storedItems(ana.coupleId!).single;
      final wire = stored.sealed.encode();
      // Нито явният текст, нито base64 формата му се виждат по жицата.
      expect(wire.contains(secret), isFalse);
      expect(wire.contains(base64Encode(utf8.encode(secret))), isFalse);
      // А партньорът си го чете нормално.
      final inbox = await boris.inbox();
      expect(inbox.single.payload['text'], secret);
    });

    test('грешен код връща null, прекъсването спира канала', () async {
      final server = InMemorySyncBackend();
      final ana = PartnerRepository(server, deviceIdOverride: 'ana');
      final boris = PartnerRepository(server, deviceIdOverride: 'boris');

      expect(await boris.accept('НЕСЪЩЕСТВУВАЩ'), isNull);

      final invite = await ana.invite();
      await boris.accept(invite.code);
      await ana.inviteAccepted();
      await ana.confirm();
      await boris.confirm();
      await ana.shareNote('преди раздялата');

      // Борис прекъсва едностранно → каналът е мъртъв и за двамата.
      await boris.unlink();
      expect(boris.status, PartnerStatus.none);
      expect(await ana.inbox(), isEmpty);
      expect(() => ana.shareNote('след раздялата'), throwsA(anything));
    });

    test('persist: нова инстанция след рестарт остава свързана', () async {
      final server = InMemorySyncBackend();
      final ana = PartnerRepository(server, deviceIdOverride: 'ana');
      final boris = PartnerRepository(server, deviceIdOverride: 'boris');
      final invite = await ana.invite();
      await boris.accept(invite.code);
      await ana.inviteAccepted();
      await ana.confirm();
      await boris.confirm();
      await boris.shareNote('пази ме след рестарт');

      // „Рестарт" на приложението на Ана.
      final restarted = PartnerRepository(server, deviceIdOverride: 'ana');
      await restarted.init();
      expect(restarted.status, PartnerStatus.linked);
      expect((await restarted.inbox()).single.payload['text'],
          'пази ме след рестарт');
    });
  });
}
