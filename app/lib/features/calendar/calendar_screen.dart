import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/cycle_settings.dart';
import '../../core/dates.dart';
import '../../data/calendar_repository.dart';
import '../../data/db_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'quick_log_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, this.todayOverride});

  /// Фиксира „днес" — само за тестове.
  final DateTime? todayOverride;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];

  late final DateTime _today = widget.todayOverride ?? DateTime.now();
  late int _year = _today.year;
  late int _month = _today.month;
  MonthData _data = MonthData.empty;

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;
  int get _firstWeekday => DateTime(_year, _month, 1).weekday;
  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  String get _locale => Localizations.localeOf(context).toString();
  String get _monthTitle => monthTitle(DateTime(_year, _month), _locale);

  bool get _viewingTodayMonth =>
      _year == _today.year && _month == _today.month;

  @override
  void initState() {
    super.initState();
    // Прогнозата се преизчислява щом потребителката промени цикъла си;
    // презареждаме и след GDPR изтриване.
    cycleSettings.addListener(_onCycleChanged);
    dbManager.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    cycleSettings.removeListener(_onCycleChanged);
    dbManager.removeListener(_load);
    super.dispose();
  }

  void _onCycleChanged() => setState(() {});

  Future<void> _load() async {
    await calendarRepository.refreshLastPeriodStart();
    final data = await calendarRepository.month(_year, _month);
    if (mounted) setState(() => _data = data);
  }

  Future<void> _openLog(int day) async {
    final date = DateTime(_year, _month, day);
    final isToday = _viewingTodayMonth && day == _today.day;
    final log = _data.logs[day];
    final existing = _data.momentsByDay[day] ?? const [];

    final result = await showQuickLogSheet(
      context,
      dateLabel: isToday ? null : dayMonthYear(date, _locale),
      initialMood: log?.mood,
      initialPeriod: log?.isPeriod ?? false,
      initialSymptoms: decodeStringList(log?.symptoms),
      initialLibido: log?.libido ?? 0.5,
      initialEnergy: log?.energy ?? 0.5,
      initialMoments: [
        for (final m in existing)
          MomentDraft(
            arousal: m.arousal,
            orgasms: m.orgasms,
            positions: decodeStringList(m.positions),
            note: m.note,
          ),
      ],
    );
    if (result == null || !mounted) return;

    final outcome = await calendarRepository.saveQuickLog(
      date: date,
      mood: result.mood,
      period: result.period,
      libido: result.libido,
      energy: result.energy,
      symptoms: result.symptoms,
      moments: result.moments,
    );
    await _load();
    if (!mounted) return;
    final message = outcome.autoFilledDays > 0
        ? _l10n.savedAutoFilled(outcome.autoFilledDays)
        : outcome.clearedDays > 0
            ? _l10n.savedCleared(outcome.clearedDays)
            : _l10n.saved;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    final target = DateTime(_year, _month + delta);
    setState(() {
      _year = target.year;
      _month = target.month;
      _data = MonthData.empty;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_monthTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: _l10n.prevMonth,
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: _l10n.nextMonth,
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_viewingTodayMonth) {
            setState(() {
              _year = _today.year;
              _month = _today.month;
            });
            _load();
          }
          _openLog(_today.day);
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
          _todayCard(context),
          const SizedBox(height: 12),
          _predictionCard(context),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _todayCard(BuildContext context) {
    final todayLog = _viewingTodayMonth ? _data.logs[_today.day] : null;
    final energy = todayLog?.energy;
    final filledBolts = energy == null ? 0 : (energy * 3).round().clamp(0, 3);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.todayCard(dayMonth(_today, _locale)),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  todayLog?.mood == null
                      ? _l10n.noLogToday
                      : _l10n.moodLabel(_moods[todayLog!.mood!]),
                  style: const TextStyle(fontSize: 15),
                ),
                const Spacer(),
                Text(
                  _l10n.energyLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                for (var i = 0; i < 3; i++)
                  Icon(
                    Icons.bolt,
                    color: i < filledBolts
                        ? context.colors.accent
                        : context.colors.surfaceHigh,
                    size: 18,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionCard(BuildContext context) {
    final next = cycleSettings.nextPeriodStart;
    if (next == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _l10n.predictionHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final daysLeft = next.difference(DateTime(_today.year, _today.month, _today.day)).inDays;
    final countdown =
        daysLeft <= 0 ? _l10n.anyMomentNow : _l10n.inDays(daysLeft);
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
                    _l10n.nextCycleAround(
                        dayMonth(next, _locale), countdown),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _l10n.cycleOfDays(cycleSettings.cycleLength),
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
    final days = _l10n.weekdaysNarrow.split(',');
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
      final isPeriod = _data.isPeriod(day);
      cells.add(
        _DayCell(
          day: day,
          isToday: _viewingTodayMonth && day == _today.day,
          isPeriod: isPeriod,
          isIntimacy: _data.hasIntimacy(day),
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
            ? Icon(Icons.favorite, color: context.colors.intimacy, size: 12)
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
        item(context.colors.period, _l10n.legendPeriod),
        item(context.colors.period, _l10n.legendPredicted, hollow: true),
        item(context.colors.intimacy, _l10n.legendIntimacy, heart: true),
        item(context.colors.fertile, _l10n.legendFertile),
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
            color: isFertile ? context.colors.fertile.withValues(alpha: 0.18) : null,
            border: isToday
                ? Border.all(color: context.colors.primarySoft, width: 2)
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
                    decoration: BoxDecoration(
                      color: context.colors.period,
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
                      border: Border.all(color: context.colors.period, width: 1.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isIntimacy)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(
                    Icons.favorite,
                    color: context.colors.intimacy,
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