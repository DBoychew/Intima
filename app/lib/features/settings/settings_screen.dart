import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/cycle_settings.dart';
import '../../core/dates.dart';
import '../../core/notifications.dart';
import '../../data/db_manager.dart';
import '../../l10n/app_localizations.dart';
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
  bool _reminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  String get _locale => Localizations.localeOf(context).toString();

  String get _timeLabel =>
      '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _pin = appLock.pinEnabled;
    _biometric = appLock.biometricEnabled;
    SecureFlag.enabled().then((v) {
      if (mounted) setState(() => _hideRecents = v);
    });
    ReminderPrefs.load().then((value) {
      if (!mounted) return;
      setState(() {
        _reminder = value.$1;
        _reminderTime = value.$2;
      });
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleReminder(bool on) async {
    if (on) {
      // Системният диалог за разрешение — без да блокираме UI-я.
      unawaited(Notifications.requestPermission());
      await Notifications.scheduleEvening(_reminderTime);
    } else {
      await Notifications.cancelEvening();
    }
    await ReminderPrefs.save(on, _reminderTime);
    if (mounted) setState(() => _reminder = on);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
    await ReminderPrefs.save(_reminder, picked);
    if (_reminder) await Notifications.scheduleEvening(picked);
  }

  Future<void> _togglePin(bool on) async {
    if (on) {
      final pin = await showPinCreateSheet(context);
      if (pin == null) return;
      await appLock.setPin(pin);
      if (!mounted) return;
      setState(() => _pin = true);
      _toast(_l10n.pinEnabled);
    } else {
      final ok = await showPinVerifySheet(
        context,
        title: _l10n.pinConfirmToDisable,
      );
      if (!ok) return;
      await appLock.disablePin();
      await appLock.setBiometric(false);
      if (!mounted) return;
      setState(() {
        _pin = false;
        _biometric = false;
      });
      _toast(_l10n.pinDisabled);
    }
  }

  Future<void> _toggleBiometric(bool on) async {
    if (on) {
      if (!_pin) {
        _toast(_l10n.biometricsNeedPin);
        return;
      }
      if (!await appLock.canUseBiometrics()) {
        if (mounted) _toast(_l10n.biometricsUnavailable);
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
                child:
                    Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
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
                  _l10n.daysValue(current),
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
                child: Text(_l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() => onSave(result));
      final next = cycleSettings.nextPeriodStart;
      _toast(next == null
          ? _l10n.saved
          : _l10n.savedNextPeriod(dayMonth(next, _locale)));
    }
  }

  void _export() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text(_l10n.exportTitle),
        content: Text(_l10n.exportBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final file = await dbManager.exportCopy();
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    subject: _l10n.exportSubject,
                  ),
                );
              } catch (e) {
                if (mounted) _toast(_l10n.exportFailed('$e'));
              }
            },
            child: Text(_l10n.exportAction),
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
    _toast(_l10n.deletedAll);
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: AppColors.accentSoft);
    return Scaffold(
      appBar: AppBar(title: Text(_l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(_l10n.sectionCycle),
          ListTile(
            title: Text(_l10n.cycleLength),
            subtitle: Text(_l10n.cycleLengthSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            trailing:
                Text(_l10n.daysValue(cycleSettings.cycleLength), style: accent),
            onTap: () => _pickLength(
              title: _l10n.cycleLength,
              hint: _l10n.cycleLengthHint,
              value: cycleSettings.cycleLength,
              min: 21,
              max: 40,
              onSave: (v) => cycleSettings.cycleLength = v,
            ),
          ),
          ListTile(
            title: Text(_l10n.periodLength),
            trailing: Text(_l10n.daysValue(cycleSettings.periodLength),
                style: accent),
            onTap: () => _pickLength(
              title: _l10n.periodLength,
              hint: _l10n.periodLengthHint,
              value: cycleSettings.periodLength,
              min: 2,
              max: 10,
              onSave: (v) => cycleSettings.periodLength = v,
            ),
          ),
          ListTile(
            title: Text(_l10n.expectedNextPeriod),
            subtitle: cycleSettings.nextPeriodStart == null
                ? Text(_l10n.markPeriodInCalendar,
                    style: Theme.of(context).textTheme.labelMedium)
                : null,
            trailing: Text(
                cycleSettings.nextPeriodStart == null
                    ? '—'
                    : dayMonth(cycleSettings.nextPeriodStart!, _locale),
                style: accent),
          ),
          _section(_l10n.sectionSecurity),
          SwitchListTile(
            title: Text(_l10n.pinLock),
            subtitle: Text(_l10n.pinLockSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            value: _pin,
            onChanged: _togglePin,
          ),
          SwitchListTile(
            title: Text(_l10n.biometrics),
            subtitle: Text(_l10n.biometricsSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            value: _biometric,
            onChanged: _toggleBiometric,
          ),
          SwitchListTile(
            title: Text(_l10n.hideInRecents),
            subtitle: Text(_l10n.hideInRecentsSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            value: _hideRecents,
            onChanged: _toggleHideRecents,
          ),
          _section(_l10n.sectionReminders),
          SwitchListTile(
            title: Text(_l10n.eveningReminder),
            subtitle: Text(_l10n.eveningReminderSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            value: _reminder,
            onChanged: _toggleReminder,
          ),
          SwitchListTile(
            title: Text(_l10n.beforePeriod),
            subtitle: Text(_l10n.beforePeriodSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            value: cycleSettings.notifyPeriod,
            onChanged: (v) => setState(() => cycleSettings.notifyPeriod = v),
          ),
          SwitchListTile(
            title: Text(_l10n.onOvulationDay),
            value: cycleSettings.notifyOvulation,
            onChanged: (v) =>
                setState(() => cycleSettings.notifyOvulation = v),
          ),
          ListTile(
            title: Text(_l10n.timeLabel),
            trailing: Text(_timeLabel, style: accent),
            onTap: _pickTime,
          ),
          _section(_l10n.sectionData),
          ListTile(
            title: Text(_l10n.exportData),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onTap: _export,
          ),
          ListTile(
            title: Text(_l10n.deleteAll,
                style: const TextStyle(color: AppColors.error)),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.error),
            onTap: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surfaceHigh,
                title: Text(_l10n.deleteAllTitle),
                content: Text(_l10n.deleteAllBody),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(_l10n.cancel)),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteEverything();
                      },
                      child: Text(_l10n.delete,
                          style: const TextStyle(color: AppColors.error))),
                ],
              ),
            ),
          ),
          _section(_l10n.sectionAbout),
          ListTile(
              title: Text(_l10n.version),
              trailing: Text(_l10n.versionValue)),
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
