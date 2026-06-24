import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../partner/partner_repository.dart';
import '../../partner/supabase_backend.dart';
import '../../theme/app_theme.dart';
import 'partner_chat_screen.dart';

/// Partner Mode (Фаза 7): няколко партньора + чат със снимки/видео.
/// Съдържанието се пази на сървъра в явен вид (оповестено).
class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  bool _loading = true;
  bool _busy = false;
  bool _failed = false;
  String? _inviteCode;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  PartnerRepository get _repo => partnerRepository;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      await _repo.init();
    } catch (e) {
      debugPrint('[partner] $e');
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<T?> _guard<T>(Future<T> Function() op) async {
    setState(() => _busy = true);
    try {
      return await op();
    } catch (e) {
      debugPrint('[partner] $e');
      if (mounted) {
        _toast(kDebugMode ? '${_l10n.partnerError}\n$e' : _l10n.partnerError);
      }
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _name(Partner p, int index) =>
      p.nickname ?? _l10n.partnerUnnamed(index + 1);

  Future<void> _openChat(Partner p, int index) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PartnerChatScreen(partner: p, title: _name(p, index)),
    ));
    // Връщане от чата (може да е прекъсната връзка / преименуван).
    await _guard(_repo.refreshPartners);
    if (mounted) setState(() {});
  }

  Future<void> _invite() async {
    final code = await _guard(_repo.invite);
    if (code != null && mounted) setState(() => _inviteCode = code);
  }

  Future<void> _checkInvite() async {
    final partner = await _guard(_repo.pollInvite);
    if (!mounted) return;
    if (partner == null) {
      _toast(_l10n.partnerWaiting);
      return;
    }
    setState(() => _inviteCode = null);
    _toast(_l10n.partnerLinked);
    await _openChat(partner, _repo.partners.length - 1);
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
              child: Text(_l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(_l10n.partnerJoin,
                style: TextStyle(color: ctx.colors.accentSoft)),
          ),
        ],
      ),
    );
    if (code == null || code.trim().isEmpty || !mounted) return;
    final partner = await _guard(() => _repo.accept(code));
    if (!mounted) return;
    if (partner == null) {
      if (!_busy) _toast(_l10n.partnerCodeInvalid);
      return;
    }
    _toast(_l10n.partnerLinked);
    await _openChat(partner, _repo.partners.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_l10n.partnerTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed
              ? _errorView()
              : _body(),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_l10n.partnerError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              FilledButton(onPressed: _init, child: Text(_l10n.bootRetry)),
            ],
          ),
        ),
      );

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_repo.hasPartners) ...[
          for (var i = 0; i < _repo.partners.length; i++)
            _partnerTile(_repo.partners[i], i),
          const SizedBox(height: 12),
        ],
        if (_inviteCode != null)
          _inviteCard()
        else
          _setupButtons(),
        if (_busy) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }

  Widget _partnerTile(Partner p, int index) => Card(
        child: ListTile(
          leading: const Text('💞', style: TextStyle(fontSize: 24)),
          title: Text(_name(p, index)),
          trailing: Icon(Icons.chevron_right,
              color: context.colors.textSecondary),
          onTap: () => _openChat(p, index),
        ),
      );

  Widget _setupButtons() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_repo.hasPartners) ...[
            const Center(child: Text('💞', style: TextStyle(fontSize: 56))),
            const SizedBox(height: 16),
            Text(_l10n.partnerIntro,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
          ],
          FilledButton(
            onPressed: _busy ? null : _invite,
            child: Text(_repo.hasPartners
                ? _l10n.partnerAddAnother
                : _l10n.partnerInvite),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _enterCode,
            child: Text(_l10n.partnerHaveCode),
          ),
        ],
      );

  Widget _inviteCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(_inviteCode!,
                      style:
                          Theme.of(context).textTheme.displaySmall!.copyWith(
                                color: context.colors.accentSoft,
                                letterSpacing: 6,
                              )),
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
            onPressed: _busy ? null : _checkInvite,
            child: Text(_l10n.partnerCheck),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    _repo.cancelInvite();
                    setState(() => _inviteCode = null);
                  },
            child: Text(_l10n.cancel),
          ),
        ],
      );
}
