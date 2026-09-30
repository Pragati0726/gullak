import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gullak/utils/constants.dart';

class GullakWidget extends StatelessWidget {
  final bool glow;
  const GullakWidget({super.key, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 260,
      child: CustomPaint(
        painter: _MatkaPainter(glow: glow),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MatkaPainter extends CustomPainter {
  final bool glow;
  _MatkaPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // ground shadow
    final shadowPaint = Paint()..color = Colors.black.withAlpha(28);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h - 4), width: w * 0.62, height: 14),
      shadowPaint,
    );

    // ── body path: round pot narrowing to a neck near the top ──
    final bodyTop = h * 0.30; // where the neck starts
    final bodyBottom = h * 0.94;
    final bellyY = h * 0.62;
    final bellyR = w * 0.46;
    final footY = h * 0.96;
    final footR = w * 0.13;
    final neckTopY = h * 0.16;
    final neckR = w * 0.10;

    final body = Path()
      ..moveTo(cx - neckR, neckTopY)
      ..cubicTo(
        cx - neckR - 6, neckTopY + 14,
        cx - bellyR * 0.55, bodyTop,
        cx - bellyR, bellyY,
      )
      ..cubicTo(
        cx - bellyR, bellyY + (bodyBottom - bellyY) * 0.55,
        cx - footR - 14, bodyBottom - 8,
        cx - footR, footY,
      )
      ..lineTo(cx + footR, footY)
      ..cubicTo(
        cx + footR + 14, bodyBottom - 8,
        cx + bellyR, bellyY + (bodyBottom - bellyY) * 0.55,
        cx + bellyR, bellyY,
      )
      ..cubicTo(
        cx + bellyR * 0.55, bodyTop,
        cx + neckR + 6, neckTopY + 14,
        cx + neckR, neckTopY,
      )
      ..close();

    final bodyShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [
        Color(0xFFD79A66),
        Color(0xFFC17A45),
        Color(0xFFA85F32),
      ],
      stops: const [0.0, 0.55, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawShadow(body, Colors.black.withAlpha(60), 6, false);
    if (glow) {
      canvas.drawPath(
        body,
        Paint()
          ..color = AppColors.glow
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 18),
      );
    }
    canvas.drawPath(body, Paint()..shader = bodyShader);

    // subtle inner rim shading near the neck base
    final rimShadow = Paint()
      ..color = const Color(0xFF8A4A28).withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(body, rimShadow);

    // ── pointed conical knob on top ──
    final knobBaseY = neckTopY + 6;
    final knobPath = Path()
      ..moveTo(cx - neckR - 2, knobBaseY)
      ..quadraticBezierTo(cx - neckR - 8, knobBaseY - 10, cx - 10, h * 0.06)
      ..quadraticBezierTo(cx - 4, h * 0.0, cx, h * -0.01)
      ..quadraticBezierTo(cx + 4, h * 0.0, cx + 10, h * 0.06)
      ..quadraticBezierTo(cx + neckR + 8, knobBaseY - 10, cx + neckR + 2, knobBaseY)
      ..close();
    canvas.drawPath(
      knobPath,
      Paint()..shader = bodyShader,
    );
    // ribbed collar under the knob
    final collarPaint = Paint()
      ..color = const Color(0xFF8A4A28).withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (double t = -1; t <= 1; t += 0.22) {
      final x = cx + t * (neckR + 4);
      canvas.drawLine(
        Offset(x, knobBaseY - 2),
        Offset(x * 0.4 + cx * 0.6, knobBaseY + 10),
        collarPaint,
      );
    }

    // ── coin slot: angled slit near the top of the belly ──
    final slotY = bodyTop + 14;
    final slotPaint = Paint()..color = Colors.black87;
    final slot = Path()
      ..moveTo(cx - 34, slotY + 6)
      ..quadraticBezierTo(cx, slotY - 4, cx + 34, slotY - 8)
      ..lineTo(cx + 32, slotY - 2)
      ..quadraticBezierTo(cx, slotY + 2, cx - 32, slotY + 12)
      ..close();
    canvas.drawPath(slot, slotPaint);

    // ── etched dash-band around the widest point ──
    final dashPaint = Paint()
      ..color = const Color(0xFF8A4A28).withAlpha(150)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    const dashCount = 26;
    for (int i = 0; i < dashCount; i++) {
      final t = i / (dashCount - 1);
      final angle = math.pi * (0.08 + t * 0.84); // spread across visible belly
      final x = cx - bellyR * 0.92 * math.cos(angle);
      final y = bellyY + 6 + math.sin(angle * 0.3) * 4;
      canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), dashPaint);
    }

    // second thinner dash band lower down
    final dashPaint2 = Paint()
      ..color = const Color(0xFF8A4A28).withAlpha(90)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const dashCount2 = 30;
    final band2Y = bellyY + (bodyBottom - bellyY) * 0.38;
    final band2R = bellyR * 0.86;
    for (int i = 0; i < dashCount2; i++) {
      final t = i / (dashCount2 - 1);
      final angle = math.pi * (0.06 + t * 0.88);
      final x = cx - band2R * math.cos(angle);
      canvas.drawLine(Offset(x, band2Y - 4), Offset(x, band2Y + 4), dashPaint2);
    }

    // soft highlight streak (kiln sheen)
    final highlight = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withAlpha(70), Colors.white.withAlpha(0)],
      ).createShader(
          Rect.fromLTWH(cx - bellyR * 0.7, bodyTop, bellyR * 0.5, bodyBottom - bodyTop));
    canvas.save();
    canvas.clipPath(body);
    canvas.drawRect(
        Rect.fromLTWH(cx - bellyR * 0.7, bodyTop, bellyR * 0.5, bodyBottom - bodyTop),
        highlight);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MatkaPainter oldDelegate) =>
      oldDelegate.glow != glow;
}