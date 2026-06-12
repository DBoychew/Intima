import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Език: системен по подразбиране, смяна, персистентност', () async {
    final c = LocaleController();
    await c.init();
    expect(c.locale, isNull); // следва системата

    var notified = 0;
    c.addListener(() => notified++);
    await c.set(const Locale('en'));
    expect(c.locale, const Locale('en'));
    expect(notified, 1);

    // Нова инстанция = нов старт — изборът се пази.
    final restarted = LocaleController();
    await restarted.init();
    expect(restarted.locale, const Locale('en'));

    // Връщане към системния = изтрит запис.
    await c.set(null);
    expect(c.locale, isNull);
    final again = LocaleController();
    await again.init();
    expect(again.locale, isNull);
  });

  test('Език: непознат запис в хранилището пада към системния', () async {
    FlutterSecureStorage.setMockInitialValues({'app_locale': 'de'});
    final c = LocaleController();
    await c.init();
    expect(c.locale, isNull);
  });
}
