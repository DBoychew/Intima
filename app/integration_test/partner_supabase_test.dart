import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intima/partner/supabase_backend.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Диагностика от устройството срещу РЕАЛНИЯ Supabase проект: сдвояване
/// с две анонимни идентичности + текстово съобщение. Изисква новата
/// схема (supabase/schema.sql) да е приложена. Чисти след себе си.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('реален Supabase: сдвояване и съобщение от устройството',
      (tester) async {
    final backend = SupabaseBackend();
    await SupabaseBackend.ensureInitialized();
    final client = Supabase.instance.client;

    // Идентичност А кани.
    final code = 'D${DateTime.now().millisecondsSinceEpoch % 100000000}';
    await backend.createPairing(code);

    // Идентичност Б (нова анонимна сесия на същото устройство) приема.
    await client.auth.signOut();
    await client.auth.signInAnonymously();
    final coupleId = await backend.joinPairing(code);
    expect(coupleId, isNotNull, reason: 'join_pairing върна null');

    final bId = client.auth.currentUser!.id;
    await backend.sendMessage(
      coupleId: coupleId!,
      author: bId,
      body: 'диагностика 💜',
    );
    final msgs = await backend.messages(coupleId);
    expect(msgs.any((m) => m.body == 'диагностика 💜'), isTrue);

    await backend.dissolve(coupleId);
  });
}
