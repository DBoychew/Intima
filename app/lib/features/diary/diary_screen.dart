import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/bg_dates.dart';
import '../../core/moods.dart';
import '../../data/calendar_repository.dart' show decodeStringList;
import '../../data/database.dart';
import '../../data/db_manager.dart';
import '../../data/diary_repository.dart';
import '../../theme/app_theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<DiaryEntryRow> _entries = [];
  DiaryEntryRow? _memory;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Презареждане и след GDPR изтриване.
    dbManager.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    dbManager.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await diaryRepository.all();
    final memory = await diaryRepository.memory();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _memory = memory;
    });
  }

  Future<void> _openEditor({DiaryEntryRow? entry}) async {
    final changed = await context.push<bool>('/diary/new', extra: entry);
    if (changed != true || !mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _query.isEmpty
        ? _entries
        : _entries.where((e) => entryMatches(e, _query)).toList();
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
          if (_memory != null && _query.isEmpty) ...[
            _memoryCard(context, _memory!),
            const SizedBox(height: 16),
          ],
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  Text(_query.isEmpty ? '📔' : '🔍',
                      style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    _query.isEmpty
                        ? 'Тук ще живеят твоите моменти. 💜\nЗапочни с бутона долу.'
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
                leading: Text(moodEmoji(e.mood),
                    style: const TextStyle(fontSize: 28)),
                title: Text(e.title,
                    style: Theme.of(context).textTheme.titleLarge),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.body,
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
                          bgDate(e.date),
                          if (decodeStringList(e.photos).isNotEmpty)
                            '📷 ${decodeStringList(e.photos).length > 1 ? decodeStringList(e.photos).length : ''}'
                                .trim(),
                          ...decodeStringList(e.tags).map((t) => '#$t'),
                        ].join(' · '),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                onTap: () => _openEditor(entry: e),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _memoryCard(BuildContext context, DiaryEntryRow entry) {
    return Card(
      color: AppColors.surfaceHigh,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Text('🕰️', style: TextStyle(fontSize: 28)),
        title: Text('Спомен от преди време',
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: AppColors.accentSoft, letterSpacing: 1.1)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '„${entry.title}“ · ${bgDate(entry.date)} ${entry.date.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        onTap: () => _openEditor(entry: entry),
      ),
    );
  }
}
