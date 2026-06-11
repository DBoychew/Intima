import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/security/app_lock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('PIN: задаване, проверка, грешен PIN, изключване', () async {
    final lock = AppLock();
    await lock.init();
    expect(lock.pinEnabled, isFalse);
    expect(lock.locked, isFalse);

    await lock.setPin('1234');
    expect(lock.pinEnabled, isTrue);
    expect(await lock.checkPin('1234'), isTrue);
    expect(await lock.checkPin('0000'), isFalse);

    await lock.disablePin();
    expect(lock.pinEnabled, isFalse);
    expect(await lock.checkPin('1234'), isFalse);
  });

  test('приложението тръгва заключено само ако има PIN', () async {
    final first = AppLock();
    await first.setPin('5678');

    // Нова инстанция = нов старт на приложението.
    final restarted = AppLock();
    await restarted.init();
    expect(restarted.locked, isTrue);

    restarted.unlock();
    expect(restarted.locked, isFalse);

    // lock() заключва отново, но само при активен PIN.
    restarted.lock();
    expect(restarted.locked, isTrue);
  });

  test('PIN хешът не пази PIN-а в чист вид', () async {
    final lock = AppLock();
    await lock.setPin('1234');
    final stored = await const FlutterSecureStorage().readAll();
    expect(stored.values.any((v) => v.contains('1234')), isFalse);
  });

  test('Stealth: фалшив PIN — отделен, активира decoy, чисти се', () async {
    final lock = AppLock();
    await lock.setPin('1234');
    await lock.setDecoyPin('5678');
    expect(lock.decoyEnabled, isTrue);

    // Фалшивият PIN не минава като истински и обратно.
    expect(await lock.checkPin('5678'), isFalse);
    expect(await lock.checkDecoyPin('5678'), isTrue);
    expect(await lock.checkDecoyPin('1234'), isFalse);

    lock.lock();
    lock.unlockDecoy();
    expect(lock.decoyActive, isTrue);
    expect(lock.locked, isFalse);

    // Заключването излиза от stealth копието.
    lock.lock();
    expect(lock.decoyActive, isFalse);

    // Изключването на основния PIN маха и фалшивия.
    await lock.disablePin();
    expect(lock.decoyEnabled, isFalse);
    expect(await lock.checkDecoyPin('5678'), isFalse);
  });
}
