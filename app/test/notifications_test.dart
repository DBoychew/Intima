import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/core/notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  group('nextInstanceOf', () {
    test('днес, ако часът предстои', () {
      final now = tz.TZDateTime(tz.local, 2026, 6, 11, 18, 0);
      final at = nextInstanceOf(const TimeOfDay(hour: 21, minute: 0), now);
      expect(at.day, 11);
      expect(at.hour, 21);
    });

    test('утре, ако часът е минал', () {
      final now = tz.TZDateTime(tz.local, 2026, 6, 11, 22, 30);
      final at = nextInstanceOf(const TimeOfDay(hour: 21, minute: 0), now);
      expect(at.day, 12);
      expect(at.hour, 21);
    });
  });

  group('periodReminderAt', () {
    test('2 дни преди прогнозата, в 9:00', () {
      final at = periodReminderAt(
          DateTime(2026, 7, 1), DateTime(2026, 6, 11));
      expect(at, DateTime(2026, 6, 29, 9));
    });

    test('null при минала дата или липсваща прогноза', () {
      expect(
          periodReminderAt(DateTime(2026, 6, 10), DateTime(2026, 6, 11)),
          isNull);
      expect(periodReminderAt(null, DateTime(2026, 6, 11)), isNull);
    });
  });

  group('ovulationReminderAt', () {
    test('в деня на овулацията, в 9:00', () {
      final at = ovulationReminderAt(
          DateTime(2026, 6, 17), DateTime(2026, 6, 11));
      expect(at, DateTime(2026, 6, 17, 9));
    });

    test('null при минал ден', () {
      expect(
          ovulationReminderAt(DateTime(2026, 6, 10), DateTime(2026, 6, 11)),
          isNull);
    });
  });
}
