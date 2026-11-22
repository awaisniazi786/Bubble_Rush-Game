import 'package:flutter/material.dart';
import 'booster.dart';

class DailyRewardItem {
  final int day;
  final int coins;
  final BoosterType? booster;
  final int boosterCount;
  final String title;

  const DailyRewardItem({
    required this.day,
    required this.coins,
    this.booster,
    this.boosterCount = 0,
    required this.title,
  });

  static const List<DailyRewardItem> calendar = [
    DailyRewardItem(day: 1, coins: 100, title: '100 Coins'),
    DailyRewardItem(day: 2, coins: 50, booster: BoosterType.bomb, boosterCount: 1, title: '50 Coins + Bomb'),
    DailyRewardItem(day: 3, coins: 150, booster: BoosterType.aimExtension, boosterCount: 1, title: '150 Coins + Aim'),
    DailyRewardItem(day: 4, coins: 100, booster: BoosterType.lightning, boosterCount: 1, title: '100 Coins + Zap'),
    DailyRewardItem(day: 5, coins: 200, booster: BoosterType.fire, boosterCount: 1, title: '200 Coins + Fire'),
    DailyRewardItem(day: 6, coins: 150, booster: BoosterType.rainbow, boosterCount: 1, title: '150 Coins + Prism'),
    DailyRewardItem(day: 7, coins: 500, booster: BoosterType.rainbow, boosterCount: 2, title: 'Mega Neon Vault!'),
  ];
}

class DailyQuest {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int targetValue;
  int currentValue;
  bool isClaimed;
  final int rewardCoins;

  DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    this.currentValue = 0,
    this.isClaimed = false,
    required this.rewardCoins,
  });

  bool get isCompleted => currentValue >= targetValue;
  double get progressRatio => (currentValue / targetValue).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'currentValue': currentValue,
    'isClaimed': isClaimed,
  };
}
