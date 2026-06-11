import 'package:intl/intl.dart';

/// Локализирано форматиране на дати (bg/en през intl).
/// Подавай locale-а от контекста: `Localizations.localeOf(context)`.

/// Напр. „11 юни" / "June 11".
String dayMonth(DateTime d, String locale) =>
    DateFormat.MMMMd(locale).format(d);

/// Напр. „11 юни 2026" / "June 11, 2026".
String dayMonthYear(DateTime d, String locale) =>
    DateFormat.yMMMMd(locale).format(d);

/// Заглавие на месец: „Юни 2026" / "June 2026".
String monthTitle(DateTime d, String locale) {
  final s = DateFormat('LLLL y', locale).format(d);
  return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
