import 'dart:math';
import 'package:flutter/material.dart';
import '../../game/particle_system.dart';

class ParticlePainter extends CustomPainter {
  final ParticleManager particleManager;
  final double animationValue;

  ParticlePainter({
    required this.particleManager,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Shockwave Rings
    for (final sw in particleManager.shockwaves) {
      final ringPaint = Paint()
        ..color = sw.color.withValues(alpha: sw.opacity * 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 * sw.opacity
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(sw.center, sw.currentRadius, ringPaint);
    }

    // 2. Draw Particles
    for (final p in particleManager.particles) {
      if (p.isStar) {
        _drawStar(canvas, p.position, p.radius, p.color.withValues(alpha: p.opacity));
      } else {
        final particlePaint = Paint()
          ..color = p.color.withValues(alpha: p.opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.position, p.radius, particlePaint);

        // Particle glow
        final glowPaint = Paint()
          ..color = p.color.withValues(alpha: p.opacity * 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.6);
        canvas.drawCircle(p.position, p.radius * 1.3, glowPaint);
      }
    }

    // 3. Draw Floating Texts
    for (final ft in particleManager.floatingTexts) {
      final textSpan = TextSpan(
        text: ft.text,
        style: TextStyle(
          fontSize: ft.fontSize * ft.scale,
          fontWeight: FontWeight.w900,
          color: ft.color.withValues(alpha: ft.opacity),
          shadows: [
            Shadow(
              color: ft.color.withValues(alpha: ft.opacity * 0.8),
              blurRadius: 10.0,
            ),
            Shadow(
              color: Colors.black.withValues(alpha: ft.opacity * 0.9),
              blurRadius: 4.0,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        ft.position.dx - textPainter.width / 2,
        ft.position.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = i * 4 * pi / 5 - pi / 2;
      final pt = Offset(center.dx + cos(a1) * r, center.dy + sin(a1) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
