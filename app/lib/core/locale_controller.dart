import 'package:flutter/material.dart';

import '../security/secure_store.dart';

/// Изборът на език, персистиран в защитеното хранилище.
/// null = езикът на системата (по подразбиране).
class LocaleController extends ChangeNotifier {
  static const _key = 'app_locale';

  /// Поддържаните ръчни избори — отговарят на arb файловете.
  static const supported = ['bg', 'en'];

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> init() async {
    final stored = await SecureStore.read(_key);
    _locale = supported.contains(stored) ? Locale(stored!) : null;
  }

  Future<void> set(Locale? locale) async {
    if (locale == null) {
      await SecureStore.delete(_key);
    } else {
      await SecureStore.write(_key, locale.languageCode);
    }
    _locale = locale;
    notifyListeners();
  }
}

final localeController = LocaleController();
