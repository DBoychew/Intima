import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import 'diary_entry.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _entries = <DiaryEntry>[
    DiaryEntry(
      mood: 4,
      title: 'Вечерята с Н.',
      date: '28 юни',
      tags: ['нас', 'вечеря'],
      text:
          'Най-хубавата вечер от месеци. Говорихме си до късно и се смяхме като в началото.',
    ),
    DiaryEntry(
      mood: 2,
      title: 'Благодарност',
      date: '26 юни',
      tags: ['благодарност'],
      text: 'Днес съм благодарна за спокойствието и за чая сутринта.',
    ),
    DiaryEntry(
      mood: 1,
      title: 'Тежък ден',
      date: '23 юни',
      tags: ['работа'],
      text: 'Много срещи, малко въздух. Утре ще е по-добре.',
    ),
  ];
  String _query = '';

  Future<void> _openEditor({DiaryEntry? entry, int? index}) async {
    final result = await context.push<DiaryEntry>('/diary/new', extra: entry);
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _entries.insert(0, result);
      } else {
        _entries[index] = result;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Записът е запазен 💜')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _query.isEmpty
        ? _entries
        : _entries.where((e) => e.matches(_query)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Дневник')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Търси в записите…',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    _query.isEmpty
                        ? 'Тук ще живеят твоите моменти. 💜'
                        : 'Нищо не открихме за „$_query“.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          for (final e in visible) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Text(e.moodEmoji, style: const TextStyle(fontSize: 28)),
                title: Text(e.title,
                    style: Theme.of(context).textTheme.titleLarge),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          e.date,
                          if (e.hasPhoto) '📷',
                          ...e.tags.map((t) => '#$t'),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                onTap: () => _openEditor(entry: e, index: _entries.indexOf(e)),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
