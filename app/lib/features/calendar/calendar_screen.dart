import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import 'quick_log_sheet.dart';

/// Прототип с примерни данни — реалните идват от БД във Фаза 3.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _monthNames = [
    'януари',
    'февруари',
    'март',
    'април',
    'май',
    'юни',
    'юли',
    'август',
    'септември',
    'октомври',
    'ноември',
    'декември',
  ];
  static const _year = 2026;
  static const _todayMonth = 6;
  static const _todayDay = 30;
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];

  int _month = _todayMonth;
  // Ключ "месец-ден", за да пазим маркери за всички месеци.
  final _periodDays = <String>{'6-3', '6-4', '6-5', '6-6', '6-7'};
  final _intimacyDays = <String>{'6-17', '6-28'};
  final _fertileDays = <String>{'6-19', '6-20', '6-21'};
  int _todayMood = 2;

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday => DateTime(_year, _month, 1).weekday;
  String get _monthTitle =>
      '${_monthNames[_month - 1][0].toUpperCase()}${_monthNames[_month - 1].substring(1)} $_year';

  String _key(int day) => '$_month-$day';

  Future<void> _openLog(int day) async {
    final isToday = _month == _todayMonth && day == _todayDay;
    final result = await showQuickLogSheet(
      context,
      dateLabel: isToday ? null : '$day ${_monthNames[_month - 1]}',
      initialPeriod: _periodDays.contains(_key(day)),
      initialIntimacy: _intimacyDays.contains(_key(day)),
    );
    if (result == null || !mounted) return;
    setState(() {
      result.period
          ? _periodDays.add(_key(day))
          : _periodDays.remove(_key(day));
      result.intimacy
          ? _intimacyDays.add(_key(day))
          : _intimacyDays.remove(_key(day));
      if (_month == _todayMonth && day == _todayDay && result.mood != null) {
        _todayMood = result.mood!;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Записано ✨')),
    );
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    setState(() => _month = (_month + delta).clamp(1, 12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_monthTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _month > 1 ? () => _changeMonth(-1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _month < 12 ? () => _changeMonth(1) : null,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_month != _todayMonth) setState(() => _month = _todayMonth);
          _openLog(_todayDay);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _weekdayHeader(context),
          const SizedBox(height: 8),
          _monthGrid(context),
          const SizedBox(height: 16),
          _legend(context),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Днес · 30 юни',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Настроение: ${_moods[_todayMood]}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      Text(
                        'Енергия ',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      const Icon(Icons.bolt, color: AppColors.accent, size: 18),
                      const Icon(
                        Icons.bolt,
                        color: AppColors.surfaceHigh,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Следващ цикъл — около 24 юли',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _weekdayHeader(BuildContext context) {
    const days = ['П', 'В', 'С', 'Ч', 'П', 'С', 'Н'];
    return Row(
      children: [
        for (final d in days)
          Expanded(
            child: Center(
              child: Text(d, style: Theme.of(context).textTheme.labelMedium),
            ),
          ),
      ],
    );
  }

  Widget _monthGrid(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 1; i < _firstWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= _daysInMonth; day++) {
      cells.add(
        _DayCell(
          day: day,
          isToday: _month == _todayMonth && day == _todayDay,
          isPeriod: _periodDays.contains(_key(day)),
          isIntimacy: _intimacyDays.contains(_key(day)),
          isFertile: _fertileDays.contains(_key(day)),
          onTap: () {
            HapticFeedback.selectionClick();
            _openLog(day);
          },
        ),
      );
    }
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _legend(BuildContext context) {
    Widget item(Color color, String label, {bool heart = false}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        heart
            ? const Icon(Icons.favorite, color: AppColors.intimacy, size: 12)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(AppColors.period, 'Менструация'),
        item(AppColors.intimacy, 'Интимност', heart: true),
        item(AppColors.fertile, 'Фертилни дни'),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isPeriod,
    required this.isIntimacy,
    required this.isFertile,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isPeriod;
  final bool isIntimacy;
  final bool isFertile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFertile ? AppColors.fertile.withValues(alpha: 0.18) : null,
            border: isToday
                ? Border.all(color: AppColors.primarySoft, width: 2)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('$day', style: const TextStyle(fontSize: 14)),
              if (isPeriod)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.period,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isIntimacy)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.favorite,
                    color: AppColors.intimacy,
                    size: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
