import 'package:flutter/material.dart';

import '../../core/dates.dart';
import '../../data/pose_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'poses_data.dart';

/// Детайл на поза: описание, статус, оценка, „пробвано на", бележка.
class PoseDetailScreen extends StatefulWidget {
  const PoseDetailScreen({super.key, required this.pose});

  final Pose pose;

  @override
  State<PoseDetailScreen> createState() => _PoseDetailScreenState();
}

class _PoseDetailScreenState extends State<PoseDetailScreen> {
  late PoseState _state = poseRepository.stateOf(widget.pose.id);
  late final TextEditingController _note =
      TextEditingController(text: _state.note);

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  String get _locale => Localizations.localeOf(context).toString();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String _moodLabel(PoseMood m) => switch (m) {
        PoseMood.tender => _l10n.poseMoodTender,
        PoseMood.playful => _l10n.poseMoodPlayful,
        PoseMood.passionate => _l10n.poseMoodPassionate,
        PoseMood.adventurous => _l10n.poseMoodAdventurous,
        PoseMood.slow => _l10n.poseMoodSlow,
      };

  Future<void> _save(PoseState next) async {
    setState(() => _state = next);
    await poseRepository.update(widget.pose.id, next);
  }

  void _toggleStatus(PoseStatus s) {
    _save(_state.copyWith(status: _state.status == s ? PoseStatus.none : s));
  }

  void _setRating(int r) {
    _save(_state.copyWith(
      rating: _state.rating == r ? null : r,
      clearRating: _state.rating == r,
    ));
  }

  Future<void> _pickTriedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _state.triedOn ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
    );
    if (picked == null) return;
    // Отбелязването „пробвано" подразбира статус „пробвано", ако е празно.
    _save(_state.copyWith(
      triedOn: picked,
      status: _state.status == PoseStatus.none
          ? PoseStatus.tried
          : _state.status,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pose = widget.pose;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(pose.name(_locale))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Заглавна „илюстрация" (placeholder силует).
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  pose.color.withValues(alpha: 0.85),
                  pose.color.withValues(alpha: 0.4),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(pose.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(_l10n.poseArtNote,
                    style: tt.labelMedium!.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Тагове.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in pose.moods) Chip(label: Text(_moodLabel(m))),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Text('${_l10n.poseIntensity}: ', style: tt.labelMedium),
            _dots(pose.intensity),
            const SizedBox(width: 16),
            Text('${_l10n.poseDifficulty}: ', style: tt.labelMedium),
            _dots(pose.difficulty),
          ]),
          const SizedBox(height: 16),
          Text(pose.description(_locale), style: tt.bodyMedium),
          const Divider(height: 32),
          // Статус.
          Wrap(
            spacing: 8,
            children: [
              for (final s in [
                PoseStatus.wantToTry,
                PoseStatus.tried,
                PoseStatus.favorite
              ])
                ChoiceChip(
                  label: Text(switch (s) {
                    PoseStatus.wantToTry => _l10n.poseStatusWantToTry,
                    PoseStatus.tried => _l10n.poseStatusTried,
                    _ => _l10n.poseStatusFavorite,
                  }),
                  selected: _state.status == s,
                  onSelected: (_) => _toggleStatus(s),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Оценка.
          Text(_l10n.poseRate, style: tt.labelMedium),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => _setRating(i),
                  icon: Icon(
                    (_state.rating ?? 0) >= i
                        ? Icons.star
                        : Icons.star_border,
                    color: context.colors.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Пробвано на.
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_l10n.poseTriedOn),
            subtitle: _state.triedOn == null
                ? Text(_l10n.poseMarkTriedToday, style: tt.labelMedium)
                : Text(dayMonthYear(_state.triedOn!, _locale)),
            trailing: Icon(Icons.event, color: context.colors.accentSoft),
            onTap: _pickTriedDate,
          ),
          const SizedBox(height: 8),
          // Лична бележка.
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _l10n.poseNote,
              hintText: _l10n.poseNoteHint,
            ),
            onChanged: (v) => _save(_state.copyWith(note: v)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _dots(int value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < value
                    ? context.colors.accent
                    : context.colors.surfaceHigh,
              ),
            ),
        ],
      );
}
