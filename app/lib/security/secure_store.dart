import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Единствената точка за достъп до OS keystore-а (Android Keystore / iOS
/// Keychain). Тук живеят ключът на базата, PIN хешът и флаговете за сигурност.
abstract class SecureStore {
  static const _storage = FlutterSecureStorage();

  static const dbKey = 'db_key';
  static const pinHash = 'pin_hash';
  static const pinSalt = 'pin_salt';
  static const biometricOn = 'biometric_on';
  static const hideRecents = 'hide_recents';

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<void> delete(String key) => _storage.delete(key: key);

  /// GDPR изтриване — маха всичко, включително ключа на базата.
  static Future<void> wipeAll() => _storage.deleteAll();
}
