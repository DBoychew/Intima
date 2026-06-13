import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/partner/partner_repository.dart';
import 'package:intima/partner/sync_backend.dart';

/// Помощник: изпълнява действие „като" дадено устройство (mock-ът
/// определя идентичността по currentDevice).
Future<T> as<T>(
  InMemoryPartnerBackend server,
  String device,
  Future<T> Function() op,
) {
  server.currentDevice = device;
  return op();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Future<String> link(
    InMemoryPartnerBackend server,
    PartnerRepository ana,
    PartnerRepository boris, {
    String a = 'ana',
    String b = 'boris',
  }) async {
    final code = await as(server, a, ana.invite);
    final pB = await as(server, b, () => boris.accept(code));
    final pA = await as(server, a, ana.pollInvite);
    expect(pA, isNotNull);
    expect(pA!.coupleId, pB!.coupleId);
    return pA.coupleId;
  }

  test('сдвояване: покана → приемане създава двойка и за двамата', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);

    final code = await as(server, 'ana', ana.invite);
    // Преди някой да приеме, канещият не вижда двойка.
    expect(await as(server, 'ana', ana.pollInvite), isNull);

    final pB = await as(server, 'boris', () => boris.accept(code));
    expect(pB, isNotNull);
    final pA = await as(server, 'ana', ana.pollInvite);
    expect(pA!.coupleId, pB!.coupleId);
  });

  test('невалиден код връща null', () async {
    final server = InMemoryPartnerBackend();
    final boris = PartnerRepository(server);
    expect(await as(server, 'boris', () => boris.accept('НЯМАТАКЪВ')), isNull);
  });

  test('чат: текст и снимка в двете посоки, мое/чуждо', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);

    await as(server, 'ana', () => ana.sendText(couple, 'Здравей 💜'));
    await as(
        server, 'boris', () => boris.sendImage(couple, '/local/pic.jpg'));

    final chat = await as(server, 'ana', () => ana.chat(couple));
    expect(chat, hasLength(2));
    expect(chat[0].body, 'Здравей 💜');
    expect(chat[0].mine, isTrue);
    expect(chat[1].mediaKind, MediaKind.image);
    expect(chat[1].mediaUrl, '/local/pic.jpg'); // mock връща пътя
    expect(chat[1].mine, isFalse);

    // Същият чат от страната на Борис — „мое/чуждо" е обърнато.
    final chatB = await as(server, 'boris', () => boris.chat(couple));
    expect(chatB[0].mine, isFalse);
    expect(chatB[1].mine, isTrue);
  });

  test('видео съобщение носи правилния вид', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);

    await as(server, 'ana', () => ana.sendVideo(couple, '/local/clip.mp4'));
    final chat = await as(server, 'boris', () => boris.chat(couple));
    expect(chat.single.mediaKind, MediaKind.video);
    expect(chat.single.mediaUrl, '/local/clip.mp4');
  });

  test('съобщенията се пазят в явен вид на сървъра (без E2E — по дизайн)',
      () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);

    await as(server, 'ana', () => ana.sendText(couple, 'явен текст'));
    final stored = server.storedMessages(couple).single;
    expect(stored.body, 'явен текст');
  });

  test('няколко партньора', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final b1 = PartnerRepository(server);
    final b2 = PartnerRepository(server);

    await link(server, ana, b1, b: 'b1');
    await link(server, ana, b2, b: 'b2');

    await as(server, 'ana', ana.refreshPartners);
    expect(ana.partners, hasLength(2));
    // Всеки партньор вижда само своята двойка.
    await as(server, 'b1', b1.refreshPartners);
    expect(b1.partners, hasLength(1));
  });

  test('псевдоним на партньор се пази локално', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);

    await as(server, 'ana', () => ana.setNickname(couple, 'Н.'));
    await as(server, 'ana', ana.refreshPartners);
    expect(ana.partners.single.nickname, 'Н.');
  });

  test('couple match: само взаимните пози се разкриват', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);

    // Само Ана иска „spooning" → още няма съвпадение.
    await as(server, 'ana', () => ana.sharePoseInterest('spooning', true));
    await as(server, 'ana', ana.refreshPartners);
    expect(await as(server, 'ana', ana.refreshMatches), isEmpty);

    // Ана иска и „on_top"; Борис иска „on_top" → съвпадение само за него.
    await as(server, 'ana', () => ana.sharePoseInterest('on_top', true));
    await as(server, 'boris', boris.refreshPartners);
    await as(server, 'boris', () => boris.sharePoseInterest('on_top', true));

    final freshForBoris = await as(server, 'boris', boris.refreshMatches);
    expect(freshForBoris.map((m) => m.poseId), ['on_top']);
    expect(freshForBoris.single.coupleId, couple);
    // „spooning" не е взаимно → не се разкрива.
    expect(boris.matchedPoseIds, {'on_top'});

    // Повторно извикване не дава „нови" (вече видяно).
    expect(await as(server, 'boris', boris.refreshMatches), isEmpty);
    expect(boris.matchedPoseIds, {'on_top'});
  });

  test('couple match: махане на интерес премахва съвпадението', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    await link(server, ana, boris);
    await as(server, 'ana', ana.refreshPartners);
    await as(server, 'boris', boris.refreshPartners);

    await as(server, 'ana', () => ana.sharePoseInterest('standing', true));
    await as(server, 'boris', () => boris.sharePoseInterest('standing', true));
    expect((await as(server, 'ana', ana.refreshMatches)).single.poseId,
        'standing');

    // Ана се отказва → вече няма съвпадение.
    await as(server, 'ana', () => ana.sharePoseInterest('standing', false));
    await as(server, 'boris', boris.refreshMatches);
    expect(boris.matchedPoseIds, isEmpty);
  });

  test('прекъсване спира чата и трие съдържанието', () async {
    final server = InMemoryPartnerBackend();
    final ana = PartnerRepository(server);
    final boris = PartnerRepository(server);
    final couple = await link(server, ana, boris);
    await as(server, 'ana', () => ana.sendText(couple, 'преди'));

    await as(server, 'ana', () => ana.unlink(couple));
    expect(ana.partners, isEmpty);

    expect(await as(server, 'boris', () => boris.chat(couple)), isEmpty);
    expect(() => as(server, 'boris', () => boris.sendText(couple, 'след')),
        throwsA(anything));
  });
}
