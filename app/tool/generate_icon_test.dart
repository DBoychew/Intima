import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Генератор на иконата на Intima — пускай с:
///   flutter test tool/generate_icon_test.dart
///
/// Дизайн: златен полумесец (цикълът, нощта, дискретността), прегърнал
/// меко лавандулово сърце (близостта) върху дълбоко лилаво — палитрата
/// от docs/design/DESIGN-SYSTEM.md.
const _size = 1024.0;

const _bgTop = Color(0xFF311B4F);
const _bgBottom = Color(0xFF1A1025);
const _goldLight = Color(0xFFE8C97A);
const _gold = Color(0xFFD4A843);
const _lavender = Color(0xFFA78BFA);
const _glow = Color(0xFF7C3AED);

Path _heartPath(Offset c, double w) {
  final h = w;
  return Path()
    ..moveTo(c.dx, c.dy + h * 0.42)
    ..cubicTo(c.dx - w * 0.55, c.dy + h * 0.04, c.dx - w * 0.46,
        c.dy - h * 0.48, c.dx, c.dy - h * 0.16)
    ..cubicTo(c.dx + w * 0.46, c.dy - h * 0.48, c.dx + w * 0.55,
        c.dy + h * 0.04, c.dx, c.dy + h * 0.42)
    ..close();
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

  // Меко лилаво сияние зад композицията.
  final glowCenter = const Offset(s * 0.5, s * 0.5);
  final glowRect = Rect.fromCircle(center: glowCenter, radius: s * 0.36);
  canvas.drawCircle(
    glowCenter,
    s * 0.36,
    Paint()
      ..shader = RadialGradient(
        colors: [_glow.withValues(alpha: 0.35), _glow.withValues(alpha: 0)],
      ).createShader(glowRect),
  );

  // Полумесец: разлика от два кръга, отворен надясно.
  const moonCenter = Offset(s * 0.45, s * 0.50);
  const moonR = s * 0.255;
  final moon = Path()
    ..addOval(Rect.fromCircle(center: moonCenter, radius: moonR));
  final cut = Path()
    ..addOval(Rect.fromCircle(
      center: const Offset(s * 0.555, s * 0.465),
      radius: moonR * 0.92,
    ));
  final crescent = Path.combine(PathOperation.difference, moon, cut);
  canvas.drawPath(
    crescent,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_goldLight, _gold],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonR))
      ..isAntiAlias = true,
  );

  // Сърце, сгушено в извивката на полумесеца.
  final heart = _heartPath(const Offset(s * 0.565, s * 0.535), s * 0.21);
  canvas.drawPath(
    heart,
    Paint()
      ..color = _lavender
      ..isAntiAlias = true,
  );

  // Малка звезда-точка горе вдясно — нощен, дискретен акцент.
  canvas.drawCircle(
    const Offset(s * 0.685, s * 0.315),
    s * 0.018,
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
