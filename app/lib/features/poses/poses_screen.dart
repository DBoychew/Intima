import 'package:flutter/material.dart';

import '../../core/premium.dart';
import '../../data/pose_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../partner/supabase_backend.dart' show partnerRepository;
import '../premium/paywall_screen.dart';
import 'pose_art.dart';
import 'pose_detail_screen.dart';
import 'poses_data.dart';

/// Каталог на позите (Фаза 8) — филтри + решетка с карти.
class PosesScreen extends StatefulWidget {
  const PosesScreen({super.key});

  @override
  State<PosesScreen> createState() => _PosesScreenState();
}

class _PosesScreenState extends State<PosesScreen> {
  PosePack? _pack;
  PoseMood? _mood;
  PoseStatus? _status;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  String get _locale => Localizations.localeOf(context).toString();

  @override
  void initState() {
    super.initState();
    poseRepository.addListener(_onChange);
    premium.addListener(_onChange);
    _loadMatches();
  }

  /// Couple Match: best-effort синхрон при отваряне — баджове + известие
  /// за нови съвпадения (напр. партньорът е отбелязал нещо междувременно).
  Future<void> _loadMatches() async {
    try {
      await partnerRepository.init();
      final fresh = await partnerRepository.refreshMatches();
      if (!mounted) return;
      setState(() {});
      if (fresh.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_l10n.coupleMatchNew)));
      }
    } catch (_) {
      // Без партньор/мрежа — каталогът работи нормално.
    }
  }

  @override
  void dispose() {
    poseRepository.removeListener(_onChange);
    premium.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  String _packLabel(PosePack p) => switch (p) {
        PosePack.starter => _l10n.packStarter,
        PosePack.romance => _l10n.packRomance,
        PosePack.adventure => _l10n.packAdventure,
      };

  String _moodLabel(PoseMood m) => switch (m) {
        PoseMood.tender => _l10n.poseMoodTender,
        PoseMood.playful => _l10n.poseMoodPlayful,
        PoseMood.passionate => _l10n.poseMoodPassionate,
        PoseMood.adventurous => _l10n.poseMoodAdventurous,
        PoseMood.slow => _l10n.poseMoodSlow,
      };

  String _statusLabel(PoseStatus s) => switch (s) {
        PoseStatus.wantToTry => _l10n.poseStatusWantToTry,
        PoseStatus.tried => _l10n.poseStatusTried,
        PoseStatus.favorite => _l10n.poseStatusFavorite,
        PoseStatus.none => _l10n.filterAll,
      };

  Future<void> _open(Pose pose) async {
    // Заключена колекция без Premium → paywall.
    if (!pose.pack.isFree && !premium.active) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      if (!premium.active) return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PoseDetailScreen(pose: pose)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final poses = filterPoses(
      posesCatalog,
      poseRepository.states,
      pack: _pack,
      mood: _mood,
      status: _status,
    );
    return Scaffold(
      appBar: AppBar(title: Text(_l10n.posesTitle)),
      body: Column(
        children: [
          _filters(),
          Expanded(
            child: poses.isEmpty
                ? Center(
                    child: Text(_l10n.posesEmpty,
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: poses.length,
                    itemBuilder: (_, i) => _poseCard(poses[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip(_l10n.filterAll, _pack == null && _mood == null && _status == null,
              () => setState(() {
                    _pack = null;
                    _mood = null;
                    _status = null;
                  })),
          for (final p in PosePack.values)
            _chip(_packLabel(p), _pack == p,
                () => setState(() => _pack = _pack == p ? null : p)),
          const SizedBox(width: 4),
          for (final s in [
            PoseStatus.wantToTry,
            PoseStatus.tried,
            PoseStatus.favorite
          ])
            _chip(_statusLabel(s), _status == s,
                () => setState(() => _status = _status == s ? null : s)),
          const SizedBox(width: 4),
          for (final m in PoseMood.values)
            _chip(_moodLabel(m), _mood == m,
                () => setState(() => _mood = _mood == m ? null : m)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _poseCard(Pose pose) {
    final locked = !pose.pack.isFree && !premium.active;
    final status = poseRepository.stateOf(pose.id).status;
    return InkWell(
      onTap: () => _open(pose),
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Генерирана векторна илюстрация като фон.
          PoseArt(color: pose.color, id: pose.id),
          // Лек тъмен градиент долу за четим текст.
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pose.emoji, style: const TextStyle(fontSize: 26)),
                    const Spacer(),
                    if (partnerRepository.matchedPoseIds.contains(pose.id))
                      ...[
                      const Text('💘', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                    ],
                    if (locked)
                      const Icon(Icons.lock, size: 18, color: Colors.white)
                    else if (status == PoseStatus.favorite)
                      const Icon(Icons.favorite, size: 18, color: Colors.white)
                    else if (status == PoseStatus.tried)
                      const Icon(Icons.check_circle,
                          size: 18, color: Colors.white)
                    else if (status == PoseStatus.wantToTry)
                      const Icon(Icons.bookmark,
                          size: 18, color: Colors.white),
                  ],
                ),
                const Spacer(),
                Text(
                  pose.name(_locale),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _dots(Icons.whatshot, pose.intensity),
                    const SizedBox(width: 10),
                    _dots(Icons.fitness_center, pose.difficulty),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dots(IconData icon, int value) => Row(
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 3),
          for (var i = 0; i < 3; i++)
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < value ? Colors.white : Colors.white24,
              ),
            ),
        ],
      );
}
