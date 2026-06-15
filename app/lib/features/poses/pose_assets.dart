import 'package:flutter/services.dart';

/// Кои пози имат вградена илюстрация в `assets/poses/<id>.<ext>`
/// (svg или растер: jpg/png/webp). Зарежда се веднъж при старт от
/// AssetManifest; липсва ли файл за поза, PoseArt пада към генерирания
/// вектор арт.
final Map<String, String> _poseAsset = {};

String? poseAssetPath(String id) => _poseAsset[id];
bool poseAssetIsSvg(String id) =>
    _poseAsset[id]?.toLowerCase().endsWith('.svg') ?? false;

Future<void> loadPoseAssets() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final re = RegExp(r'assets/poses/([^/]+)\.(svg|png|jpe?g|webp)$',
        caseSensitive: false);
    for (final key in manifest.listAssets()) {
      final m = re.firstMatch(key);
      if (m == null) continue;
      final id = m.group(1)!;
      // Предпочитаме SVG, ако случайно има и двата формата за една поза.
      final existing = _poseAsset[id];
      if (existing == null || (!existing.toLowerCase().endsWith('.svg') &&
          key.toLowerCase().endsWith('.svg'))) {
        _poseAsset[id] = key;
      }
    }
  } catch (_) {
    // Без манифест/папка — ползва се генерираният fallback.
  }
}
