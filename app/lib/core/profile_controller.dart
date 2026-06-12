import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../security/secure_store.dart';

/// Профилът на потребителя — име и аватар. Аватарът се копира в
/// частното пространство на приложението; пътят и името се пазят в
/// защитеното хранилище.
class ProfileController extends ChangeNotifier {
  static const _nameKey = 'profile_name';
  static const _avatarKey = 'profile_avatar';

  String? _name;
  String? get name => _name;

  String? _avatarPath;
  String? get avatarPath => _avatarPath;

  Future<void> init() async {
    _name = await SecureStore.read(_nameKey);
    _avatarPath = await SecureStore.read(_avatarKey);
    // Файлът може да е изтрит извън приложението — не показваме счупен.
    if (_avatarPath != null && !File(_avatarPath!).existsSync()) {
      _avatarPath = null;
    }
  }

  Future<void> setName(String? name) async {
    final clean = name?.trim();
    if (clean == null || clean.isEmpty) {
      await SecureStore.delete(_nameKey);
      _name = null;
    } else {
      await SecureStore.write(_nameKey, clean);
      _name = clean;
    }
    notifyListeners();
  }

  Future<void> setAvatar(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(dir.path, 'profile'));
    await folder.create(recursive: true);
    final dest = p.join(
      folder.path,
      'avatar_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath)}',
    );
    // Старият аватар се чисти.
    final old = _avatarPath;
    final copy = await File(sourcePath).copy(dest);
    _avatarPath = copy.path;
    await SecureStore.write(_avatarKey, copy.path);
    if (old != null) {
      try {
        await File(old).delete();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> reset() async {
    await SecureStore.delete(_nameKey);
    await SecureStore.delete(_avatarKey);
    _name = null;
    _avatarPath = null;
    notifyListeners();
  }
}

final profileController = ProfileController();
