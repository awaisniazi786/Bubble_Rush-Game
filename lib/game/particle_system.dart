import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/game_colors.dart';

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double radius;
  double opacity;
  double life;
  double maxLife;
  double gravity;
  bool isStar;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.radius,
    this.opacity = 1.0,
    required this.maxLife,
    this.gravity = 350.0,
    this.isStar = false,
  }) : life = maxLife;

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;

    velocity = Offset(velocity.dx * 0.96, velocity.dy + gravity * dt);
    position += velocity * dt;
    opacity = (life / maxLife).clamp(0.0, 1.0);
    return true;
  }
}

class FloatingText {
  Offset position;
  final String text;
  final Color color;
  double life;
  final double maxLife;
  final double fontSize;

  FloatingText({
    required this.position,
    required this.text,
    required this.color,
    this.maxLife = 1.0,
    this.fontSize = 20.0,
  }) : life = maxLife;

  bool update(double dt) {
    life -= dt;
    if (life <= 0) return false;
    position += Offset(0, -60 * dt);
    return true;
  }

  double get opacity => (life / maxLife).clamp(0.0, 1.0);
  double get scale => 1.0 + (1.0 - (life / maxLife)) * 0.3;
}

class ShockwaveRing {
  Offset center;
  double currentRadius;
  final double maxRadius;
  final Color color;
  double opacity;

  ShockwaveRing({
    required this.center,
    this.currentRadius = 10.0,
    required this.maxRadius,
    required this.color,
    this.opacity = 1.0,
  });

  bool update(double dt) {
    currentRadius += 280 * dt;
    opacity = (1.0 - (currentRadius / maxRadius)).clamp(0.0, 1.0);
    return currentRadius < maxRadius;
  }
}

class ParticleManager {
  final List<Particle> particles = [];
  final List<FloatingText> floatingTexts = [];
  final List<ShockwaveRing> shockwaves = [];
  final Random _rng = Random();

  void addPopExplosion(Offset pos, Color color, {int count = 14}) {
    for (int i = 0; i < count; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 120.0 + _rng.nextDouble() * 220.0;
      particles.add(
        Particle(
          position: pos,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: color,
          radius: 3.0 + _rng.nextDouble() * 3.5,
          maxLife: 0.4 + _rng.nextDouble() * 0.3,
          gravity: 280.0,
        ),
      );
    }
  }

  void addBombDetonation(Offset pos) {
    shockwaves.add(
      ShockwaveRing(
        center: pos,
        maxRadius: 140.0,
        color: GameColors.bombFuse,
      ),
    );

    for (int i = 0; i < 35; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 180.0 + _rng.nextDouble() * 300.0;
      final colors = [GameColors.bombFuse, GameColors.neonOrange, GameColors.neonYellow, Colors.white];
      particles.add(
        Particle(
          position: pos,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: colors[_rng.nextInt(colors.length)],
          radius: 3.5 + _rng.nextDouble() * 4.5,
          maxLife: 0.6 + _rng.nextDouble() * 0.4,
          gravity: 200.0,
        ),
      );
    }
  }

  void addLightningShockwave(Offset pos) {
    shockwaves.add(
      ShockwaveRing(
        center: pos,
        maxRadius: 180.0,
        color: GameColors.neonCyan,
      ),
    );

    for (int i = 0; i < 25; i++) {
      final angle = _rng.nextDouble() * 2 * pi;
      final speed = 200.0 + _rng.nextDouble() * 250.0;
      particles.add(
        Particle(
          position: pos,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: (_rng.nextBool()) ? GameColors.neonCyan : Colors.white,
          radius: 2.5 + _rng.nextDouble() * 3.5,
          maxLife: 0.45 + _rng.nextDouble() * 0.25,
          gravity: 100.0,
        ),
      );
    }
  }

  void addConfetti(double boardWidth) {
    final colors = [
      GameColors.neonCyan,
      GameColors.neonPink,
      GameColors.neonGold,
      GameColors.neonGreen,
      GameColors.neonPurple,
      Colors.white,
    ];
    for (int i = 0; i < 60; i++) {
      final x = _rng.nextDouble() * boardWidth;
      final y = _rng.nextDouble() * 120.0;
      final angle = _rng.nextDouble() * pi;
      final speed = 80.0 + _rng.nextDouble() * 150.0;
      particles.add(
        Particle(
          position: Offset(x, y),
          velocity: Offset(cos(angle) * speed, sin(angle) * speed + 50.0),
          color: colors[_rng.nextInt(colors.length)],
          radius: 4.0 + _rng.nextDouble() * 4.0,
          maxLife: 1.8 + _rng.nextDouble() * 1.0,
          gravity: 120.0,
          isStar: _rng.nextBool(),
        ),
      );
    }
  }

  void addFloatingText(Offset pos, String text, Color color, {double fontSize = 22.0}) {
    floatingTexts.add(
      FloatingText(
        position: pos,
        text: text,
        color: color,
        fontSize: fontSize,
        maxLife: 0.9,
      ),
    );
  }

  void update(double dt) {
    particles.removeWhere((p) => !p.update(dt));
    floatingTexts.removeWhere((t) => !t.update(dt));
    shockwaves.removeWhere((s) => !s.update(dt));
  }

  void clear() {
    particles.clear();
    floatingTexts.clear();
    shockwaves.clear();
  }
}
