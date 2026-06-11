import 'package:flutter/foundation.dart';

import '../security/secure_store.dart';

/// Източник на истината за Premium статуса.
///
/// MVP: локален флаг в защитеното хранилище. Когато billing-ът влезе
/// (Play Billing/RevenueCat, чака Play акаунта), той ще управлява този
/// флаг — интерфейсът към UI-я остава същият.
class Premium extends ChangeNotifier {
  static const _key = 'premium_active';

  bool _active = false;
  bool get active => _active;

  Future<void> init() async {
    _active = await SecureStore.read(_key) == '1';
  }

  /// Активира Premium локално — извиква се от billing слоя след
  /// потвърдена покупка (или от dev unlock в debug).
  Future<void> activate() async {
    await SecureStore.write(_key, '1');
    _active = true;
    notifyListeners();
  }

  Future<void> deactivate() async {
    await SecureStore.delete(_key);
    _active = false;
    notifyListeners();
  }
}

final premium = Premium();
