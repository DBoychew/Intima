import 'package:flutter/material.dart';

import '../../core/bg_dates.dart';
import '../../core/cycle_settings.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pin = true;
  bool _biometric = true;
  bool _hideRecents = true;
  bool _reminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Записано ✨ Следваща менструация — около '
            '${bgDate(cycleSettings.nextPeriodStart)}',
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
            'Всички записи ще бъдат експортирани в криптиран файл, който можеш да съхраниш или прехвърлиш.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отказ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Експортът е готов 📦 (реалният файл идва във Фаза 2)')),
              );
            },
            child: const Text('Експортирай'),
          ),
        ],
      ),
    );
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
            trailing: Text(bgDate(cycleSettings.nextPeriodStart),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
          ),
          _section('СИГУРНОСТ'),
          SwitchListTile(
            title: const Text('PIN заключване'),
            value: _pin,
            onChanged: (v) => setState(() => _pin = v),
          ),
          SwitchListTile(
            title: const Text('Биометрия'),
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
          ),
          SwitchListTile(
            title: const Text('Скрий в скорошни приложения'),
            value: _hideRecents,
            onChanged: (v) => setState(() => _hideRecents = v),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Всички данни са изтрити 🗑️ (прототип)')),
                        );
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
