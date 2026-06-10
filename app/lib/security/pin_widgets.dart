import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import 'app_lock.dart';

const pinLength = 4;

/// Точките, показващи колко цифри са въведени.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? AppColors.accentSoft : null,
            border: Border.all(
              color: isFilled ? AppColors.accentSoft : AppColors.textSecondary,
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// Голяма цифрова клавиатура — основният начин за въвеждане на PIN.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.extraKey,
  });

  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  /// Слот долу вляво — напр. бутон за биометрия на lock екрана.
  final Widget? extraKey;

  Widget _key(BuildContext context, Widget child, VoidCallback? onTap) {
    return SizedBox(
      width: 76,
      height: 76,
      child: onTap == null
          ? child
          : InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              customBorder: const CircleBorder(),
              child: Center(child: child),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget digit(int d) => _key(
          context,
          Text('$d', style: const TextStyle(fontSize: 28)),
          () => onDigit(d),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [for (final d in row) digit(d)],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _key(context, extraKey ?? const SizedBox(), null),
            digit(0),
            _key(
              context,
              const Icon(Icons.backspace_outlined,
                  color: AppColors.textSecondary),
              onBackspace,
            ),
          ],
        ),
      ],
    );
  }
}

/// Създаване на PIN: въвеждане + потвърждение. Връща PIN-а или null.
Future<String?> showPinCreateSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _PinCreateSheet(),
  );
}

class _PinCreateSheet extends StatefulWidget {
  const _PinCreateSheet();

  @override
  State<_PinCreateSheet> createState() => _PinCreateSheetState();
}

class _PinCreateSheetState extends State<_PinCreateSheet> {
  String _first = '';
  String _entered = '';
  String? _error;

  bool get _confirming => _first.isNotEmpty;

  void _onDigit(int d) {
    if (_entered.length >= pinLength) return;
    setState(() {
      _entered += '$d';
      _error = null;
    });
    if (_entered.length < pinLength) return;
    if (!_confirming) {
      setState(() {
        _first = _entered;
        _entered = '';
      });
    } else if (_entered == _first) {
      Navigator.pop(context, _entered);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _first = '';
        _entered = '';
        _error = 'PIN кодовете не съвпадат — опитай отново';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _confirming ? 'Потвърди PIN кода' : 'Избери PIN код',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Ще го въвеждаш при всяко отваряне на Intima.',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color:
                      _error != null ? AppColors.error : AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          PinDots(filled: _entered.length),
          const SizedBox(height: 20),
          PinPad(
            onDigit: _onDigit,
            onBackspace: () => setState(() {
              if (_entered.isNotEmpty) {
                _entered = _entered.substring(0, _entered.length - 1);
              }
            }),
          ),
        ],
      ),
    );
  }
}

/// Проверка на текущия PIN (напр. преди изключване на заключването).
/// Връща true само при верен PIN.
Future<bool> showPinVerifySheet(BuildContext context, {String? title}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _PinVerifySheet(title: title),
  );
  return ok ?? false;
}

class _PinVerifySheet extends StatefulWidget {
  const _PinVerifySheet({this.title});

  final String? title;

  @override
  State<_PinVerifySheet> createState() => _PinVerifySheetState();
}

class _PinVerifySheetState extends State<_PinVerifySheet> {
  String _entered = '';
  String? _error;

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
      Navigator.pop(context, true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _entered = '';
        _error = 'Грешен PIN — опитай отново';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title ?? 'Въведи текущия PIN',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 20),
          PinDots(filled: _entered.length),
          const SizedBox(height: 20),
          PinPad(
            onDigit: _onDigit,
            onBackspace: () => setState(() {
              if (_entered.isNotEmpty) {
                _entered = _entered.substring(0, _entered.length - 1);
              }
            }),
          ),
        ],
      ),
    );
  }
}
