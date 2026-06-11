import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/calendar_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

/// Резултатът от бързия запис — пише се директно в базата.
class QuickLogResult {
  const QuickLogResult({
    required this.mood,
    required this.period,
    required this.symptoms,
    required this.libido,
    required this.energy,
    required this.moments,
  });

  final int? mood;
  final bool period;
  final List<String> symptoms;
  final double libido;
  final double energy;
  final List<MomentDraft> moments;

  bool get intimacy => moments.isNotEmpty;
}

/// [dateLabel] — null означава „днес"; иначе напр. „12 юни 2026".
/// Връща null при затваряне без „Запази".
Future<QuickLogResult?> showQuickLogSheet(
  BuildContext context, {
  String? dateLabel,
  int? initialMood,
  bool initialPeriod = false,
  List<String> initialSymptoms = const [],
  double initialLibido = 0.5,
  double initialEnergy = 0.5,
  List<MomentDraft> initialMoments = const [],
}) {
  return showModalBottomSheet<QuickLogResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _QuickLogSheet(
      dateLabel: dateLabel,
      initialMood: initialMood,
      initialPeriod: initialPeriod,
      initialSymptoms: initialSymptoms,
      initialLibido: initialLibido,
      initialEnergy: initialEnergy,
      initialMoments: initialMoments,
    ),
  );
}

/// Един интимен момент — на ден може да има няколко.
class _IntimateSession {
  _IntimateSession();

  _IntimateSession.from(MomentDraft draft)
      : arousal = draft.arousal,
        orgasms = draft.orgasms {
    positions.addAll(draft.positions);
    note.text = draft.note;
  }

  double arousal = 0.6;
  int orgasms = 1;
  final positions = <String>{};
  final note = TextEditingController();

  MomentDraft toDraft() => MomentDraft(
        arousal: arousal,
        orgasms: orgasms,
        positions: positions.toList(),
        note: note.text.trim(),
      );
}

class _QuickLogSheet extends StatefulWidget {
  const _QuickLogSheet({
    this.dateLabel,
    this.initialMood,
    this.initialPeriod = false,
    this.initialSymptoms = const [],
    this.initialLibido = 0.5,
    this.initialEnergy = 0.5,
    this.initialMoments = const [],
  });

  /// null = запис за днес.
  final String? dateLabel;
  final int? initialMood;
  final bool initialPeriod;
  final List<String> initialSymptoms;
  final double initialLibido;
  final double initialEnergy;
  final List<MomentDraft> initialMoments;

  @override
  State<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<_QuickLogSheet> {
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];

  int? _mood;
  bool _period = false;
  final _symptoms = <String>{};
  double _libido = 0.5;
  double _energy = 0.5;
  final _sessions = <_IntimateSession>[];

  bool get _intimacyOn => _sessions.isNotEmpty;
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _period = widget.initialPeriod;
    _symptoms.addAll(widget.initialSymptoms);
    _libido = widget.initialLibido;
    _energy = widget.initialEnergy;
    _sessions.addAll(widget.initialMoments.map(_IntimateSession.from));
  }

  @override
  void dispose() {
    for (final s in _sessions) {
      s.note.dispose();
    }
    super.dispose();
  }

  void _toggleIntimacy(bool on) {
    HapticFeedback.selectionClick();
    setState(() {
      if (on) {
        _sessions.add(_IntimateSession());
      } else {
        _sessions.clear();
      }
    });
  }

  void _save() {
    HapticFeedback.lightImpact();
    Navigator.pop(
      context,
      QuickLogResult(
        mood: _mood,
        period: _period,
        symptoms: _symptoms.toList(),
        libido: _libido,
        energy: _energy,
        moments: [for (final s in _sessions) s.toDraft()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symptomTags = [_l10n.tagPms, _l10n.tagHeadache, _l10n.tagBadSleep];
    final positions = [
      _l10n.posMissionary,
      _l10n.posSpoons,
      _l10n.posOnTop,
      _l10n.posBehind,
      _l10n.posStanding,
      _l10n.pos69,
      _l10n.posOther,
    ];
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                  widget.dateLabel == null
                      ? _l10n.howAreYouToday
                      : _l10n.logFor(widget.dateLabel!),
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_moods.length, (i) {
                final selected = _mood == i;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _mood = i);
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 150),
                    scale: selected ? 1.2 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? context.colors.primary.withValues(alpha: 0.25)
                            : null,
                      ),
                      child: Text(_moods[i],
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(_l10n.intimateMoment),
                  selected: _intimacyOn,
                  selectedColor: context.colors.intimacy.withValues(alpha: 0.25),
                  onSelected: _toggleIntimacy,
                ),
                FilterChip(
                  label: Text(_l10n.tagPeriod),
                  selected: _period,
                  selectedColor: context.colors.period.withValues(alpha: 0.25),
                  onSelected: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _period = v);
                  },
                ),
                for (final tag in symptomTags)
                  FilterChip(
                    label: Text(tag),
                    selected: _symptoms.contains(tag),
                    onSelected: (v) => setState(
                        () => v ? _symptoms.add(tag) : _symptoms.remove(tag)),
                  ),
              ],
            ),
            if (_intimacyOn) ...[
              const SizedBox(height: 16),
              for (var i = 0; i < _sessions.length; i++) ...[
                _SessionCard(
                  index: i,
                  session: _sessions[i],
                  positions: positions,
                  onChanged: () => setState(() {}),
                  onRemove: () => setState(() {
                    _sessions.removeAt(i).note.dispose();
                  }),
                ),
                const SizedBox(height: 12),
              ],
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _sessions.add(_IntimateSession())),
                  icon: Icon(Icons.add, color: context.colors.accentSoft),
                  label: Text(_l10n.addAnotherMoment,
                      style: TextStyle(color: context.colors.accentSoft)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _slider(_l10n.libido, _libido, (v) => setState(() => _libido = v)),
            _slider(_l10n.energy, _energy, (v) => setState(() => _energy = v)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text(_l10n.saveSparkle)),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.labelMedium),
        ),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            activeColor: context.colors.primarySoft,
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.index,
    required this.session,
    required this.positions,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _IntimateSession session;
  final List<String> positions;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: context.colors.intimacy.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: context.colors.intimacy, size: 18),
              const SizedBox(width: 8),
              Text(l10n.momentN(index + 1),
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close,
                    color: context.colors.textSecondary, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                  width: 72, child: Text(l10n.arousal, style: labelStyle)),
              Expanded(
                child: Slider(
                  value: session.arousal,
                  activeColor: context.colors.intimacy,
                  onChanged: (v) {
                    session.arousal = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                  width: 72, child: Text(l10n.orgasms, style: labelStyle)),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: context.colors.textSecondary),
                onPressed: session.orgasms > 0
                    ? () {
                        session.orgasms--;
                        onChanged();
                      }
                    : null,
              ),
              Text('${session.orgasms}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: context.colors.accentSoft)),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: context.colors.textSecondary),
                onPressed: () {
                  session.orgasms++;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(l10n.positions, style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in positions)
                FilterChip(
                  label: Text(p),
                  selected: session.positions.contains(p),
                  selectedColor:
                      context.colors.intimacy.withValues(alpha: 0.25),
                  onSelected: (v) {
                    v
                        ? session.positions.add(p)
                        : session.positions.remove(p);
                    onChanged();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: session.note,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: l10n.momentNoteHint,
            ),
          ),
        ],
      ),
    );
  }
}
