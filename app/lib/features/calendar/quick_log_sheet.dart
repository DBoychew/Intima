import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/calendar_repository.dart';
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

/// [dateLabel] — null означава „днес"; иначе напр. „12 юни".
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
  static const _tags = ['Менструация', 'ПМС', 'Главоболие', 'Лош сън'];
  static const _positions = [
    'Мисионерска',
    'Лъжички',
    'Отгоре',
    'Отзад',
    'Права',
    '69',
    'Друга',
  ];

  int? _mood;
  final _selected = <String>{};
  double _libido = 0.5;
  double _energy = 0.5;
  final _sessions = <_IntimateSession>[];

  bool get _intimacyOn => _sessions.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _mood = widget.initialMood;
    _libido = widget.initialLibido;
    _energy = widget.initialEnergy;
    if (widget.initialPeriod) _selected.add('Менструация');
    _selected.addAll(widget.initialSymptoms.where(_tags.contains));
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
        period: _selected.contains('Менструация'),
        symptoms:
            _selected.where((t) => t != 'Менструация').toList(),
        libido: _libido,
        energy: _energy,
        moments: [for (final s in _sessions) s.toDraft()],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      ? 'Как си днес?'
                      : 'Запис за ${widget.dateLabel}',
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
                            ? AppColors.primary.withValues(alpha: 0.25)
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
                  label: const Text('Интимен момент ♥'),
                  selected: _intimacyOn,
                  selectedColor: AppColors.intimacy.withValues(alpha: 0.25),
                  onSelected: _toggleIntimacy,
                ),
                for (final tag in _tags)
                  FilterChip(
                    label: Text(tag),
                    selected: _selected.contains(tag),
                    onSelected: (v) => setState(
                        () => v ? _selected.add(tag) : _selected.remove(tag)),
                  ),
              ],
            ),
            if (_intimacyOn) ...[
              const SizedBox(height: 16),
              for (var i = 0; i < _sessions.length; i++) ...[
                _SessionCard(
                  index: i,
                  session: _sessions[i],
                  positions: _positions,
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
                  icon: const Icon(Icons.add, color: AppColors.accentSoft),
                  label: const Text('Добави още един момент',
                      style: TextStyle(color: AppColors.accentSoft)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _slider('Либидо', _libido, (v) => setState(() => _libido = v)),
            _slider('Енергия', _energy, (v) => setState(() => _energy = v)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: const Text('Запази ✨')),
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
            activeColor: AppColors.primarySoft,
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
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.intimacy.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.intimacy, size: 18),
              const SizedBox(width: 8),
              Text('Момент ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(width: 72, child: Text('Възбуда', style: labelStyle)),
              Expanded(
                child: Slider(
                  value: session.arousal,
                  activeColor: AppColors.intimacy,
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
              SizedBox(width: 72, child: Text('Оргазми', style: labelStyle)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.textSecondary),
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
                      .copyWith(color: AppColors.accentSoft)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textSecondary),
                onPressed: () {
                  session.orgasms++;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Пози', style: labelStyle),
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
                      AppColors.intimacy.withValues(alpha: 0.25),
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
            decoration: const InputDecoration(
              hintText: 'Опиши момента… (само за теб)',
            ),
          ),
        ],
      ),
    );
  }
}
