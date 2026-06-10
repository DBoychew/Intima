import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

/// Прототип с примерни записи — реалните идват от БД във Фаза 4.
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  static const _entries = [
    (
      emoji: '🥰',
      title: 'Вечерята с Н.',
      date: '28 юни',
      tags: ['нас', 'вечеря'],
      excerpt: 'Най-хубавата вечер от месеци. Говорихме си до късно и…',
    ),
    (
      emoji: '🙂',
      title: 'Благодарност',
      date: '26 юни',
      tags: ['благодарност'],
      excerpt: 'Днес съм благодарна за спокойствието и за чая сутринта…',
    ),
    (
      emoji: '😐',
      title: 'Тежък ден',
      date: '23 юни',
      tags: ['работа'],
      excerpt: 'Много срещи, малко въздух. Утре ще е по-добре.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дневник')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/diary/new'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: 'Търси в записите…',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          for (final e in _entries) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Text(e.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(e.title,
                    style: Theme.of(context).textTheme.titleLarge),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${e.date} · ${e.tags.map((t) => '#$t').join(' ')}',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                onTap: () {},
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
