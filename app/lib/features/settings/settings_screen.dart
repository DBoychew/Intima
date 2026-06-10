import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/bg_dates.dart';
import '../../core/cycle_settings.dart';
import '../../data/db_manager.dart';
import '../../security/app_lock.dart';
import '../../security/pin_widgets.dart';
import '../../security/secure_flag.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pin = false;
  bool _biometric = false;
  bool _hideRecents = true;
  bool _reminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _pin = appLock.pinEnabled;
    _biometric = appLock.biometricEnabled;
    SecureFlag.enabled().then((v) {
      if (mounted) setState(() => _hideRecents = v);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _togglePin(bool on) async {
    if (on) {
      final pin = await showPinCreateSheet(context);
      if (pin == null) return;
      await appLock.setPin(pin);
      if (!mounted) return;
      setState(() => _pin = true);
      _toast('PIN заключването е активно 🔒');
    } else {
      final ok = await showPinVerifySheet(
        context,
        title: 'Потвърди с PIN, за да изключиш',
      );
      if (!ok) return;
      await appLock.disablePin();
      await appLock.setBiometric(false);
      if (!mounted) return;
      setState(() {
        _pin = false;
        _biometric = false;
      });
      _toast('PIN заключването е изключено');
    }
  }

  Future<void> _toggleBiometric(bool on) async {
    if (on) {
      if (!_pin) {
        _toast('Първо активирай PIN — биометрията е допълнение към него');
        return;
      }
      if (!await appLock.canUseBiometrics()) {
        if (mounted) {
          _toast('Биометрията не е налична на това устройство');
        }
        return;
      }
    }
    await appLock.setBiometric(on);
    if (mounted) setState(() => _biometric = on);
  }

  Future<void> _toggleHideRecents(bool on) async {
    await SecureFlag.set(on);
    if (mounted) setState(() => _hideRecents = on);
  }

  String get _timeLabel =>
      '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  /// Голям и ясен избор на брой дни — слайдер с числото отгоре.
  Future<void> _pickLength({
    required String title,
    required String hint,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onSave,
  }) async {
    var current = value;
    final result = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
              ),
              const SizedBox(height: 8),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '$current дни',
                  style: Theme.of(ctx)
                      .textTheme
                      .displaySmall!
                      .copyWith(color: AppColors.accentSoft),
                ),
              ),
              Slider(
                value: current.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                activeColor: AppColors.primarySoft,
                onChanged: (v) => setSheetState(() => current = v.round()),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, current),
                child: const Text('Запази'),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => onSave(result));
      final next = cycleSettings.nextPeriodStart;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            next == null
                ? 'Записано ✨'
                : 'Записано ✨ Следваща менструация — около ${bgDate(next)}',
          ),
        ),
      );
    }
  }

  void _export() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Експорт на данните'),
        content: const Text(
            'Всички записи ще бъдат експортирани като криптиран файл (AES-256). '
            'Без ключа от това устройство той не може да бъде прочетен.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final file = await dbManager.exportCopy();
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    subject: 'Intima — криптиран архив',
                  ),
                );
              } catch (e) {
                if (mounted) _toast('Експортът не успя: $e');
              }
            },
            child: const Text('Експортирай'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEverything() async {
    await dbManager.wipeEverything();
    await appLock.reload();
    cycleSettings.resetToDefaults();
    if (!mounted) return;
    setState(() {
      _pin = false;
      _biometric = false;
    });
    _toast('Всички данни са изтрити завинаги 🗑️');
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section('ЦИКЪЛ'),
          ListTile(
            title: const Text('Дължина на цикъла'),
            subtitle: Text('По нея предвиждаме следващата менструация',
                style: Theme.of(context).textTheme.labelMedium),
            trailing: Text('${cycleSettings.cycleLength} дни',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
            onTap: () => _pickLength(
              title: 'Дължина на цикъла',
              hint:
                  'От първия ден на една менструация до първия ден на следващата.',
              value: cycleSettings.cycleLength,
              min: 21,
              max: 40,
              onSave: (v) => cycleSettings.cycleLength = v,
            ),
          ),
          ListTile(
            title: const Text('Дължина на менструацията'),
            trailing: Text('${cycleSettings.periodLength} дни',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
            onTap: () => _pickLength(
              title: 'Дължина на менструацията',
              hint: 'Колко дни обикновено продължава менструацията ти.',
              value: cycleSettings.periodLength,
              min: 2,
              max: 10,
              onSave: (v) => cycleSettings.periodLength = v,
            ),
          ),
          ListTile(
            title: const Text('Очаквана следваща менструация'),
            subtitle: cycleSettings.nextPeriodStart == null
                ? Text('Отбележи менструация в календара',
                    style: Theme.of(context).textTheme.labelMedium)
                : null,
            trailing: Text(
                cycleSettings.nextPeriodStart == null
                    ? '—'
                    : bgDate(cycleSettings.nextPeriodStart!),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
          ),
          _section('СИГУРНОСТ'),
          SwitchListTile(
            title: const Text('PIN заключване'),
            subtitle: Text('Изисква PIN при всяко отваряне',
                style: Theme.of(context).textTheme.labelMedium),
            value: _pin,
            onChanged: _togglePin,
          ),
          SwitchListTile(
            title: const Text('Биометрия'),
            subtitle: Text('Пръстов отпечатък или лице вместо PIN',
                style: Theme.of(context).textTheme.labelMedium),
            value: _biometric,
            onChanged: _toggleBiometric,
          ),
          SwitchListTile(
            title: const Text('Скрий в скорошни приложения'),
            subtitle: Text('Блокира и скрийншотите',
                style: Theme.of(context).textTheme.labelMedium),
            value: _hideRecents,
            onChanged: _toggleHideRecents,
          ),
          _section('НАПОМНЯНИЯ'),
          SwitchListTile(
            title: const Text('Вечерно напомняне'),
            value: _reminder,
            onChanged: (v) => setState(() => _reminder = v),
          ),
          SwitchListTile(
            title: const Text('Преди менструация'),
            subtitle: Text('Дискретно, 2 дни по-рано',
                style: Theme.of(context).textTheme.labelMedium),
            value: cycleSettings.notifyPeriod,
            onChanged: (v) => setState(() => cycleSettings.notifyPeriod = v),
          ),
          SwitchListTile(
            title: const Text('В деня на овулация'),
            value: cycleSettings.notifyOvulation,
            onChanged: (v) =>
                setState(() => cycleSettings.notifyOvulation = v),
          ),
          ListTile(
            title: const Text('Час'),
            trailing: Text(_timeLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
            onTap: _pickTime,
          ),
          _section('ДАННИ'),
          ListTile(
            title: const Text('Експортирай данните'),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: _export,
          ),
          ListTile(
            title: const Text('Изтрий всичко',
                style: TextStyle(color: AppColors.error)),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.error),
            onTap: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surfaceHigh,
                title: const Text('Изтриване на всичко?'),
                content: const Text(
                    'Всички записи ще бъдат изтрити завинаги. Това не може да се отмени.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Отказ')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteEverything();
                      },
                      child: const Text('Изтрий',
                          style: TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ),
          _section('ЗА ПРИЛОЖЕНИЕТО'),
          const ListTile(title: Text('Версия'), trailing: Text('0.1.0 · прототип')),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 4, left: 8),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: AppColors.accent, letterSpacing: 1.2)),
      );
}
