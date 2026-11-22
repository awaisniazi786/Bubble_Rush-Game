import 'package:flutter/material.dart';
import '../constants/game_colors.dart';

enum BoosterType {
  bomb,
  rainbow,
  lightning,
  fire,
  aimExtension,
  extraShots,
  colorSwap,
  slowMotion,
}

extension BoosterTypeExtension on BoosterType {
  String get title {
    switch (this) {
      case BoosterType.bomb:
        return 'Bomb';
      case BoosterType.rainbow:
        return 'Rainbow';
      case BoosterType.lightning:
        return 'Lightning';
      case BoosterType.fire:
        return 'Fire Ball';
      case BoosterType.aimExtension:
        return 'Super Aim';
      case BoosterType.extraShots:
        return '+5 Shots';
      case BoosterType.colorSwap:
        return 'Color Swap';
      case BoosterType.slowMotion:
        return 'Slow-Mo';
    }
  }

  String get description {
    switch (this) {
      case BoosterType.bomb:
        return 'Explodes all bubbles in a 3x3 radius';
      case BoosterType.rainbow:
        return 'Matches and pops any color bubble cluster';
      case BoosterType.lightning:
        return 'Clears the entire horizontal row of bubbles';
      case BoosterType.fire:
        return 'Blazes through bubbles directly to the top';
      case BoosterType.aimExtension:
        return 'Shows full trajectory bounce paths to target';
      case BoosterType.extraShots:
        return 'Adds 5 extra shots to your inventory';
      case BoosterType.colorSwap:
        return 'Changes the current shooter bubble color';
      case BoosterType.slowMotion:
        return 'Slows down bubble speed for ultimate accuracy';
    }
  }

  IconData get icon {
    switch (this) {
      case BoosterType.bomb:
        return Icons.brightness_high_rounded;
      case BoosterType.rainbow:
        return Icons.auto_awesome;
      case BoosterType.lightning:
        return Icons.bolt_rounded;
      case BoosterType.fire:
        return Icons.local_fire_department_rounded;
      case BoosterType.aimExtension:
        return Icons.gps_fixed_rounded;
      case BoosterType.extraShots:
        return Icons.add_circle_outline_rounded;
      case BoosterType.colorSwap:
        return Icons.swap_horizontal_circle_rounded;
      case BoosterType.slowMotion:
        return Icons.timer_outlined;
    }
  }

  Color get color {
    switch (this) {
      case BoosterType.bomb:
        return GameColors.bombFuse;
      case BoosterType.rainbow:
        return GameColors.neonPurple;
      case BoosterType.lightning:
        return GameColors.neonCyan;
      case BoosterType.fire:
        return GameColors.neonOrange;
      case BoosterType.aimExtension:
        return GameColors.neonGreen;
      case BoosterType.extraShots:
        return GameColors.neonGold;
      case BoosterType.colorSwap:
        return GameColors.neonBlue;
      case BoosterType.slowMotion:
        return GameColors.neonPurple;
    }
  }

  int get costInCoins {
    switch (this) {
      case BoosterType.bomb:
        return 150;
      case BoosterType.rainbow:
        return 200;
      case BoosterType.lightning:
        return 180;
      case BoosterType.fire:
        return 220;
      case BoosterType.aimExtension:
        return 100;
      case BoosterType.extraShots:
        return 120;
      case BoosterType.colorSwap:
        return 80;
      case BoosterType.slowMotion:
        return 90;
    }
  }

  int get unlockLevel {
    switch (this) {
      case BoosterType.bomb:
        return 3;
      case BoosterType.rainbow:
        return 7;
      case BoosterType.extraShots:
        return 1;
      case BoosterType.colorSwap:
        return 1;
      case BoosterType.aimExtension:
        return 5;
      case BoosterType.lightning:
        return 12;
      case BoosterType.fire:
        return 18;
      case BoosterType.slowMotion:
        return 25;
    }
  }
}
