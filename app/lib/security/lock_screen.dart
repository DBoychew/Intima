import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'app_lock.dart';
import 'pin_widgets.dart';

/// Екранът, който пази всичко — PIN или биометрия.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _entered = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    // Биометрията се предлага веднага — PIN-ът остава резервен вариант.
    if (appLock.biometricEnabled) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => appLock.tryBiometricUnlock(),
      );
    }
  }

  Future<void> _onDigit(int d) async {
    if (_entered.length >= pinLength) return;
    setState(() {
      _entered += '$d';
      _error = null;
    });
    if (_entered.length < pinLength) return;
    final ok = await appLock.checkPin(_entered);
    if (!mounted) return;
    if (ok) {
      HapticFeedback.lightImpact();
      appLock.unlock(); // router-ът ни праща към календара
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _entered = '';
        _error = AppLocalizations.of(context)!.lockWrongPin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, color: AppColors.accent, size: 44),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.appName, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 8),
            Text(
              _error ?? AppLocalizations.of(context)!.lockEnterPin,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: _error != null
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            PinDots(filled: _entered.length),
            const Spacer(),
            PinPad(
              onDigit: _onDigit,
              onBackspace: () => setState(() {
                if (_entered.isNotEmpty) {
                  _entered = _entered.substring(0, _entered.length - 1);
                }
              }),
              extraKey: appLock.biometricEnabled
                  ? InkWell(
                      onTap: appLock.tryBiometricUnlock,
                      customBorder: const CircleBorder(),
                      child: const Center(
                        child: Icon(
                          Icons.fingerprint,
                          color: AppColors.accentSoft,
                          size: 32,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
