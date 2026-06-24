import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/cycle_settings.dart';
import '../../core/data_version.dart';
import '../../core/moods.dart';
import '../../core/premium.dart';
import '../../data/insights_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../premium/paywall_screen.dart';

/// Инсайти и статистики (Premium) — изцяло локални изчисления.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  InsightsData? _data;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  String get _locale => Localizations.localeOf(context).toString();

  @override
  void initState() {
    super.initState();
    _reload();
    dataVersion.addListener(_reload);
    premium.addListener(_onPremiumChanged);
  }

  @override
  void dispose() {
    dataVersion.removeListener(_reload);
    premium.removeListener(_onPremiumChanged);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _reload() async {
    final data = await insightsRepository.compute();
    if (mounted) setState(() => _data = data);
  }

  String _phaseLabel(CyclePhase phase) => switch (phase) {
        CyclePhase.menstrual => _l10n.phaseMenstrual,
        CyclePhase.follicular => _l10n.phaseFollicular,
        CyclePhase.ovulation => _l10n.phaseOvulation,
        CyclePhase.luteal => _l10n.phaseLuteal,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_l10n.insightsTitle)),
      body: !premium.active
          ? _teaser()
          : _data == null
              ? const Center(child: CircularProgressIndicator())
              : _data!.isEmpty
                  ? _empty()
                  : _content(_data!),
    );
  }

  /// Демо данни за превюто на free потребителите — да видят какво
  /// купуват, без да гадаят по празен екран.
  InsightsData _demoData() {
    final now = DateTime.now();
    return InsightsData(
      cycle: const CycleStats(count: 3, average: 28.4, min: 27, max: 30),
      moodByPhase: const {
        CyclePhase.menstrual: 1.8,
        CyclePhase.follicular: 3.1,
        CyclePhase.ovulation: 3.8,
        CyclePhase.luteal: 2.6,
      },
      moodSamples: const {
        CyclePhase.menstrual: 5,
        CyclePhase.follicular: 6,
        CyclePhase.ovulation: 3,
        CyclePhase.luteal: 7,
      },
      trend: [
        for (var i = 5; i >= 0; i--)
          MonthTrend(
            month: DateTime(now.year, now.month - i),
            avgLibido: 0.45 + 0.07 * (5 - i),
            avgEnergy: 0.55 + 0.05 * (5 - i),
            moments: 2 + (5 - i) % 3,
          ),
      ],
      recap: Recap(
        diaryEntries: 8,
        moments: 5,
        orgasms: 7,
        avgMood: 3.2,
        topSymptom: _l10n.tagPms,
        topPosition: _l10n.posSpoons,
      ),
      correlations: const Correlations(
        moodFertileDelta: 0.6,
        intimacyInFertilePct: 0.55,
        libidoEnergyTrend: 1,
      ),
    );
  }

  /// За free потребители — живо превю с демо данни + път към paywall-а.
  Widget _teaser() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_l10n.insightsSampleBadge,
                style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.45,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: _cards(_demoData()),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_l10n.insightsTeaser,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PaywallScreen()),
                    );
                    if (mounted) setState(() {});
                  },
                  child: Text(_l10n.insightsUnlock),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _empty() => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(_l10n.insightsEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );

  /// Картите за дадените данни — общи за реалния изглед и демо превюто.
  List<Widget> _cards(InsightsData data) => [
        _cycleCard(data.cycle),
        const SizedBox(height: 12),
        _moodCard(data),
        if (data.correlations.hasAny) ...[
          const SizedBox(height: 12),
          _correlationsCard(data.correlations),
        ],
        if (data.trend.any((m) => m.hasData)) ...[
          const SizedBox(height: 12),
          _trendCard(data.trend),
        ],
        if (data.recap.hasData) ...[
          const SizedBox(height: 12),
          _recapCard(data.recap),
        ],
      ];

  Widget _correlationsCard(Correlations c) {
    final lines = <String>[];
    if (c.moodFertileDelta != null && c.moodFertileDelta!.abs() >= 0.3) {
      lines.add(c.moodFertileDelta! > 0
          ? _l10n.corrMoodFertileUp
          : _l10n.corrMoodFertileDown);
    }
    if (c.intimacyInFertilePct != null) {
      lines.add(_l10n
          .corrIntimacyFertile((c.intimacyInFertilePct! * 100).round()));
    }
    if (c.libidoEnergyTrend != null && c.libidoEnergyTrend != 0) {
      lines.add(c.libidoEnergyTrend! > 0
          ? _l10n.corrLibidoEnergyTogether
          : _l10n.corrLibidoEnergyOpposite);
    }
    if (lines.isEmpty) return const SizedBox.shrink();
    return _card(title: _l10n.insightsCorrTitle, children: [
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  '),
              Expanded(
                  child: Text(line,
                      style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        ),
    ]);
  }

  Widget _content(InsightsData data) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._cards(data),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _cycleCard(CycleStats cycle) {
    if (cycle.count == 0) {
      return _card(title: _l10n.insightsCycleCard, children: [
        Text(_l10n.insightsCycleNeedTwo,
            style: Theme.of(context).textTheme.labelMedium),
      ]);
    }
    final avg = NumberFormat.decimalPatternDigits(
      locale: _locale,
      decimalDigits: 1,
    ).format(cycle.average);
    return _card(title: _l10n.insightsCycleCard, children: [
      Text(_l10n.insightsAvgDays(avg),
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(color: context.colors.accentSoft)),
      const SizedBox(height: 4),
      Text(_l10n.insightsMeasuredFrom(cycle.count),
          style: Theme.of(context).textTheme.labelMedium),
      if (cycle.min != cycle.max)
        Text(_l10n.insightsCycleRange(cycle.min!, cycle.max!),
            style: Theme.of(context).textTheme.labelMedium),
      Text(_l10n.insightsVsSetting(cycleSettings.cycleLength),
          style: Theme.of(context).textTheme.labelMedium),
    ]);
  }

  Widget _moodCard(InsightsData data) {
    final phases = CyclePhase.values
        .where((p) => data.moodByPhase.containsKey(p))
        .toList();
    return _card(title: _l10n.insightsMoodCard, children: [
      for (final phase in phases) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(_phaseLabel(phase),
                    style: Theme.of(context).textTheme.labelMedium),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(children: [
                    Container(height: 12, color: context.colors.surfaceHigh),
                    FractionallySizedBox(
                      // 0..4 → запълване; пазим минимум, за да личи.
                      widthFactor:
                          (data.moodByPhase[phase]! / 4).clamp(0.06, 1.0),
                      child: Container(
                          height: 12, color: context.colors.primarySoft),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              Text(moodEmoji(data.moodByPhase[phase]!.round()),
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
      // С под 2 фази картината е още непълна — нежен подканващ текст.
      if (phases.length < 2) ...[
        const SizedBox(height: 4),
        Text(_l10n.insightsMoodHint,
            style: Theme.of(context).textTheme.labelMedium),
      ],
    ]);
  }

  Widget _trendCard(List<MonthTrend> months) {
    const barMax = 64.0;
    final monthFmt = DateFormat.MMM(_locale);
    return _card(title: _l10n.insightsTrendCard, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in months)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _bar((m.avgLibido ?? 0) * barMax,
                            context.colors.primarySoft),
                        const SizedBox(width: 3),
                        _bar((m.avgEnergy ?? 0) * barMax,
                            context.colors.accentSoft),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(monthFmt.format(m.month),
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Row(children: [
        _legendDot(context.colors.primarySoft, _l10n.libido),
        const SizedBox(width: 16),
        _legendDot(context.colors.accentSoft, _l10n.energy),
      ]),
    ]);
  }

  Widget _bar(double height, Color color) => Container(
        width: 10,
        // Нулата остава видима като точица — личи, че месецът е празен.
        height: height < 3 ? 3 : height,
        decoration: BoxDecoration(
          color: height < 3 ? color.withValues(alpha: 0.25) : color,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _legendDot(Color color, String label) => Row(children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ]);

  Widget _recapCard(Recap recap) {
    Widget row(String emoji, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: Theme.of(context).textTheme.bodyMedium)),
          ]),
        );
    return _card(title: _l10n.insightsRecapCard, children: [
      row('📖', _l10n.insightsRecapEntries(recap.diaryEntries)),
      row('💞', _l10n.insightsRecapMoments(recap.moments)),
      if (recap.moments > 0) row('✨', _l10n.insightsRecapOrgasms(recap.orgasms)),
      if (recap.avgMood != null)
        row(moodEmoji(recap.avgMood!.round()), _l10n.insightsAvgMood),
      if (recap.topSymptom != null)
        row('🌡️', '${_l10n.insightsTopSymptom}: ${recap.topSymptom}'),
      if (recap.topPosition != null)
        row('💘', '${_l10n.insightsTopPosition}: ${recap.topPosition}'),
    ]);
  }
}
