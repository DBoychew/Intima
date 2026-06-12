import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/theme_controller.dart';
import 'package:intima/theme/palettes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Тема и палитра: по подразбиране, смяна, персистентност', () async {
    final c = ThemeController();
    await c.init();
    expect(c.mode, ThemeMode.dark);
    expect(c.palette, AppPalette.intima);

    var notified = 0;
    c.addListener(() => notified++);
    await c.set(ThemeMode.light);
    await c.setPalette(AppPalette.roseGold);
    expect(notified, 2);

    // Нова инстанция = нов старт — изборът се пази.
    final restarted = ThemeController();
    await restarted.init();
    expect(restarted.mode, ThemeMode.light);
    expect(restarted.palette, AppPalette.roseGold);
  });

  test('Палитра: непознат запис в хранилището връща класиката', () {
    expect(AppPalette.fromStored(null), AppPalette.intima);
    expect(AppPalette.fromStored('несъществуваща'), AppPalette.intima);
    expect(AppPalette.fromStored('ocean'), AppPalette.ocean);
  });

  test('Палитри: всяка има различими ключови цветове в двата режима', () {
    for (final p in AppPalette.values) {
      for (final c in [p.dark, p.light]) {
        // Семантичните цветове не бива да се сливат един с друг.
        final key = {c.primary, c.accent, c.period, c.fertile};
        expect(key.length, 4, reason: '$p: ключови цветове се повтарят');
        // Текстът трябва да се различава от фона.
        expect(c.textPrimary, isNot(c.background));
      }
    }
    // Premium флагът: класиката е безплатна, останалите не са.
    expect(AppPalette.intima.isPremium, isFalse);
    expect(AppPalette.values.where((p) => p.isPremium).length, 3);
  });
}
