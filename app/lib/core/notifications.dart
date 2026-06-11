import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_bg.dart';
import '../security/secure_store.dart';
import 'cycle_settings.dart';

/// Нежни, дискретни напомняния — заглавията и текстовете никога не
/// издават съдържанието на приложението (виж PLAN.md, Фаза 5).
abstract class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _eveningId = 1;
  static const _periodId = 2;
  static const _ovulationId = 3;

  /// Насрочваме без widget контекст — взимаме езика на системата.
  static AppLocalizations get _strings {
    try {
      return lookupAppLocalizations(ui.PlatformDispatcher.instance.locale);
    } catch (_) {
      return AppLocalizationsBg();
    }
  }

  static AndroidNotificationDetails get _channel =>
      AndroidNotificationDetails(
        'intima_gentle',
        _strings.notifChannelName,
        channelDescription: _strings.notifChannelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        // Без съдържание на заключен екран.
        visibility: NotificationVisibility.secret,
      );

  static Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Оставаме на UTC — напомнянията пак работят, само часът е изместен.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Ежедневно вечерно напомняне в [time].
  static Future<void> scheduleEvening(TimeOfDay time) async {
    if (!_ready) return;
    await _plugin.zonedSchedule(
      id: _eveningId,
      title: _strings.appName,
      body: _strings.notifEvening,
      scheduledDate: nextInstanceOf(time, tz.TZDateTime.now(tz.local)),
      notificationDetails: NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelEvening() => _plugin.cancel(id: _eveningId);

  /// Синхронизира напомнянията за цикъла с текущите предикции.
  static Future<void> syncCycleReminders() async {
    if (!_ready) return;
    await _plugin.cancel(id: _periodId);
    await _plugin.cancel(id: _ovulationId);

    final now = DateTime.now();
    if (cycleSettings.notifyPeriod) {
      final at = periodReminderAt(cycleSettings.nextPeriodStart, now);
      if (at != null) {
        await _schedule(
            _periodId, _strings.appName, _strings.notifPeriod, at);
      }
    }
    if (cycleSettings.notifyOvulation) {
      final at = ovulationReminderAt(cycleSettings.ovulation, now);
      if (at != null) {
        await _schedule(
            _ovulationId, _strings.appName, _strings.notifOvulation, at);
      }
    }
  }

  static Future<void> _schedule(
      int id, String title, String body, DateTime at) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;
}

/// Следващото настъпване на [time] — днес или утре (чиста функция).
tz.TZDateTime nextInstanceOf(TimeOfDay time, tz.TZDateTime now) {
  var at = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, time.hour, time.minute);
  if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
  return at;
}

/// 2 дни преди очакваната менструация, в 9:00; null ако е в миналото
/// или няма прогноза.
DateTime? periodReminderAt(DateTime? nextPeriodStart, DateTime now) {
  if (nextPeriodStart == null) return null;
  final at = DateTime(nextPeriodStart.year, nextPeriodStart.month,
          nextPeriodStart.day, 9)
      .subtract(const Duration(days: 2));
  return at.isAfter(now) ? at : null;
}

/// В деня на овулацията, в 9:00; null ако е в миналото или няма прогноза.
DateTime? ovulationReminderAt(DateTime? ovulation, DateTime now) {
  if (ovulation == null) return null;
  final at =
      DateTime(ovulation.year, ovulation.month, ovulation.day, 9);
  return at.isAfter(now) ? at : null;
}

/// Ключове за настройките на вечерното напомняне.
abstract class ReminderPrefs {
  static const onKey = 'reminder_on';
  static const timeKey = 'reminder_time';

  static Future<(bool, TimeOfDay)> load() async {
    final on = await SecureStore.read(onKey) == '1';
    final raw = await SecureStore.read(timeKey) ?? '21:00';
    final parts = raw.split(':');
    final time = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 21,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    return (on, time);
  }

  static Future<void> save(bool on, TimeOfDay time) async {
    await SecureStore.write(onKey, on ? '1' : '0');
    await SecureStore.write(timeKey,
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
  }
}
