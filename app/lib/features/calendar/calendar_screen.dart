import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/bg_dates.dart';
import '../../core/cycle_settings.dart';
import '../../theme/app_theme.dart';
import 'quick_log_sheet.dart';

/// Прототип с примерни данни — реалните идват от БД във Фаза 3.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _todayYear = 2026;
  static const _todayMonth = 6;
  static const _todayDay = 30;
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];

  int _year = _todayYear;
  int _month = _todayMonth;
  // Ключ "година-месец-ден", за да не смесваме записи от различни години.
  final _periodDays = <String>{
    '2026-6-3',
    '2026-6-4',
    '2026-6-5',
    '2026-6-6',
    '2026-6-7',
  };
  final _intimacyDays = <String>{'2026-6-17', '2026-6-28'};
  int _todayMood = 2;

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday => DateTime(_year, _month, 1).weekday;
  String get _monthTitle =>
      '${bgMonths[_month - 1][0].toUpperCase()}${bgMonths[_month - 1].substring(1)} $_year';

  String _key(int day) => '$_year-$_month-$day';

  @override
  void initState() {
    super.initState();
    // Прогнозата се преизчислява щом потребителката промени цикъла си.
    cycleSettings.addListener(_onCycleChanged);
  }

  @override
  void dispose() {
    cycleSettings.removeListener(_onCycleChanged);
    super.dispose();
  }

  void _onCycleChanged() => setState(() {});

  Future<void> _openLog(int day) async {
    final isToday =
        _year == _todayYear && _month == _todayMonth && day == _todayDay;
    final result = await showQuickLogSheet(
      context,
      dateLabel: isToday ? null : '$day ${bgMonths[_month - 1]} $_year',
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
      if (_year == _todayYear &&
          _month == _todayMonth &&
          day == _todayDay &&
          result.mood != null) {
        _todayMood = result.mood!;
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Записано ✨')));
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    final target = DateTime(_year, _month + delta);
    setState(() {
      _year = target.year;
      _month = target.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_monthTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Предишен месец',
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Следващ месец',
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_year != _todayYear || _month != _todayMonth) {
            setState(() {
              _year = _todayYear;
              _month = _todayMonth;
            });
          }
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
          _predictionCard(context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _predictionCard(BuildContext context) {
    final next = cycleSettings.nextPeriodStart;
    final daysLeft = next
        .difference(DateTime(_todayYear, _todayMonth, _todayDay))
        .inDays;
    final countdown = daysLeft <= 0
        ? 'очаква се всеки момент'
        : 'след $daysLeft ${daysLeft == 1 ? 'ден' : 'дни'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('🔮', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Следващ цикъл — около ${bgDate(next)} ($countdown)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'При цикъл от ${cycleSettings.cycleLength} дни · '
                    'настройва се от Настройки',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
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
      final date = DateTime(_year, _month, day);
      final isPeriod = _periodDays.contains(_key(day));
      cells.add(
        _DayCell(
          day: day,
          isToday:
              _year == _todayYear && _month == _todayMonth && day == _todayDay,
          isPeriod: isPeriod,
          isIntimacy: _intimacyDays.contains(_key(day)),
          isFertile: cycleSettings.isFertile(date),
          isPredicted: !isPeriod && cycleSettings.isPredictedPeriod(date),
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
    Widget item(
      Color color,
      String label, {
      bool heart = false,
      bool hollow = false,
    }) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        heart
            ? const Icon(Icons.favorite, color: AppColors.intimacy, size: 12)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: hollow ? null : color,
                  border: hollow ? Border.all(color: color, width: 1.5) : null,
                  shape: BoxShape.circle,
                ),
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
        item(AppColors.period, 'Очаквана', hollow: true),
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
    required this.isPredicted,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool isPeriod;
  final bool isIntimacy;
  final bool isFertile;

  /// Очакван (прогнозен) ден от менструация — показва се с празна точка.
  final bool isPredicted;
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
                )
              else if (isPredicted)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.period, width: 1.2),
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
