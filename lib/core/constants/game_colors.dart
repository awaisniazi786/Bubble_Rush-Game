import 'package:flutter/material.dart';

class GameColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF090B1A);
  static const Color backgroundSecondary = Color(0xFF120826);
  static const Color backgroundTertiary = Color(0xFF1E1038);
  static const Color panelGlass = Color(0xCC160F30);
  static const Color panelGlassLight = Color(0x26FFFFFF);
  static const Color panelBorder = Color(0x4000F2FE);

  // Neon Accents
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonBlue = Color(0xFF4FACFE);
  static const Color neonPurple = Color(0xFFB000FF);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonGreen = Color(0xFF00FFA3);
  static const Color neonOrange = Color(0xFFFF6D00);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color neonGold = Color(0xFFFFB300);

  // Bubble Colors
  static const Color bubbleCyan = Color(0xFF00E5FF);
  static const Color bubblePink = Color(0xFFFF1493);
  static const Color bubbleGold = Color(0xFFFFD700);
  static const Color bubbleGreen = Color(0xFF00E676);
  static const Color bubblePurple = Color(0xFFAA00FF);
  static const Color bubbleOrange = Color(0xFFFF6F00);
  static const Color bubbleBlue = Color(0xFF2979FF);

  // Special Bubble Colors
  static const Color bombDark = Color(0xFF1A1A24);
  static const Color bombFuse = Color(0xFFFF3D00);
  static const Color fireCore = Color(0xFFFFEA00);
  static const Color fireGlow = Color(0xFFFF3D00);
  static const Color lightningCore = Color(0xFFFFFFFF);
  static const Color lightningGlow = Color(0xFF00E5FF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3C5EA);
  static const Color textMuted = Color(0xFF6B7A99);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF070914),
      Color(0xFF0E0B24),
      Color(0xFF160A30),
      Color(0xFF0A0818),
    ],
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    colors: [Color(0xFF00F2FE), Color(0xFF4FACFE), Color(0xFFB000FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF007F), Color(0xFFFF4081), Color(0xFFB000FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rainbowGradient = LinearGradient(
    colors: [
      Color(0xFFFF1744),
      Color(0xFFFF9100),
      Color(0xFFFFEA00),
      Color(0xFF00E676),
      Color(0xFF00E5FF),
      Color(0xFF2979FF),
      Color(0xFFAA00FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
