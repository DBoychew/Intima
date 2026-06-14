import 'package:flutter/material.dart';

/// Оригинална, генерирана във вектор илюстрация за поза — абстрактни
/// преплетени силуети (без анатомия, wellness тон). Чисто откъм права:
/// рисува се изцяло в код, нищо не се сваля. Детерминирана за дадена
/// поза (един и същ seed → един и същ образ).
class PoseArt extends StatelessWidget {
  const PoseArt({
    super.key,
    required this.color,
    required this.seed,
    this.borderRadius = 18,
  });

  final Color color;
  final int seed;
  final double borderRadius;

  /// Стабилен seed от id-то на позата (не зависи от hashCode).
  static int seedOf(String id) =>
      id.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0x7fffffff);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _PoseArtPainter(color: color, seed: seed),
        size: Size.infinite,
      ),
    );
  }
}

/// Малък детерминиран PRNG (LCG) — за повторяеми вариации без Random.
class _Lcg {
  _Lcg(this._state);
  int _state;
  double next() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state / 0x7fffffff;
  }

  double range(double a, double b) => a + (b - a) * next();
}

class _PoseArtPainter extends CustomPainter {
  _PoseArtPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hsl = HSLColor.fromColor(color);
    final dark = hsl
        .withLightness((hsl.lightness * 0.55).clamp(0.0, 1.0))
        .toColor();
    final light = hsl
        .withLightness((hsl.lightness * 1.15).clamp(0.0, 1.0))
        .withSaturation((hsl.saturation * 0.9).clamp(0.0, 1.0))
        .toColor();

    // Фон — мек диагонален градиент.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ).createShader(rect),
    );

    final rnd = _Lcg(seed);
    final w = size.width, h = size.height;

    // Мек светъл ореол някъде горе.
    canvas.drawCircle(
      Offset(w * rnd.range(0.25, 0.75), h * rnd.range(0.18, 0.38)),
      w * rnd.range(0.28, 0.42),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    // Две преплетени „ленти" — абстрактни фигури, спускащи се отдолу.
    for (var i = 0; i < 2; i++) {
      final baseX = w * (i == 0 ? rnd.range(0.30, 0.42) : rnd.range(0.58, 0.70));
      final sway = w * rnd.range(0.12, 0.22);
      final dir = i == 0 ? 1.0 : -1.0;
      final path = Path()..moveTo(baseX, h * 1.05);
      path.cubicTo(
        baseX + dir * sway, h * rnd.range(0.70, 0.82),
        baseX - dir * sway, h * rnd.range(0.45, 0.58),
        baseX + dir * sway * rnd.range(0.3, 0.7), h * rnd.range(0.20, 0.34),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = w * rnd.range(0.10, 0.16)
          ..color = Colors.white.withValues(alpha: i == 0 ? 0.30 : 0.20),
      );
      // „Глава" — малък кръг в горния край на лентата.
      final hx = baseX + dir * sway * 0.4;
      final hy = h * rnd.range(0.18, 0.30);
      canvas.drawCircle(
        Offset(hx, hy),
        w * rnd.range(0.07, 0.10),
        Paint()..color = Colors.white.withValues(alpha: i == 0 ? 0.34 : 0.24),
      );
    }

    // Дискретен акцент — сърце/точка от златистото усещане.
    final ax = w * rnd.range(0.4, 0.6);
    final ay = h * rnd.range(0.5, 0.66);
    _drawHeart(canvas, Offset(ax, ay), w * 0.07,
        Colors.white.withValues(alpha: 0.5));
  }

  void _drawHeart(Canvas canvas, Offset c, double s, Color color) {
    final p = Path();
    p.moveTo(c.dx, c.dy + s * 0.3);
    p.cubicTo(c.dx - s, c.dy - s * 0.6, c.dx - s * 0.5, c.dy - s,
        c.dx, c.dy - s * 0.3);
    p.cubicTo(c.dx + s * 0.5, c.dy - s, c.dx + s, c.dy - s * 0.6,
        c.dx, c.dy + s * 0.3);
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PoseArtPainter old) =>
      old.seed != seed || old.color != color;
}
