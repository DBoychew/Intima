import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../l10n/app_localizations.dart';
import '../../partner/partner_repository.dart';
import '../../partner/supabase_backend.dart';
import '../../partner/sync_backend.dart';
import '../../theme/app_theme.dart';

/// Чат с един партньор — текст, снимки и видео. Без E2E (оповестено).
class PartnerChatScreen extends StatefulWidget {
  const PartnerChatScreen({
    super.key,
    required this.partner,
    required this.title,
  });

  final Partner partner;
  final String title;

  @override
  State<PartnerChatScreen> createState() => _PartnerChatScreenState();
}

class _PartnerChatScreenState extends State<PartnerChatScreen> {
  final _input = TextEditingController();
  List<ChatMessage> _messages = const [];
  bool _loading = true;
  bool _sending = false;
  late String _title = widget.title;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  PartnerRepository get _repo => partnerRepository;
  String get _coupleId => widget.partner.coupleId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<T?> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (e) {
      debugPrint('[partner] $e');
      if (mounted) {
        _toast(kDebugMode ? '${_l10n.partnerError}\n$e' : _l10n.partnerError);
      }
      return null;
    }
  }

  Future<void> _load() async {
    final messages = await _guard(() => _repo.chat(_coupleId));
    if (!mounted) return;
    setState(() {
      if (messages != null) _messages = messages;
      _loading = false;
    });
  }

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await _guard(() async {
      await _repo.sendText(_coupleId, text);
      return true;
    });
    if (ok == true) _input.clear();
    setState(() => _sending = false);
    await _load();
  }

  Future<void> _sendImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 1920, imageQuality: 85);
    if (picked == null) return;
    setState(() => _sending = true);
    await _guard(() => _repo.sendImage(_coupleId, picked.path));
    setState(() => _sending = false);
    await _load();
  }

  Future<void> _sendVideo() async {
    final picked =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _sending = true);
    await _guard(() => _repo.sendVideo(_coupleId, picked.path));
    setState(() => _sending = false);
    await _load();
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: widget.partner.nickname);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.colors.surfaceHigh,
        title: Text(_l10n.partnerNickname),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: _l10n.partnerNicknameHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(_l10n.save,
                style: TextStyle(color: ctx.colors.accentSoft)),
          ),
        ],
      ),
    );
    if (name == null || !mounted) return;
    await _repo.setNickname(_coupleId, name);
    if (mounted) {
      setState(() => _title = name.trim().isEmpty ? widget.title : name.trim());
    }
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
    if (confirmed != true) return;
    await _guard(() => _repo.unlink(_coupleId));
    if (mounted) {
      _toast(_l10n.partnerUnlinked);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: _l10n.partnerNickname,
            onPressed: _rename,
          ),
          IconButton(
            icon: Icon(Icons.link_off, color: context.colors.error),
            tooltip: _l10n.partnerUnlink,
            onPressed: _unlink,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _empty()
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) =>
                              _bubble(_messages[_messages.length - 1 - i]),
                        ),
                      ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _empty() => ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Text(_l10n.partnerEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      );

  Widget _bubble(ChatMessage m) {
    return Align(
      alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: m.mine
              ? context.colors.primary.withValues(alpha: 0.25)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.mediaKind != MediaKind.none && m.mediaUrl != null)
              _media(m),
            if (m.body != null && m.body!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                    top: m.mediaKind == MediaKind.none ? 0 : 8),
                child: Text(m.body!),
              ),
            const SizedBox(height: 4),
            Text(m.mine ? _l10n.partnerYou : '💜',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _media(ChatMessage m) {
    final url = m.mediaUrl!;
    if (m.mediaKind == MediaKind.video) {
      return GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _NetworkVideoScreen(url: url),
        )),
        child: Container(
          width: 200,
          height: 140,
          decoration: BoxDecoration(
            color: context.colors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.play_circle_fill,
              size: 44, color: context.colors.primarySoft),
        ),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _NetworkImageScreen(url: url),
      )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: 200,
            height: 200,
            color: context.colors.surfaceHigh,
            alignment: Alignment.center,
            child: const Text('📷'),
          ),
        ),
      ),
    );
  }

  Widget _inputBar() => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                tooltip: _l10n.addPhoto,
                onPressed: _sending ? null : _sendImage,
              ),
              IconButton(
                icon: const Icon(Icons.video_library_outlined),
                tooltip: _l10n.addVideo,
                onPressed: _sending ? null : _sendVideo,
              ),
              Expanded(
                child: TextField(
                  controller: _input,
                  decoration:
                      InputDecoration(hintText: _l10n.partnerNoteHint),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: _sending ? null : _sendText,
                icon: const Icon(Icons.send),
                tooltip: _l10n.partnerSend,
              ),
            ],
          ),
        ),
      );
}

/// Снимка от мрежата на цял екран — pinch zoom.
class _NetworkImageScreen extends StatelessWidget {
  const _NetworkImageScreen({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            maxScale: 5,
            child: Image.network(url),
          ),
        ),
      ),
    );
  }
}

/// Видео от мрежата на цял екран — тап за пауза/пускане.
class _NetworkVideoScreen extends StatefulWidget {
  const _NetworkVideoScreen({required this.url});
  final String url;

  @override
  State<_NetworkVideoScreen> createState() => _NetworkVideoScreenState();
}

class _NetworkVideoScreenState extends State<_NetworkVideoScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _ready = true);
      _controller.play();
    }).catchError((_) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: _failed
          ? Center(child: Text(AppLocalizations.of(context)!.videoMissing))
          : !_ready
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                  onTap: () => setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  }),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      if (!_controller.value.isPlaying)
                        const Icon(Icons.play_circle_fill,
                            size: 72, color: Colors.white70),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: VideoProgressIndicator(_controller,
                            allowScrubbing: true),
                      ),
                    ],
                  ),
                ),
    );
  }
}
