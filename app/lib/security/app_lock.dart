import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import 'secure_store.dart';

/// PIN + биометрично заключване. PIN-ът никога не се пази в чист вид —
/// само солен SHA-256 хеш в OS keystore-а.
class AppLock extends ChangeNotifier {
  final _auth = LocalAuthentication();

  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _locked = false;

  bool get pinEnabled => _pinEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get locked => _locked;

  /// Чете състоянието при старт — приложението тръгва заключено, ако има PIN.
  Future<void> init() async {
    _pinEnabled = await SecureStore.read(SecureStore.pinHash) != null;
    _biometricEnabled =
        await SecureStore.read(SecureStore.biometricOn) == '1';
    _locked = _pinEnabled;
  }

  String _hash(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<void> setPin(String pin) async {
    final rnd = Random.secure();
    final salt = List.generate(
      16,
      (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await SecureStore.write(SecureStore.pinSalt, salt);
    await SecureStore.write(SecureStore.pinHash, _hash(pin, salt));
    _pinEnabled = true;
    notifyListeners();
  }

  /// Чиста проверка — не отключва (виж [unlock]).
  Future<bool> checkPin(String pin) async {
    final salt = await SecureStore.read(SecureStore.pinSalt);
    final hash = await SecureStore.read(SecureStore.pinHash);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  Future<void> disablePin() async {
    await SecureStore.delete(SecureStore.pinHash);
    await SecureStore.delete(SecureStore.pinSalt);
    _pinEnabled = false;
    _locked = false;
    notifyListeners();
  }

  Future<bool> canUseBiometrics() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> setBiometric(bool on) async {
    await SecureStore.write(SecureStore.biometricOn, on ? '1' : '0');
    _biometricEnabled = on;
    notifyListeners();
  }

  /// Биометрична автентикация; при успех отключва.
  Future<bool> tryBiometricUnlock() async {
    if (!_biometricEnabled) return false;
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Отключи Intima',
      );
      if (ok) unlock();
      return ok;
    } catch (_) {
      return false;
    }
  }

  void lock() {
    if (!_pinEnabled || _locked) return;
    _locked = true;
    notifyListeners();
  }

  void unlock() {
    if (!_locked) return;
    _locked = false;
    notifyListeners();
  }

  /// Извиква се след GDPR изтриване — keystore-ът вече е празен.
  Future<void> reload() async {
    await init();
    notifyListeners();
  }
}

final appLock = AppLock();
