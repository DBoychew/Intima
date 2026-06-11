import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../core/cycle_settings.dart';
import 'secure_store.dart';

/// PIN + биометрично заключване. PIN-ът никога не се пази в чист вид —
/// само солен SHA-256 хеш в OS keystore-а.
class AppLock extends ChangeNotifier {
  final _auth = LocalAuthentication();

  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _locked = false;
  bool _decoyEnabled = false;
  bool _decoyActive = false;

  bool get pinEnabled => _pinEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get locked => _locked;

  /// Има ли конфигуриран фалшив (stealth) PIN.
  bool get decoyEnabled => _decoyEnabled;

  /// Отключено с фалшивия PIN — приложението се преструва на празно.
  bool get decoyActive => _decoyActive;

  /// Чете състоянието при старт — приложението тръгва заключено, ако има PIN.
  Future<void> init() async {
    _pinEnabled = await SecureStore.read(SecureStore.pinHash) != null;
    _biometricEnabled =
        await SecureStore.read(SecureStore.biometricOn) == '1';
    _decoyEnabled = await SecureStore.read(_decoyHashKey) != null;
    _decoyActive = false;
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
    // Без основен PIN фалшивият няма смисъл.
    await disableDecoyPin();
    notifyListeners();
  }

  // --- Stealth (фалшив PIN) ---
  static const _decoyHashKey = 'decoy_pin_hash';
  static const _decoySaltKey = 'decoy_pin_salt';

  Future<void> setDecoyPin(String pin) async {
    final rnd = Random.secure();
    final salt = List.generate(
      16,
      (_) => rnd.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await SecureStore.write(_decoySaltKey, salt);
    await SecureStore.write(_decoyHashKey, _hash(pin, salt));
    _decoyEnabled = true;
    notifyListeners();
  }

  Future<bool> checkDecoyPin(String pin) async {
    final salt = await SecureStore.read(_decoySaltKey);
    final hash = await SecureStore.read(_decoyHashKey);
    if (salt == null || hash == null) return false;
    return _hash(pin, salt) == hash;
  }

  Future<void> disableDecoyPin() async {
    await SecureStore.delete(_decoyHashKey);
    await SecureStore.delete(_decoySaltKey);
    _decoyEnabled = false;
    _decoyActive = false;
    notifyListeners();
  }

  /// Отключване с фалшивия PIN — празното копие на приложението.
  void unlockDecoy() {
    _decoyActive = true;
    // Настройките на цикъла изглеждат фабрични (само в паметта —
    // персистването е блокирано, докато decoy е активен).
    cycleSettings.resetToDefaults();
    unlock();
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
    // Заключването винаги излиза от stealth копието.
    _decoyActive = false;
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
