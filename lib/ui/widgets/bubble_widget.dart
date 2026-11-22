import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/models/bubble.dart';

class GlossyBubbleWidget extends StatelessWidget {
  final Bubble bubble;
  final double radius;

  const GlossyBubbleWidget({
    super.key,
    required this.bubble,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: BubblePainter(
        bubble: bubble,
        radius: radius,
      ),
    );
  }
}

class BubblePainter extends CustomPainter {
  final Bubble bubble;
  final double radius;

  BubblePainter({
    required this.bubble,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = radius * bubble.scale;
    if (r <= 0) return;

    final baseColor = bubble.color?.color ?? _getSpecialBaseColor(bubble.type);
    final glowColor = bubble.color?.glowColor ?? _getSpecialGlowColor(bubble.type);

    // 1. Outer Neon Glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.35 * bubble.opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4);
    canvas.drawCircle(center, r * 0.95, glowPaint);

    // 2. Base Sphere with 3D Radial Gradient
    final sphereRect = Rect.fromCircle(center: center, radius: r);
    final lightSource = Offset(center.dx - r * 0.35, center.dy - r * 0.35);

    final Paint bodyPaint;
    if (bubble.type == BubbleType.rainbow) {
      bodyPaint = Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFFF1744),
            Color(0xFFFF9100),
            Color(0xFFFFEA00),
            Color(0xFF00E676),
            Color(0xFF00E5FF),
            Color(0xFF2979FF),
            Color(0xFFAA00FF),
            Color(0xFFFF1744),
          ],
        ).createShader(sphereRect);
    } else {
      bodyPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (lightSource.dx - center.dx) / r,
            (lightSource.dy - center.dy) / r,
          ),
          radius: 1.1,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.55)!.withValues(alpha: bubble.opacity),
            baseColor.withValues(alpha: bubble.opacity),
            Color.lerp(baseColor, Colors.black, 0.45)!.withValues(alpha: bubble.opacity),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(sphereRect);
    }

    canvas.drawCircle(center, r * 0.9, bodyPaint);

    // 3. Inner Specular Glint (Top-Left Highlight)
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.85 * bubble.opacity),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(center.dx - r * 0.3, center.dy - r * 0.3),
          radius: r * 0.45,
        ),
      );

    canvas.save();
    canvas.translate(center.dx - r * 0.28, center.dy - r * 0.32);
    canvas.rotate(-pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 0.55, height: r * 0.28),
      highlightPaint,
    );
    canvas.restore();

    // 4. Subtle Bottom-Right Rim Refraction
    final rimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * bubble.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.1);

    final rimRect = Rect.fromCircle(center: center, radius: r * 0.82);
    canvas.drawArc(rimRect, pi * 0.15, pi * 0.65, false, rimPaint);

    // 5. Special Bubble Emblems
    if (bubble.type != BubbleType.normal) {
      _drawSpecialEmblem(canvas, center, r);
    }
  }

  void _drawSpecialEmblem(Canvas canvas, Offset center, double r) {
    final emblemPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95 * bubble.opacity)
      ..style = PaintingStyle.fill;

    switch (bubble.type) {
      case BubbleType.bomb:
        // Bomb fuse spark
        final sparkPaint = Paint()
          ..color = GameColors.bombFuse
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(Offset(center.dx, center.dy - r * 0.5), r * 0.2, sparkPaint);
        // Fuse line
        final linePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(center.dx, center.dy - r * 0.2),
          Offset(center.dx, center.dy - r * 0.45),
          linePaint,
        );
        break;

      case BubbleType.lightning:
        // Draw Lightning bolt
        final path = Path()
          ..moveTo(center.dx + r * 0.05, center.dy - r * 0.45)
          ..lineTo(center.dx - r * 0.3, center.dy + r * 0.05)
          ..lineTo(center.dx, center.dy + r * 0.05)
          ..lineTo(center.dx - r * 0.1, center.dy + r * 0.45)
          ..lineTo(center.dx + r * 0.35, center.dy - r * 0.05)
          ..lineTo(center.dx + r * 0.05, center.dy - r * 0.05)
          ..close();
        canvas.drawPath(path, emblemPaint);
        break;

      case BubbleType.fire:
        // Draw Flame emblem
        final path = Path()
          ..moveTo(center.dx, center.dy - r * 0.45)
          ..quadraticBezierTo(center.dx + r * 0.35, center.dy - r * 0.1, center.dx + r * 0.25, center.dy + r * 0.3)
          ..quadraticBezierTo(center.dx, center.dy + r * 0.45, center.dx - r * 0.25, center.dy + r * 0.3)
          ..quadraticBezierTo(center.dx - r * 0.35, center.dy - r * 0.1, center.dx, center.dy - r * 0.45)
          ..close();
        final flamePaint = Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFEA00), Color(0xFFFF3D00)],
          ).createShader(Rect.fromCircle(center: center, radius: r * 0.45));
        canvas.drawPath(path, flamePaint);
        break;

      case BubbleType.rainbow:
        // Draw 4-point star in center
        final starPath = Path();
        for (int i = 0; i < 4; i++) {
          final a1 = i * pi / 2;
          final a2 = a1 + pi / 4;
          final p1 = Offset(center.dx + cos(a1) * r * 0.35, center.dy + sin(a1) * r * 0.35);
          final p2 = Offset(center.dx + cos(a2) * r * 0.12, center.dy + sin(a2) * r * 0.12);
          if (i == 0) starPath.moveTo(p1.dx, p1.dy);
          starPath.lineTo(p2.dx, p2.dy);
          starPath.lineTo(p1.dx, p1.dy);
        }
        canvas.drawPath(starPath, emblemPaint);
        break;

      default:
        break;
    }
  }

  Color _getSpecialBaseColor(BubbleType type) {
    switch (type) {
      case BubbleType.bomb:
        return GameColors.bombDark;
      case BubbleType.lightning:
        return const Color(0xFF0077B6);
      case BubbleType.fire:
        return const Color(0xFFD00000);
      case BubbleType.rainbow:
        return Colors.white;
      default:
        return GameColors.bubbleCyan;
    }
  }

  Color _getSpecialGlowColor(BubbleType type) {
    switch (type) {
      case BubbleType.bomb:
        return GameColors.bombFuse;
      case BubbleType.lightning:
        return GameColors.neonCyan;
      case BubbleType.fire:
        return GameColors.neonOrange;
      case BubbleType.rainbow:
        return GameColors.neonPurple;
      default:
        return GameColors.neonCyan;
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) {
    return oldDelegate.bubble != bubble ||
        oldDelegate.radius != radius ||
        oldDelegate.bubble.scale != bubble.scale ||
        oldDelegate.bubble.opacity != bubble.opacity;
  }
}
