import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/cycle_settings.dart';
import '../../core/dates.dart';
import '../../core/fertility.dart';
import '../../core/moods.dart';
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

  String _fertLabel(FertilityLevel l) => switch (l) {
        FertilityLevel.veryHigh => _l10n.fertVeryHigh,
        FertilityLevel.high => _l10n.fertHigh,
        FertilityLevel.moderate => _l10n.fertModerate,
        FertilityLevel.low => _l10n.fertLow,
        FertilityLevel.negligible => _l10n.fertNegligible,
      };

  Color _fertColor(FertilityLevel l) => switch (l) {
        FertilityLevel.veryHigh ||
        FertilityLevel.high =>
          context.colors.fertile,
        FertilityLevel.moderate => context.colors.accent,
        _ => context.colors.textSecondary,
      };

  /// Подробен изглед на деня: фаза, шанс за забременяване и записаното.
  Future<void> _showDayDetail(int day) async {
    final date = DateTime(_year, _month, day);
    final log = _data.logs[day];
    final moments = _data.momentsByDay[day] ?? const [];
    final isPeriod = log?.isPeriod ?? false;
    final predicted = !isPeriod && cycleSettings.isPredictedPeriod(date);
    final dfo = cycleSettings.daysFromOvulation(date);
    final isOvulation = dfo == 0;
    final fertile = cycleSettings.isFertile(date);

    final (String phaseLabel, Color phaseColor) = isPeriod
        ? (_l10n.dayPhasePeriod, context.colors.period)
        : predicted
            ? (_l10n.dayPhasePredicted, context.colors.period)
            : isOvulation
                ? (_l10n.dayPhaseOvulation, context.colors.fertile)
                : fertile
                    ? (_l10n.dayPhaseFertile, context.colors.fertile)
                    : (_l10n.dayPhaseRegular, context.colors.textSecondary);

    final symptoms = decodeStringList(log?.symptoms);
    final tt = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(dayMonthYear(date, _locale),
                      style: tt.headlineSmall),
                ),
                const SizedBox(height: 16),
                // Фаза на цикъла.
                Row(children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: phaseColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(phaseLabel, style: tt.bodyMedium),
                ]),
                const SizedBox(height: 16),
                _fertilitySection(dfo, ctx),
                const SizedBox(height: 16),
                // Записаното за деня.
                if (log == null && moments.isEmpty)
                  Text(_l10n.dayNoData, style: tt.labelMedium)
                else ...[
                  if (log?.mood != null)
                    _detailRow(_l10n.detailMood, moodEmoji(log!.mood)),
                  if (log?.libido != null)
                    _detailRow(_l10n.detailLibido,
                        '${(log!.libido! * 100).round()}%'),
                  if (log?.energy != null)
                    _detailRow(_l10n.detailEnergy,
                        '${(log!.energy! * 100).round()}%'),
                  if (symptoms.isNotEmpty)
                    _detailRow(_l10n.detailSymptoms, symptoms.join(', ')),
                  if (moments.isNotEmpty)
                    _detailRow('💞', _l10n.detailMoments(moments.length)),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openLog(day);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(_l10n.dayDetailEdit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );

  Widget _fertilitySection(int? dfo, BuildContext ctx) {
    final tt = Theme.of(ctx).textTheme;
    if (dfo == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ctx.colors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(_l10n.fertNoData, style: tt.bodyMedium),
      );
    }
    final chance = pregnancyChance(dfo);
    final relative = dfo == 0
        ? _l10n.fertOnOvulation
        : dfo < 0
            ? _l10n.fertBeforeOvulation(-dfo)
            : _l10n.fertAfterOvulation(dfo);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ctx.colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_l10n.fertilityTitle, style: tt.labelMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(_fertLabel(chance.level),
                  style: tt.titleLarge!
                      .copyWith(color: _fertColor(chance.level))),
              const SizedBox(width: 8),
              if (chance.percentApprox > 0)
                Text(_l10n.fertApprox(chance.percentApprox),
                    style: tt.bodyMedium!
                        .copyWith(color: ctx.colors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(relative, style: tt.labelMedium),
          const SizedBox(height: 8),
          Text(_l10n.fertDisclaimer,
              style: tt.labelMedium!
                  .copyWith(color: ctx.colors.textSecondary)),
        ],
      ),
    );
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
            _showDayDetail(day);
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

  /// Кога е най-вероятно забременяване — нежно обяснение на зеленото.
  void _showOvulationInfo() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(_l10n.ovulationInfoTitle,
                    style: Theme.of(ctx).textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              Text(_l10n.ovulationInfoBody,
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(_l10n.ovulationGotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    Widget item(
      Color color,
      String label, {
      bool heart = false,
      bool hollow = false,
      VoidCallback? onInfo,
    }) {
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          heart
              ? Icon(Icons.favorite, color: context.colors.intimacy, size: 12)
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: hollow ? null : color,
                    border:
                        hollow ? Border.all(color: color, width: 1.5) : null,
                    shape: BoxShape.circle,
                  ),
                ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          if (onInfo != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.info_outline,
                size: 14, color: context.colors.textSecondary),
          ],
        ],
      );
      if (onInfo == null) return row;
      return InkWell(
        onTap: onInfo,
        borderRadius: BorderRadius.circular(8),
        child: row,
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(context.colors.period, _l10n.legendPeriod),
        item(context.colors.period, _l10n.legendPredicted, hollow: true),
        item(context.colors.intimacy, _l10n.legendIntimacy, heart: true),
        item(context.colors.fertile, _l10n.legendFertile,
            onInfo: _showOvulationInfo),
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