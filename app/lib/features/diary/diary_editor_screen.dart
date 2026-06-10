import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  static const _templates = [
    'Свободен текст',
    'Как се чувствам',
    'Благодарност',
    'За нас 💞',
  ];
  static const _moods = ['😞', '😐', '🙂', '😊', '🥰'];

  int _template = 0;
  int? _mood;

  void _save() {
    HapticFeedback.lightImpact();
    context.go('/diary');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Записът е запазен 💜')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/diary'),
        ),
        title: const Text('Нов запис'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Запази',
                style: TextStyle(color: AppColors.accentSoft, fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                _templates.length,
                (i) => ChoiceChip(
                  label: Text(_templates[i]),
                  selected: _template == i,
                  onSelected: (_) => setState(() => _template = i),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_moods.length, (i) {
                final selected = _mood == i;
                return GestureDetector(
                  onTap: () => setState(() => _mood = i),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : null,
                    ),
                    child:
                        Text(_moods[i], style: const TextStyle(fontSize: 26)),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Започни да пишеш…',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined,
                      color: AppColors.textSecondary),
                  label: Text('Добави снимка',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tag, color: AppColors.textSecondary),
                  label: Text('Тагове',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
