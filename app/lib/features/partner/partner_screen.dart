import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../partner/partner_repository.dart';
import '../../partner/supabase_backend.dart';
import '../../theme/app_theme.dart';

/// Partner Mode (Фаза 7): сдвояване с код + емоджи проверка и
/// споделени E2E шифровани бележки.
class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  bool _loading = true;
  bool _busy = false;
  String? _inviteCode;
  List<({String author, bool mine, dynamic payload})> _notes = const [];
  final _noteController = TextEditingController();

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  PartnerRepository get _repo => partnerRepository;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _repo.init();
    if (_repo.status == PartnerStatus.linked) await _refreshNotes();
    if (mounted) setState(() => _loading = false);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Изпълнява мрежова операция с видим busy индикатор и общ
  /// error toast — мрежата е новост за приложението, грешките
  /// трябва да са нежни.
  Future<T?> _guard<T>(Future<T> Function() op) async {
    setState(() => _busy = true);
    try {
      return await op();
    } catch (e) {
      debugPrint('[partner] $e');
      if (mounted) {
        // В debug показваме причината — иначе се дебъгва на сляпо.
        _toast(kDebugMode ? '${_l10n.partnerError}\n$e' : _l10n.partnerError);
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refreshNotes() async {
    final inbox = await _guard(() => _repo.inbox());
    if (inbox == null || !mounted) return;
    setState(() {
      _notes = [
        for (final m in inbox.reversed)
          (author: m.author, mine: m.mine, payload: m.payload),
      ];
    });
  }

  Future<void> _invite() async {
    final invite = await _guard(() => _repo.invite());
    if (invite != null && mounted) {
      setState(() => _inviteCode = invite.code);
    }
  }

  Future<void> _checkAccepted() async {
    final sas = await _guard(() => _repo.inviteAccepted());
    if (!mounted) return;
    if (sas == null) {
      _toast(_l10n.partnerWaiting);
      return;
    }
    await _verifySas(sas);
  }

  Future<void> _enterCode() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceHigh,
        title: Text(_l10n.partnerEnterCodeTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(hintText: _l10n.partnerEnterCodeHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(_l10n.partnerJoin,
                style: TextStyle(color: ctx.colors.accentSoft)),
          ),
        ],
      ),
    );
    if (code == null || code.trim().isEmpty || !mounted) return;
    final sas = await _guard(() => _repo.accept(code));
    if (!mounted) return;
    if (sas == null) {
      if (!_busy) _toast(_l10n.partnerCodeInvalid);
      return;
    }
    await _verifySas(sas);
  }

  /// Гласовата проверка: и двамата виждат емоджитата и ги сравняват.
  Future<void> _verifySas(List<String> sas) async {
    final matched = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceHigh,
        title: Text(_l10n.partnerCompareTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sas.join('  '), style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(_l10n.partnerCompareBody,
                style: Theme.of(ctx).textTheme.labelMedium),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_l10n.partnerNoMatch,
                style: TextStyle(color: ctx.colors.error)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_l10n.partnerMatch),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (matched != true) {
      _repo.cancelPending();
      setState(() => _inviteCode = null);
      return;
    }
    HapticFeedback.mediumImpact();
    final ok = await _guard(() async {
      await _repo.confirm();
      return true;
    });
    if (!mounted) return;
    setState(() => _inviteCode = null);
    if (ok == true) await _refreshNotes();
  }

  Future<void> _send() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    final ok = await _guard(() async {
      await _repo.shareNote(text);
      return true;
    });
    if (ok != true || !mounted) return;
    _noteController.clear();
    _toast(_l10n.partnerSent);
    await _refreshNotes();
  }

  Future<void> _unlink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceHigh,
        title: Text(_l10n.partnerUnlinkTitle),
        content: Text(_l10n.partnerUnlinkBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_l10n.partnerUnlink,
                style: TextStyle(color: ctx.colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _guard(() async {
      await _repo.unlink();
      return true;
    });
    if (mounted) {
      setState(() => _notes = const []);
      _toast(_l10n.partnerUnlinked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.partnerTitle),
        actions: [
          if (_repo.status == PartnerStatus.linked)
            IconButton(
              icon: Icon(Icons.link_off, color: context.colors.error),
              tooltip: _l10n.partnerUnlink,
              onPressed: _unlink,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : switch (_repo.status) {
              PartnerStatus.linked => _linkedView(),
              _ => _setupView(),
            },
    );
  }

  Widget _setupView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: Text('💞', style: TextStyle(fontSize: 56))),
        const SizedBox(height: 16),
        Text(_l10n.partnerIntro,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 24),
        if (_inviteCode == null) ...[
          FilledButton(
            onPressed: _busy ? null : _invite,
            child: Text(_l10n.partnerInvite),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _enterCode,
            child: Text(_l10n.partnerHaveCode),
          ),
        ] else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _inviteCode!,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: context.colors.accentSoft,
                          letterSpacing: 6,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(_l10n.partnerSayCode,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _checkAccepted,
            child: Text(_l10n.partnerCheck),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    _repo.cancelPending();
                    setState(() => _inviteCode = null);
                  },
            child: Text(_l10n.cancel),
          ),
        ],
        if (_busy) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _linkedView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(_l10n.partnerStatusLinked,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: context.colors.accentSoft)),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshNotes,
            child: _notes.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 80),
                      Center(
                        child: Text(_l10n.partnerEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final note = _notes[i];
                      return Align(
                        alignment: note.mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                          color: note.mine
                              ? context.colors.primary.withValues(alpha: 0.25)
                              : context.colors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${note.payload['text']}'),
                                const SizedBox(height: 4),
                                Text(note.mine ? _l10n.partnerYou : '💜',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    decoration:
                        InputDecoration(hintText: _l10n.partnerNoteHint),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _busy ? null : _send,
                  icon: const Icon(Icons.send),
                  tooltip: _l10n.partnerSend,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
