import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

import '../../core/cycle_settings.dart';
import '../../core/dates.dart';
import '../../core/locale_controller.dart';
import '../../core/notifications.dart';
import '../../core/premium.dart';
import '../../core/profile_controller.dart';
import '../../core/theme_controller.dart';
import '../../partner/supabase_backend.dart' show signInWithProvider;
import '../../data/db_manager.dart';
import '../../data/diary_pdf.dart';
import '../../data/pose_repository.dart';
import '../../data/diary_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../security/app_lock.dart';
import '../../security/pin_widgets.dart';
import '../../security/secure_flag.dart';
import '../../theme/app_theme.dart';
import '../../theme/palettes.dart';
import '../poses/poses_screen.dart';
import '../premium/paywall_screen.dart';

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
                      .copyWith(color: context.colors.accentSoft),
                ),
              ),
              Slider(
                value: current.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                activeColor: context.colors.primarySoft,
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
        backgroundColor: context.colors.surfaceHigh,
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

  /// Premium gate: без активен Premium отваря paywall-а; продължава само
  /// ако след него Premium вече е активен (debug unlock / бъдещ billing).
  Future<bool> _requirePremium() async {
    if (premium.active) return true;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
    return premium.active;
  }

  Future<void> _configureStealth() async {
    if (!_pin) {
      _toast(_l10n.stealthNeedPin);
      return;
    }
    if (!await _requirePremium() || !mounted) return;

    if (appLock.decoyEnabled) {
      // Вече е активен → промяна или изключване.
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ctx.colors.surfaceHigh,
          title: Text(_l10n.stealthPin),
          content: Text(_l10n.stealthSubtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'off'),
              child: Text(_l10n.stealthTurnOff,
                  style: TextStyle(color: ctx.colors.error)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'change'),
              child: Text(_l10n.stealthChange),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (action == 'off') {
        await appLock.disableDecoyPin();
        if (mounted) {
          setState(() {});
          _toast(_l10n.stealthDisabled);
        }
        return;
      }
      if (action != 'change') return;
    }

    final pin = await showPinCreateSheet(context);
    if (pin == null || !mounted) return;
    // Фалшивият PIN не бива да съвпада с истинския.
    if (await appLock.checkPin(pin)) {
      if (mounted) _toast(_l10n.stealthSameAsMain);
      return;
    }
    await appLock.setDecoyPin(pin);
    if (mounted) {
      setState(() {});
      _toast(_l10n.stealthEnabled);
    }
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => _l10n.themeLight,
        ThemeMode.system => _l10n.themeSystem,
        _ => _l10n.themeDark,
      };

  Future<void> _pickTheme() async {
    const modes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in modes)
              ListTile(
                title: Text(_themeLabel(mode)),
                leading: Icon(switch (mode) {
                  ThemeMode.light => Icons.light_mode_outlined,
                  ThemeMode.system => Icons.brightness_auto_outlined,
                  _ => Icons.dark_mode_outlined,
                }),
                trailing: themeController.mode == mode
                    ? Icon(Icons.check, color: ctx.colors.accentSoft)
                    : mode != ThemeMode.dark && !premium.active
                        ? Icon(Icons.lock_outline,
                            size: 20, color: ctx.colors.textSecondary)
                        : null,
                onTap: () => Navigator.pop(ctx, mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || selected == themeController.mode || !mounted) {
      return;
    }
    // Светлата/системната тема са Premium.
    if (selected != ThemeMode.dark && !await _requirePremium()) return;
    await themeController.set(selected);
    if (mounted) setState(() {});
  }

  /// Имената на езиците са ендоними — не се превеждат.
  String _languageLabel(Locale? locale) => switch (locale?.languageCode) {
        'bg' => 'Български',
        'en' => 'English',
        _ => _l10n.languageSystem,
      };

  Future<void> _pickLanguage() async {
    const choices = [null, Locale('bg'), Locale('en')];
    // null не може да е sentinel в showModalBottomSheet → индекс.
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < choices.length; i++)
              ListTile(
                title: Text(_languageLabel(choices[i])),
                leading: Icon(choices[i] == null
                    ? Icons.brightness_auto_outlined
                    : Icons.language),
                trailing: localeController.locale == choices[i]
                    ? Icon(Icons.check, color: ctx.colors.accentSoft)
                    : null,
                onTap: () => Navigator.pop(ctx, i),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null || !mounted) return;
    await localeController.set(choices[selected]);
    if (mounted) setState(() {});
  }

  Widget _profileHeader() {
    final avatar = profileController.avatarPath;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: context.colors.surfaceHigh,
              backgroundImage:
                  avatar != null ? FileImage(File(avatar)) : null,
              child: avatar == null
                  ? Icon(Icons.person,
                      size: 36, color: context.colors.textSecondary)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileController.name ?? _l10n.profileSetName,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(_l10n.profileChangePhoto,
                    style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
          IconButton(
            onPressed: _editName,
            icon: Icon(Icons.edit_outlined, color: context.colors.accentSoft),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
      if (picked == null) return;
      await profileController.setAvatar(picked.path);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) _toast(_l10n.galleryUnavailable);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: profileController.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceHigh,
        title: Text(_l10n.profileName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: _l10n.profileNameHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(_l10n.save,
                style: TextStyle(color: ctx.colors.accentSoft)),
          ),
        ],
      ),
    );
    if (name == null || !mounted) return;
    await profileController.setName(name);
    if (mounted) setState(() {});
  }

  /// Вход през доставчик. Изисква настройка в Supabase (виж
  /// ZA_DIMITAR.md). Instagram/TikTok не се поддържат.
  Future<void> _signIn(OAuthProvider provider) async {
    try {
      await signInWithProvider(provider);
    } catch (_) {
      if (mounted) _toast(_l10n.partnerError);
    }
  }

  Widget _accountSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(_l10n.accountSignedOut,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _signIn(OAuthProvider.facebook),
            icon: const Icon(Icons.facebook),
            label: Text(_l10n.signInFacebook),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _signIn(OAuthProvider.google),
            icon: const Icon(Icons.login),
            label: Text(_l10n.signInGoogle),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(_l10n.accountProvidersNote,
                style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      );

  String _paletteLabel(AppPalette p) => switch (p) {
        AppPalette.roseGold => _l10n.paletteRoseGold,
        AppPalette.midnightBlue => _l10n.paletteMidnightBlue,
        AppPalette.ocean => _l10n.paletteOcean,
        _ => _l10n.paletteIntima,
      };

  Future<void> _pickPalette() async {
    final selected = await showModalBottomSheet<AppPalette>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in AppPalette.values)
              ListTile(
                title: Text(_paletteLabel(p)),
                leading: _PaletteSwatch(palette: p),
                trailing: themeController.palette == p
                    ? Icon(Icons.check, color: ctx.colors.accentSoft)
                    : p.isPremium && !premium.active
                        ? Icon(Icons.lock_outline,
                            size: 20, color: ctx.colors.textSecondary)
                        : null,
                onTap: () => Navigator.pop(ctx, p),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (selected == null ||
        selected == themeController.palette ||
        !mounted) {
      return;
    }
    if (selected.isPremium && !await _requirePremium()) return;
    await themeController.setPalette(selected);
    if (mounted) {
      setState(() {});
      _toast(_l10n.paletteApplied);
    }
  }

  Future<void> _exportPdf() async {
    if (!await _requirePremium() || !mounted) return;
    final entries = await diaryRepository.all();
    if (!mounted) return;
    if (entries.isEmpty) {
      _toast(_l10n.pdfEmpty);
      return;
    }
    _toast(_l10n.pdfExporting);
    final title = _l10n.pdfDocTitle;
    final locale = _locale;
    try {
      final bytes = await exportDiaryPdf(
        entries,
        title: title,
        formatDate: (d) => dayMonthYear(d, locale),
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}intima-diary.pdf');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: _l10n.pdfSubject),
      );
    } catch (e) {
      if (mounted) _toast(_l10n.pdfFailed('$e'));
    }
  }

  Future<void> _deleteEverything() async {
    await dbManager.wipeEverything();
    await appLock.reload();
    await premium.deactivate();
    await profileController.reset();
    await poseRepository.reset();
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
        .copyWith(color: context.colors.accentSoft);
    return Scaffold(
      appBar: AppBar(title: Text(_l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _profileHeader(),
          // Библиотека с пози — реална функция, скрита в stealth копието.
          if (!appLock.decoyActive)
            Card(
              child: ListTile(
                leading: const Text('💞', style: TextStyle(fontSize: 22)),
                title: Text(_l10n.posesTitle),
                subtitle: Text(_l10n.posesSubtitle,
                    style: Theme.of(context).textTheme.labelMedium),
                trailing: Icon(Icons.chevron_right,
                    color: context.colors.textSecondary),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PosesScreen()),
                ),
              ),
            ),
          _section(_l10n.sectionAccount),
          _accountSection(),
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
          // В stealth копието не издаваме, че stealth съществува.
          if (!appLock.decoyActive)
            ListTile(
              title: Text(_l10n.stealthPin),
              subtitle: Text(_l10n.stealthSubtitle,
                  style: Theme.of(context).textTheme.labelMedium),
              trailing: premium.active
                  ? Text(
                      appLock.decoyEnabled
                          ? _l10n.statusOn
                          : _l10n.statusOff,
                      style: accent)
                  : Icon(Icons.lock_outline,
                      size: 20, color: context.colors.textSecondary),
              onTap: _configureStealth,
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
          _section(_l10n.sectionGeneral),
          ListTile(
            title: Text(_l10n.languageTitle),
            trailing: Text(_languageLabel(localeController.locale),
                style: accent),
            onTap: _pickLanguage,
          ),
          _section(_l10n.sectionPremium),
          ListTile(
            leading: const Text('💜', style: TextStyle(fontSize: 22)),
            title: Text(_l10n.premiumTitle),
            subtitle: Text(
                premium.active
                    ? _l10n.premiumActive
                    : _l10n.premiumSettingsSubtitle,
                style: Theme.of(context).textTheme.labelMedium),
            trailing: Icon(Icons.chevron_right,
                color: context.colors.textSecondary),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
          ListTile(
            title: Text(_l10n.pdfExportTitle),
            trailing: premium.active
                ? Icon(Icons.chevron_right,
                    color: context.colors.textSecondary)
                : Icon(Icons.lock_outline,
                    color: context.colors.textSecondary, size: 20),
            onTap: _exportPdf,
          ),
          ListTile(
            title: Text(_l10n.themeTitle),
            trailing: Text(_themeLabel(themeController.mode), style: accent),
            onTap: _pickTheme,
          ),
          ListTile(
            title: Text(_l10n.paletteTitle),
            trailing:
                Text(_paletteLabel(themeController.palette), style: accent),
            onTap: _pickPalette,
          ),
          // Експорт/изтриване пипат РЕАЛНИТЕ данни — скрити в stealth.
          if (!appLock.decoyActive) ...[
          _section(_l10n.sectionData),
          ListTile(
            title: Text(_l10n.exportData),
            trailing: Icon(Icons.chevron_right,
                color: context.colors.textSecondary),
            onTap: _export,
          ),
          ListTile(
            title: Text(_l10n.deleteAll,
                style: TextStyle(color: context.colors.error)),
            trailing:
                Icon(Icons.chevron_right, color: context.colors.error),
            onTap: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: context.colors.surfaceHigh,
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
                          style: TextStyle(color: context.colors.error))),
                ],
              ),
            ),
          ),
          ],
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
                .copyWith(color: context.colors.accent, letterSpacing: 1.2)),
      );
}

/// Мини превю на палитра — четирите ѝ ключови цвята в текущия режим.
class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? palette.dark
        : palette.light;
    return SizedBox(
      width: 68,
      child: Row(
        children: [
          for (final color in [c.primary, c.accent, c.period, c.fertile])
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
