import 'dart:math';
import 'package:flutter/material.dart';

class TrajectoryPainter extends CustomPainter {
  final List<Offset> path;
  final Color color;
  final double bubbleRadius;
  final Offset? targetCenter;
  final double pulse;

  TrajectoryPainter({
    required this.path,
    required this.color,
    required this.bubbleRadius,
    this.targetCenter,
    this.pulse = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35 + 0.15 * sin(pulse * pi * 2))
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Draw dotted glowing trajectory along path
    const dotSpacing = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < path.length - 1; i++) {
      final p1 = path[i];
      final p2 = path[i + 1];
      final dist = (p2 - p1).distance;
      if (dist <= 0) continue;

      final dir = (p2 - p1) / dist;
      double d = (pulse * dotSpacing) % dotSpacing;

      while (d < dist) {
        final pt = p1 + dir * d;
        final fade = (1.0 - (pt.dy / size.height)).clamp(0.2, 1.0);
        dotPaint.color = color.withValues(alpha: fade * 0.85);

        // Draw outer dot glow
        canvas.drawCircle(pt, 3.5, glowPaint);
        // Draw inner crisp dot
        canvas.drawCircle(pt, 2.0, linePaint);

        d += dotSpacing;
      }

      // Draw bounce points
      if (i < path.length - 2) {
        final bouncePaint = Paint()
          ..color = color.withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(p2, bubbleRadius * 0.5, bouncePaint);
      }
    }

    // Draw Target Reticle at target landing cell
    if (targetCenter != null) {
      final targetGlow = Paint()
        ..color = color.withValues(alpha: 0.4 + 0.2 * sin(pulse * pi * 2))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

      final targetRing = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final r = bubbleRadius * (0.85 + 0.08 * sin(pulse * pi * 2));
      canvas.drawCircle(targetCenter!, r, targetGlow);
      canvas.drawCircle(targetCenter!, r, targetRing);

      // Draw crosshair ticks
      for (int i = 0; i < 4; i++) {
        final a = i * pi / 2 + pulse * pi;
        final p1 = targetCenter! + Offset(cos(a) * (r - 4), sin(a) * (r - 4));
        final p2 = targetCenter! + Offset(cos(a) * (r + 4), sin(a) * (r + 4));
        canvas.drawLine(p1, p2, targetRing);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TrajectoryPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.color != color ||
        oldDelegate.pulse != pulse ||
        oldDelegate.targetCenter != targetCenter;
  }
}
