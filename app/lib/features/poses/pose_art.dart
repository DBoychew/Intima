import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'pose_assets.dart';

/// Илюстрация за поза. Ако има вградена CC0 SVG (`assets/poses/<id>.svg`)
/// — показва нея (бяла, върху брандирания градиент). Ако липсва — пада
/// към генериран във вектор силует на двойка (fallback, чист откъм права).
class PoseArt extends StatelessWidget {
  const PoseArt({
    super.key,
    required this.color,
    required this.id,
    this.borderRadius = 18,
  });

  final Color color;
  final String id;
  final double borderRadius;

  /// Стабилен seed от id-то на позата (не зависи от hashCode).
  static int seedOf(String id) =>
      id.codeUnits.fold(7, (a, c) => (a * 31 + c) & 0x7fffffff);

  @override
  Widget build(BuildContext context) {
    final seed = seedOf(id);
    final hasSvg = poseSvgAvailable(id);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Брандиран фон — градиент + bokeh + прожектор.
          CustomPaint(painter: _PoseBackgroundPainter(color: color, seed: seed)),
          // Реалната CC0 илюстрация или генерираният силует.
          if (hasSvg)
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.66,
                heightFactor: 0.66,
                child: SvgPicture.asset(
                  'assets/poses/$id.svg',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withValues(alpha: 0.92), BlendMode.srcIn),
                ),
              ),
            )
          else
            CustomPaint(painter: _PoseFigurePainter(seed: seed)),
          // Долна винетка — за контраст на текста.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x47000000)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Малък детерминиран PRNG (LCG) — повторяеми вариации без Random.
class _Lcg {
  _Lcg(this._state);
  int _state;
  double next() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state / 0x7fffffff;
  }

  double range(double a, double b) => a + (b - a) * next();
  int pick(int n) => (next() * n).floor().clamp(0, n - 1);
}

/// Брандираният фон — хармоничен градиент, мек bokeh и прожектор.
class _PoseBackgroundPainter extends CustomPainter {
  _PoseBackgroundPainter({required this.color, required this.seed});

  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final base = HSLColor.fromColor(color);

    HSLColor shift(double dh, double dl, [double ds = 0]) => HSLColor.fromAHSL(
          1,
          (base.hue + dh) % 360,
          (base.saturation + ds).clamp(0.0, 1.0),
          (base.lightness + dl).clamp(0.0, 1.0),
        );

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            shift(18, 0.16, -0.05).toColor(),
            shift(-12, -0.20).toColor(),
          ],
        ).createShader(rect),
    );

    final rnd = _Lcg(seed);
    final w = size.width, h = size.height;

    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(w * rnd.range(0.05, 0.95), h * rnd.range(0.05, 0.7)),
        w * rnd.range(0.18, 0.5),
        Paint()
          ..color = Colors.white.withValues(alpha: rnd.range(0.04, 0.09))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.62),
      w * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(
            center: Offset(w * 0.5, h * 0.62), radius: w * 0.5)),
    );
  }

  @override
  bool shouldRepaint(_PoseBackgroundPainter old) =>
      old.seed != seed || old.color != color;
}

/// Генериран силует на двойка в прегръдка (fallback, когато няма SVG).
class _PoseFigurePainter extends CustomPainter {
  _PoseFigurePainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = _Lcg(seed);
    _drawCouple(canvas, size, rnd);
  }

  void _drawCouple(Canvas canvas, Size size, _Lcg rnd) {
    final w = size.width, h = size.height;
    final composition = rnd.pick(4);

    // spread = разтвор на краката; lean = колко горната част отива към
    // центъра (прегръдка); dyBack/scaleBack = втората фигура.
    late double spread, lean, dyBack, scaleBack;
    switch (composition) {
      case 0: // лице в лице, равни
        spread = w * 0.15; lean = 0.62; dyBack = 0; scaleBack = 0.97;
      case 1: // близка прегръдка
        spread = w * 0.12; lean = 0.78; dyBack = -h * 0.03; scaleBack = 0.94;
      case 2: // единият по-високо (отгоре/седнал)
        spread = w * 0.14; lean = 0.5; dyBack = -h * 0.15; scaleBack = 0.84;
      default: // спокойна, рамо до рамо
        spread = w * 0.17; lean = 0.45; dyBack = 0; scaleBack = 1.03;
    }

    final cx = w * 0.5;
    final groundY = h * 0.95;
    final figH = h * rnd.range(0.6, 0.67);
    final figW = w * 0.2;

    // Сянка на земята под двойката.
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, groundY + h * 0.02),
          width: w * 0.66,
          height: h * 0.06),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    final back = _figure(
      bottomX: cx + spread,
      topX: cx + spread * (1 - lean),
      bottomY: groundY + dyBack,
      height: figH * scaleBack,
      width: figW * scaleBack,
    );
    final front = _figure(
      bottomX: cx - spread,
      topX: cx - spread * (1 - lean),
      bottomY: groundY,
      height: figH,
      width: figW,
    );

    // Задна фигура — по-тъмна за дълбочина.
    canvas.drawPath(
        back, Paint()..color = Colors.white.withValues(alpha: 0.34));

    // Сянка на предната върху задната + самата предна (почти бяла).
    canvas.drawPath(
        front.shift(Offset(w * 0.012, h * 0.012)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.16)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));
    canvas.drawPath(
        front, Paint()..color = Colors.white.withValues(alpha: 0.92));
  }

  /// Силует на човек, навеждащ се: горната част е центрирана около
  /// [topX], долната около [bottomX] (затова фигурата „ляга" към партньора).
  Path _figure({
    required double topX,
    required double bottomX,
    required double bottomY,
    required double height,
    required double width,
  }) {
    final headR = height * 0.15;
    final headC = Offset(topX, bottomY - height + headR);
    final shoulderY = headC.dy + headR * 1.05;
    final topW = width * 0.55;
    final botW = width;

    final p = Path()..addOval(Rect.fromCircle(center: headC, radius: headR));
    // Десен контур: рамо (горе при topX) → ханш/крак (долу при bottomX).
    p.moveTo(topX + topW, shoulderY);
    p.cubicTo(
      topX + topW, shoulderY + height * 0.25,
      bottomX + botW, bottomY - height * 0.22,
      bottomX + botW * 0.55, bottomY,
    );
    // Долен ръб.
    p.quadraticBezierTo(
        bottomX, bottomY + height * 0.03, bottomX - botW * 0.55, bottomY);
    // Ляв контур обратно нагоре до другото рамо.
    p.cubicTo(
      bottomX - botW, bottomY - height * 0.22,
      topX - topW, shoulderY + height * 0.25,
      topX - topW, shoulderY,
    );
    p.close();
    return p;
  }

  @override
  bool shouldRepaint(_PoseFigurePainter old) => old.seed != seed;
}
