import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

void showQuickLogSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _QuickLogSheet(),
  );
}

/// Един интимен момент — на ден може да има няколко.
class _IntimateSession {
  double arousal = 0.6;
  int orgasms = 1;
  final positions = <String>{};
  final note = TextEditingController();
}

class _QuickLogSheet extends StatefulWidget {
  const _QuickLogSheet();

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
  double _libido = 0.6;
  double _energy = 0.4;
  final _sessions = <_IntimateSession>[];

  bool get _intimacyOn => _sessions.isNotEmpty;

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
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Записано ✨')),
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
              child: Text('Как си днес?',
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
