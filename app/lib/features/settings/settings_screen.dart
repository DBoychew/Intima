import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
          ListTile(
            title: const Text('Час'),
            trailing: Text('21:00',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: AppColors.accentSoft)),
            onTap: () {},
          ),
          _section('ДАННИ'),
          ListTile(
            title: const Text('Експортирай данните'),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: () {},
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
                      onPressed: () => Navigator.pop(ctx),
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
