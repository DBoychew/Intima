import 'package:flutter/services.dart';

/// Кои пози имат вградена SVG илюстрация в `assets/poses/<id>.svg`.
/// Зарежда се веднъж при старт от AssetManifest; ако файл липсва за
/// дадена поза, PoseArt пада към генерирания вектор арт.
final Set<String> _availablePoseSvgs = {};

bool poseSvgAvailable(String id) => _availablePoseSvgs.contains(id);

Future<void> loadPoseAssets() async {
  try {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final re = RegExp(r'assets/poses/([^/]+)\.svg$');
    for (final key in manifest.listAssets()) {
      final m = re.firstMatch(key);
      if (m != null) _availablePoseSvgs.add(m.group(1)!);
    }
  } catch (_) {
    // Без манифест/папка — просто няма вградени SVG; ползва се fallback.
  }
}
