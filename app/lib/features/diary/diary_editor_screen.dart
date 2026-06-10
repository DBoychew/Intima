import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import 'diary_entry.dart';

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key, this.initial});

  /// null = нов запис; иначе редакция на съществуващ.
  final DiaryEntry? initial;

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

  late final TextEditingController _text;
  int _template = 0;
  int? _mood;
  late List<String> _tags;
  late bool _hasPhoto;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.initial?.text ?? '');
    _mood = widget.initial?.mood;
    _tags = [...widget.initial?.tags ?? []];
    _hasPhoto = widget.initial?.hasPhoto ?? false;
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String get _derivedTitle {
    final firstLine = _text.text.trim().split('\n').first.trim();
    if (firstLine.isEmpty) return _templates[_template];
    return firstLine.length <= 28
        ? firstLine
        : '${firstLine.substring(0, 28)}…';
  }

  void _save() {
    HapticFeedback.lightImpact();
    Navigator.pop(
      context,
      DiaryEntry(
        title: widget.initial?.title ?? _derivedTitle,
        text: _text.text.trim(),
        date: widget.initial?.date ?? '30 юни',
        mood: _mood,
        tags: _tags,
        hasPhoto: _hasPhoto,
      ),
    );
  }

  Future<void> _addTag() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (_) => const _AddTagDialog(),
    );
    final clean = tag?.trim().replaceAll('#', '');
    if (clean != null && clean.isNotEmpty && !_tags.contains(clean)) {
      setState(() => _tags.add(clean));
    }
  }

  void _togglePhoto() {
    HapticFeedback.selectionClick();
    setState(() => _hasPhoto = !_hasPhoto);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _hasPhoto
              ? 'Снимката е прикачена 📷 (галерията идва във Фаза 4)'
              : 'Снимката е премахната',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.initial == null ? 'Нов запис' : 'Редакция'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Запази',
              style: TextStyle(color: AppColors.accentSoft, fontSize: 16),
            ),
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
              children: List.generate(DiaryEntry.moods.length, (i) {
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
                    child: Text(
                      DiaryEntry.moods[i],
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _text,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Започни да пишеш…',
                ),
              ),
            ),
            if (_hasPhoto || _tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_hasPhoto)
                    InputChip(
                      avatar: const Icon(
                        Icons.photo,
                        size: 18,
                        color: AppColors.accentSoft,
                      ),
                      label: const Text('снимка'),
                      onDeleted: _togglePhoto,
                    ),
                  for (final t in _tags)
                    InputChip(
                      label: Text('#$t'),
                      onDeleted: () => setState(() => _tags.remove(t)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: _hasPhoto
                        ? Icons.delete_outline
                        : Icons.photo_camera_outlined,
                    label: _hasPhoto ? 'Премахни снимка' : 'Добави снимка',
                    highlighted: _hasPhoto,
                    onTap: _togglePhoto,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.tag,
                    label: 'Нов таг',
                    onTap: _addTag,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Вторичен бутон в стила на полетата — мека повърхност без рамка,
/// но с голяма зона за докосване.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? AppColors.accentSoft : AppColors.textSecondary;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _AddTagDialog extends StatefulWidget {
  const _AddTagDialog();

  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      title: const Text('Нов таг'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Име на тага',
          hintText: 'напр. нас',
          prefixText: '# ',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отказ'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(
            'Добави',
            style: TextStyle(color: AppColors.accentSoft),
          ),
        ),
      ],
    );
  }
}
