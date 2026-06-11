import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Генератор на иконата на Intima — пускай с:
///   flutter test tool/generate_icon_test.dart
///   dart run flutter_launcher_icons
///
/// Дизайн: две преплетени сърца — страстно рубинено зад златно — върху
/// дълбок виненолилав градиент. Двойка, близост, страст; палитрата е от
/// docs/design/DESIGN-SYSTEM.md + period/интимност акцентите.
const _size = 1024.0;

const _bgTop = Color(0xFF4A1238);
const _bgBottom = Color(0xFF1A1025);
const _goldLight = Color(0xFFF0D48A);
const _gold = Color(0xFFD4A843);
const _rubyLight = Color(0xFFE25563);
const _rubyDeep = Color(0xFFA9326E);
const _glow = Color(0xFFE0447C);

Path _heartPath(double w) {
  final h = w;
  return Path()
    ..moveTo(0, h * 0.42)
    ..cubicTo(-w * 0.55, h * 0.04, -w * 0.46, -h * 0.48, 0, -h * 0.16)
    ..cubicTo(w * 0.46, -h * 0.48, w * 0.55, h * 0.04, 0, h * 0.42)
    ..close();
}

void _drawHeart(
  Canvas canvas, {
  required Offset center,
  required double width,
  required double rotationDeg,
  required List<Color> colors,
}) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotationDeg * math.pi / 180);
  final path = _heartPath(width);
  canvas.drawPath(
    path,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ).createShader(
        Rect.fromCenter(center: Offset.zero, width: width, height: width),
      )
      ..isAntiAlias = true,
  );
  canvas.restore();
}

void _drawIcon(Canvas canvas, {required bool withBackground}) {
  const s = _size;
  final rect = Rect.fromLTWH(0, 0, s, s);

  if (withBackground) {
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgTop, _bgBottom],
        ).createShader(rect),
    );
  }

  // Страстно сияние зад двойката сърца.
  const glowCenter = Offset(s * 0.5, s * 0.5);
  final glowRect = Rect.fromCircle(center: glowCenter, radius: s * 0.38);
  canvas.drawCircle(
    glowCenter,
    s * 0.38,
    Paint()
      ..shader = RadialGradient(
        colors: [_glow.withValues(alpha: 0.40), _glow.withValues(alpha: 0)],
      ).createShader(glowRect),
  );

  // Рубинено сърце отзад — леко наклонено наляво.
  _drawHeart(
    canvas,
    center: const Offset(s * 0.405, s * 0.445),
    width: s * 0.335,
    rotationDeg: -18,
    colors: const [_rubyLight, _rubyDeep],
  );

  // Златно сърце отпред — наклонено надясно, върху рубиненото.
  _drawHeart(
    canvas,
    center: const Offset(s * 0.575, s * 0.55),
    width: s * 0.40,
    rotationDeg: 10,
    colors: const [_goldLight, _gold],
  );

  // Искра — малък златен акцент горе вдясно.
  canvas.drawCircle(
    const Offset(s * 0.715, s * 0.295),
    s * 0.020,
    Paint()..color = _goldLight,
  );
}

Future<void> _render(String path, {required bool withBackground}) async {
  final recorder = ui.PictureRecorder();
  _drawIcon(Canvas(recorder), withBackground: withBackground);
  final image = await recorder
      .endRecording()
      .toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('генерира иконите в assets/icon/', (tester) async {
    await tester.runAsync(() async {
      await _render('assets/icon/icon.png', withBackground: true);
      await _render('assets/icon/foreground.png', withBackground: false);
    });
    expect(File('assets/icon/icon.png').existsSync(), isTrue);
    expect(File('assets/icon/foreground.png').existsSync(), isTrue);
  });
}
