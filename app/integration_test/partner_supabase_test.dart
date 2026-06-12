import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intima/partner/couple_crypto.dart';
import 'package:intima/partner/supabase_backend.dart';
import 'package:intima/partner/sync_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Диагностика от устройството срещу РЕАЛНИЯ Supabase проект: пълно
/// сдвояване с две анонимни идентичности + шифрована бележка.
/// Оставя сървъра чист след себе си (dissolve).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('реален Supabase: сдвояване и E2E бележка от устройството',
      (tester) async {
    final backend = SupabaseBackend();
    final code = CoupleCrypto.inviteCode();

    // Страна А: първа анонимна идентичност кани.
    final pairA = await CoupleCrypto.newKeyPair();
    await backend.createPairing(
        code, await CoupleCrypto.publicKeyBytes(pairA));

    // Страна Б: нова анонимна идентичност на същото устройство приема.
    await Supabase.instance.client.auth.signOut();
    await Supabase.instance.client.auth.signInAnonymously();
    final pairB = await CoupleCrypto.newKeyPair();
    final pubA = await backend.joinPairing(
        code, await CoupleCrypto.publicKeyBytes(pairB));
    expect(pubA, isNotNull, reason: 'join_pairing върна null');

    final keyB = await CoupleCrypto.sharedKey(pairB, pubA!);
    final coupleId = await backend.completePairing(code);

    // Б споделя шифрована бележка, тегли я обратно и я отваря.
    final sealed = await CoupleCrypto.seal({'text': 'диагностика 💜'}, keyB);
    await backend.push(SharedItem(
      id: 'diag',
      coupleId: coupleId,
      author: (await backend.identity())!,
      kind: SharedKind.note,
      sealed: sealed,
      createdAt: DateTime.now(),
    ));
    final items = await backend.pull(coupleId);
    expect(items, isNotEmpty);
    final opened = await CoupleCrypto.open(items.last.sealed, keyB);
    expect(opened['text'], 'диагностика 💜');

    // Чистим след себе си.
    await backend.dissolve(coupleId);
  });
}
