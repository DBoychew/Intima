import 'package:flutter/material.dart';

import '../security/secure_store.dart';

/// Изборът на тема, персистиран в защитеното хранилище.
/// Тъмната е по подразбиране (бранд); светлата/системната са Premium.
class ThemeController extends ChangeNotifier {
  static const _key = 'theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  Future<void> init() async {
    _mode = switch (await SecureStore.read(_key)) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
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
}

final themeController = ThemeController();
