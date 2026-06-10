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

class _QuickLogSheet extends StatefulWidget {
  const _QuickLogSheet();

  @override
  State<_QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<_QuickLogSheet> {
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];
  static const _tags = ['Менструация', 'Интимен момент ♥', 'ПМС', 'Главоболие', 'Лош сън'];

  int? _mood;
  final _selected = <String>{};
  double _libido = 0.6;
  double _energy = 0.4;

  void _save() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Записано ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    child:
                        Text(_moods[i], style: const TextStyle(fontSize: 28)),
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
              for (final tag in _tags)
                FilterChip(
                  label: Text(tag),
                  selected: _selected.contains(tag),
                  onSelected: (v) => setState(
                      () => v ? _selected.add(tag) : _selected.remove(tag)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _slider('Либидо', _libido, (v) => setState(() => _libido = v)),
          _slider('Енергия', _energy, (v) => setState(() => _energy = v)),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Запази ✨')),
        ],
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
