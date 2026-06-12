import 'package:flutter/material.dart';

import '../security/secure_store.dart';
import '../theme/palettes.dart';

/// Изборът на тема и палитра, персистиран в защитеното хранилище.
/// Тъмната тема и палитрата „Intima" са по подразбиране (бранд);
/// светлата/системната тема и останалите палитри са Premium.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';
  static const _paletteKey = 'theme_palette';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  AppPalette _palette = AppPalette.intima;
  AppPalette get palette => _palette;

  Future<void> init() async {
    _mode = switch (await SecureStore.read(_key)) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    _palette = AppPalette.fromStored(await SecureStore.read(_paletteKey));
  }

  Future<void> set(ThemeMode mode) async {
    await SecureStore.write(_key, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
      _ => 'dark',
    });
    _mode = mode;
    notifyListeners();
  }

  Future<void> setPalette(AppPalette palette) async {
    await SecureStore.write(_paletteKey, palette.storageValue);
    _palette = palette;
    notifyListeners();
  }
}

final themeController = ThemeController();
