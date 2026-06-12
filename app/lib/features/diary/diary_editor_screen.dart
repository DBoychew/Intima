import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

import '../../core/moods.dart';
import '../../core/premium.dart';
import '../../data/calendar_repository.dart' show decodeStringList;
import '../../data/database.dart';
import '../../data/diary_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../premium/paywall_screen.dart';

/// Шаблон със собствен журналинг промпт; [starter] се вмъква при празен текст.
typedef _Template = ({String name, String hint, String? starter});

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key, this.initial});

  /// null = нов запис; иначе редакция на съществуващ.
  final DiaryEntryRow? initial;

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  List<_Template> get _templates => [
        (name: _l10n.tplFree, hint: _l10n.tplFreeHint, starter: null),
        (name: _l10n.tplFeelings, hint: _l10n.tplFeelingsHint, starter: null),
        (
          name: _l10n.tplGratitude,
          hint: _l10n.tplGratitudeHint,
          starter: _l10n.tplGratitudeStarter,
        ),
        (
          name: _l10n.tplUs,
          hint: _l10n.tplUsHint,
          starter: _l10n.tplUsStarter,
        ),
      ];

  late final TextEditingController _text;
  int _template = 0;
  int? _mood;
  late List<String> _tags;
  late List<String> _photos;
  late List<String> _videos;
  late List<String> _audios;
  bool _saving = false;

  /// Плейърът за аудио бележките — една активна наведнъж.
  final _audioPlayer = AudioPlayer();
  int? _playingAudio;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.initial?.body ?? '');
    _mood = widget.initial?.mood;
    _tags = [...decodeStringList(widget.initial?.tags)];
    _photos = [...decodeStringList(widget.initial?.photos)];
    _videos = [...decodeStringList(widget.initial?.videos)];
    _audios = [...decodeStringList(widget.initial?.audios)];
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingAudio = null);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String get _derivedTitle {
    final firstLine = _text.text.trim().split('\n').first.trim();
    if (firstLine.isEmpty) return _templates[_template].name;
    return firstLine.length <= 28
        ? firstLine
        : '${firstLine.substring(0, 28)}…';
  }

  void _applyTemplate(int i) {
    setState(() {
      _template = i;
      final starter = _templates[i].starter;
      if (starter != null && _text.text.trim().isEmpty) {
        _text.text = starter;
        _text.selection =
            TextSelection.collapsed(offset: starter.length);
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    final initial = widget.initial;
    if (initial == null) {
      await diaryRepository.create(
        title: _derivedTitle,
        body: _text.text.trim(),
        date: DateTime.now(),
        mood: _mood,
        tags: _tags,
        photos: _photos,
        videos: _videos,
        audios: _audios,
      );
    } else {
      await diaryRepository.update(initial.copyWith(
        title: _derivedTitle,
        body: _text.text.trim(),
        mood: Value(_mood),
        tags: jsonEncode(_tags),
        hasPhoto: _photos.isNotEmpty,
        photos: jsonEncode(_photos),
        videos: jsonEncode(_videos),
        audios: jsonEncode(_audios),
      ));
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceHigh,
        title: Text(_l10n.deleteEntryTitle),
        content: Text(_l10n.deleteEntryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                Text(_l10n.delete, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await diaryRepository.delete(widget.initial!);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickPhotos() async {
    HapticFeedback.selectionClick();
    try {
      final picked = await ImagePicker().pickMultiImage(
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked.isEmpty || !mounted) return;
      final paths = <String>[];
      for (final image in picked) {
        paths.add(await diaryRepository.importPhoto(image.path));
      }
      setState(() => _photos.addAll(paths));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.galleryUnavailable)),
        );
      }
    }
  }

  /// Премиум gate за видеата: без активен Premium отваря paywall-а.
  Future<void> _pickVideo() async {
    HapticFeedback.selectionClick();
    if (!premium.active) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      if (!premium.active || !mounted) return;
      setState(() {}); // катинарчето на бутона изчезва
    }
    try {
      final picked = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );
      if (picked == null || !mounted) return;
      final path = await diaryRepository.importVideo(picked.path);
      setState(() => _videos.add(path));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.galleryUnavailable)),
        );
      }
    }
  }

  Future<bool> _confirmRemoval(String title, String body) async {
    HapticFeedback.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surfaceHigh,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_l10n.remove,
                style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
    return confirmed == true && mounted;
  }

  Future<void> _confirmRemovePhoto(int index) async {
    if (!await _confirmRemoval(_l10n.removePhotoTitle, _l10n.removePhotoBody)) {
      return;
    }
    await diaryRepository.deletePhotoFile(_photos[index]);
    if (mounted) setState(() => _photos.removeAt(index));
  }

  Future<void> _confirmRemoveVideo(int index) async {
    if (!await _confirmRemoval(_l10n.removeVideoTitle, _l10n.removeVideoBody)) {
      return;
    }
    await diaryRepository.deletePhotoFile(_videos[index]);
    if (mounted) setState(() => _videos.removeAt(index));
  }

  /// Записва аудио бележка (Premium) — отваря лист с микрофона.
  Future<void> _recordAudio() async {
    HapticFeedback.selectionClick();
    if (!premium.active) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      if (!premium.active || !mounted) return;
      setState(() {});
    }
    final temp = await showAudioRecordSheet(context);
    if (temp == null || !mounted) return;
    final saved = await diaryRepository.importAudio(temp);
    // Временният файл от записа е копиран — чистим го.
    if (saved != temp) {
      try {
        await File(temp).delete();
      } catch (_) {}
    }
    if (mounted) setState(() => _audios.add(saved));
  }

  Future<void> _toggleAudio(int index) async {
    HapticFeedback.selectionClick();
    if (_playingAudio == index) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _playingAudio = null);
      return;
    }
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(_audios[index]));
      if (mounted) setState(() => _playingAudio = index);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.audioMissing)),
        );
      }
    }
  }

  Future<void> _confirmRemoveAudio(int index) async {
    if (!await _confirmRemoval(_l10n.removeAudioTitle, _l10n.removeAudioBody)) {
      return;
    }
    if (_playingAudio == index) {
      await _audioPlayer.stop();
      _playingAudio = null;
    }
    await diaryRepository.deletePhotoFile(_audios[index]);
    if (mounted) setState(() => _audios.removeAt(index));
  }

  Widget _audioThumb(int index) {
    final playing = _playingAudio == index;
    return Stack(
      children: [
        InkWell(
          onTap: () => _toggleAudio(index),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(playing ? Icons.stop_circle : Icons.play_circle_fill,
                    size: 36, color: context.colors.accentSoft),
                const SizedBox(height: 4),
                const Text('🎙️', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _confirmRemoveAudio(index),
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _viewPhoto(int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PhotoViewerScreen(path: _photos[index]),
    ));
  }

  Widget _photoThumb(int index) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _viewPhoto(index),
          borderRadius: BorderRadius.circular(14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(_photos[index]),
              width: 104,
              height: 104,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 104,
                height: 104,
                color: context.colors.surface,
                alignment: Alignment.center,
                child: const Text('📷'),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _confirmRemovePhoto(index),
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _viewVideo(int index) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _VideoViewerScreen(path: _videos[index]),
    ));
  }

  /// Видео плочка — кадър няма (без тежки зависимости), но плочката
  /// ясно казва какво е: лента + play бутон.
  Widget _videoThumb(int index) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _viewVideo(index),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: context.colors.surfaceHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill,
                    size: 36, color: context.colors.primarySoft),
                const SizedBox(height: 4),
                const Text('🎬', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () => _confirmRemoveVideo(index),
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(widget.initial == null ? _l10n.newEntry : _l10n.editEntry),
        actions: [
          if (widget.initial != null)
            IconButton(
              icon: Icon(Icons.delete_outline, color: context.colors.error),
              tooltip: _l10n.deleteEntryTooltip,
              onPressed: _delete,
            ),
          TextButton(
            onPressed: _save,
            child: Text(
              _l10n.save,
              style: TextStyle(color: context.colors.accentSoft, fontSize: 16),
            ),
          ),
        ],
      ),
      // Целият редактор скролва — снимките и таговете се виждат винаги.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _templates.length,
              (i) => ChoiceChip(
                label: Text(_templates[i].name),
                selected: _template == i,
                onSelected: (_) => _applyTemplate(i),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(moodEmojis.length, (i) {
              final selected = _mood == i;
              return GestureDetector(
                onTap: () => setState(() => _mood = i),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? context.colors.primary.withValues(alpha: 0.25)
                        : null,
                  ),
                  child: Text(
                    moodEmojis[i],
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _text,
            maxLines: null,
            minLines: 8,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: _templates[_template].hint,
            ),
          ),
          if (_photos.isNotEmpty || _videos.isNotEmpty || _audios.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + _videos.length + _audios.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => i < _photos.length
                    ? _photoThumb(i)
                    : i < _photos.length + _videos.length
                        ? _videoThumb(i - _photos.length)
                        : _audioThumb(i - _photos.length - _videos.length),
              ),
            ),
          ],
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
                  icon: Icons.add_photo_alternate_outlined,
                  label: _l10n.addPhoto,
                  onTap: _pickPhotos,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.video_library_outlined,
                  label: _l10n.addVideo,
                  onTap: _pickVideo,
                  // Видеата са Premium — катинарче подсказва преди тап.
                  locked: !premium.active,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.mic_none,
                  label: _l10n.addAudio,
                  onTap: _recordAudio,
                  locked: !premium.active,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.tag,
                  label: _l10n.newTag,
                  onTap: _addTag,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Снимка на цял екран — pinch zoom, затваряне със стрелката или тап.
class _PhotoViewerScreen extends StatelessWidget {
  const _PhotoViewerScreen({required this.path});

  final String path;

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
            child: Image.file(
              File(path),
              errorBuilder: (_, _, _) =>
                Text(AppLocalizations.of(context)!.photoMissing),
            ),
          ),
        ),
      ),
    );
  }
}

/// Записва аудио бележка във временен файл; връща пътя или null при
/// отказ. Записът тръгва веднага — намерението е ясно от бутона.
Future<String?> showAudioRecordSheet(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const _AudioRecordSheet(),
    );

class _AudioRecordSheet extends StatefulWidget {
  const _AudioRecordSheet();

  @override
  State<_AudioRecordSheet> createState() => _AudioRecordSheetState();
}

class _AudioRecordSheetState extends State<_AudioRecordSheet> {
  final _recorder = AudioRecorder();
  Timer? _timer;
  int _seconds = 0;
  bool _recording = false;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) setState(() => _denied = true);
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = p.join(
      dir.path,
      'note_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    if (!mounted) {
      await _recorder.stop();
      return;
    }
    setState(() => _recording = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _stopAndSave() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (mounted) Navigator.pop(context, path);
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    final path = await _recorder.stop();
    if (path != null) {
      try {
        await File(path).delete();
      } catch (_) {}
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  String get _elapsed => '${(_seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(_seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
                child: Text('🎙️', style: TextStyle(fontSize: 48))),
            const SizedBox(height: 12),
            Center(
              child: _denied
                  ? Text(l10n.audioPermissionDenied,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium)
                  : Text(
                      _recording
                          ? '${l10n.audioRecording} $_elapsed'
                          : l10n.audioRecording,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: context.colors.accentSoft),
                    ),
            ),
            const SizedBox(height: 20),
            if (_denied)
              FilledButton(
                onPressed: _cancel,
                child: Text(l10n.cancel),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _cancel,
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _recording ? _stopAndSave : null,
                      icon: const Icon(Icons.stop),
                      label: Text(l10n.audioStopSave),
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

/// Видео на цял екран — тап за пауза/пускане, скруб лента отдолу.
class _VideoViewerScreen extends StatefulWidget {
  const _VideoViewerScreen({required this.path});

  final String path;

  @override
  State<_VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<_VideoViewerScreen> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
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

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
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
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                      // Голям play бутон, когато е на пауза.
                      if (!_controller.value.isPlaying)
                        const Icon(Icons.play_circle_fill,
                            size: 72, color: Colors.white70),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 24,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                        ),
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
    this.locked = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Premium функция без активен Premium — бутонът работи (отваря
  /// paywall-а), но катинарчето подсказва предварително.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.textSecondary;
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          if (locked) ...[
            const SizedBox(width: 6),
            Icon(Icons.lock_outline, size: 14, color: color),
          ],
        ],
      ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        backgroundColor: context.colors.surface,
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
      backgroundColor: context.colors.surfaceHigh,
      title: Text(AppLocalizations.of(context)!.newTagTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.tagNameLabel,
          hintText: AppLocalizations.of(context)!.tagNameHint,
          prefixText: '# ',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            AppLocalizations.of(context)!.add,
            style: TextStyle(color: context.colors.accentSoft),
          ),
        ),
      ],
    );
  }
}