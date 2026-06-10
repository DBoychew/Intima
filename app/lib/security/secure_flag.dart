import 'dart:io';

import 'package:flutter/services.dart';

import 'secure_store.dart';

/// Скрива съдържанието в recent apps и блокира скрийншоти (FLAG_SECURE).
/// MainActivity го пуска по подразбиране — Dart само синхронизира избора.
abstract class SecureFlag {
  static const _channel = MethodChannel('intima/secure_flag');

  static Future<void> set(bool on) async {
    await SecureStore.write(SecureStore.hideRecents, on ? '1' : '0');
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('setSecureFlag', on);
    } on PlatformException {
      // Прототип/тестова среда без канала — флагът остава както е от
      // MainActivity (включен по подразбиране).
    }
  }

  /// Включено по подразбиране — изключва се само с изричен избор.
  static Future<bool> enabled() async =>
      await SecureStore.read(SecureStore.hideRecents) != '0';

  static Future<void> applyAtStartup() async => set(await enabled());
}
