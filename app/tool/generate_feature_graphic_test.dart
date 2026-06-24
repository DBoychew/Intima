import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Google Play feature graphic (1024×500) — пускай с:
///   flutter test tool/generate_feature_graphic_test.dart
/// Композиция: двете сърца от иконата вляво, име + слоган вдясно.
const _w = 1024.0;
const _h = 500.0;

const _bgTop = Color(0xFF4A1238);
const _bgBottom = Color(0xFF1A1025);
const _goldLight = Color(0xFFF0D48A);
const _gold = Color(0xFFD4A843);
const _rubyLight = Color(0xFFE25563);
const _rubyDeep = Color(0xFFA9326E);
const _glow = Color(0xFFE0447C);
const _textPrimary = Color(0xFFF3EFFA);
const _textSecondary = Color(0xFFC9BBDD);

Path _heartPath(double w) {
  final h = w;
  return Path()
    ..moveTo(0, h * 0.42)
    ..cubicTo(-w * 0.55, h * 0.04, -w * 0.46, -h * 0.48, 0, -h * 0.16)
    ..cubicTo(w * 0.46, -h * 0.48, w * 0.55, h * 0.04, 0, h * 0.42)
    ..close();
}

void _drawHeart(Canvas canvas, Offset center, double width,
    double rotationDeg, List<Color> colors) {
  canvas.save();
  canvas.translate(center.dx, center.dy);
  canvas.rotate(rotationDeg * math.pi / 180);
  canvas.drawPath(
    _heartPath(width),
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

void _drawText(Canvas canvas, String text, Offset at, TextStyle style,
    {double maxWidth = _w}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, at);
}

Future<void> _loadFont(String family, String assetPath) async {
  final bytes = File(assetPath).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

void main() {
  testWidgets('генерира feature graphic в assets/store/', (tester) async {
    await tester.runAsync(() async {
      await _loadFont(
          'PlayfairDisplay', 'assets/fonts/PlayfairDisplay-SemiBold.ttf');
      await _loadFont('Inter', 'assets/fonts/Inter-Medium.ttf');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const rect = Rect.fromLTWH(0, 0, _w, _h);

      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ).createShader(rect),
      );

      // Сияние зад сърцата.
      const heartsCenter = Offset(255, 250);
      canvas.drawCircle(
        heartsCenter,
        210,
        Paint()
          ..shader = RadialGradient(colors: [
            _glow.withValues(alpha: 0.38),
            _glow.withValues(alpha: 0),
          ]).createShader(
              Rect.fromCircle(center: heartsCenter, radius: 210)),
      );
      _drawHeart(canvas, const Offset(205, 225), 175, -18,
          const [_rubyLight, _rubyDeep]);
      _drawHeart(canvas, const Offset(295, 280), 210, 10,
          const [_goldLight, _gold]);
      canvas.drawCircle(
          const Offset(372, 135), 10, Paint()..color = _goldLight);

      // Текстов блок вдясно.
      _drawText(
        canvas,
        'Intima',
        const Offset(480, 130),
        const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 110,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
        ),
      );
      _drawText(
        canvas,
        'Private cycle diary.\nEncrypted. Discreet.',
        const Offset(486, 290),
        const TextStyle(
          fontFamily: 'Inter',
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: _textSecondary,
          height: 1.5,
        ),
        maxWidth: 530,
      );

      final image = await recorder
          .endRecording()
          .toImage(_w.toInt(), _h.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      Directory('assets/store').createSync(recursive: true);
      File('assets/store/feature_graphic.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    });
    expect(File('assets/store/feature_graphic.png').existsSync(), isTrue);
  });
}
