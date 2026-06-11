import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'security/app_lock.dart';
import 'theme/app_theme.dart';

/// Стъпка от стартирането — име + действие, за да виждаме докъде стига.
typedef BootStep = ({String label, Future<void> Function() run});

/// Подменя се в тестове с празен списък.
List<BootStep> bootSteps = [];

/// Брандиран стартов екран: пуска [bootSteps] една по една с timeout,
/// показва коя стъпка тече и дава „Опитай отново" при проблем.
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  String _status = 'Стартираме…';
  String? _error;

  @override
  void initState() {
    super.initState();
    // След първия кадър — навигацията не бива да се случва по време на build.
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() => _error = null);
    for (final step in bootSteps) {
      if (!mounted) return;
      setState(() => _status = step.label);
      try {
        await step.run().timeout(const Duration(seconds: 15));
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = '${step.label} — неуспешно ($e)');
        return;
      }
    }
    if (!mounted) return;
    context.go(appLock.locked ? '/lock' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💜', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text('Intima', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 32),
              if (_error == null) ...[
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.accentSoft,
                  ),
                ),
                const SizedBox(height: 16),
                Text(_status, style: Theme.of(context).textTheme.labelMedium),
              ] else ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _run,
                  child: const Text('Опитай отново'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
