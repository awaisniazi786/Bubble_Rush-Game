import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int maxProgress;
  int currentProgress;
  bool isClaimed;
  final int coinReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.maxProgress,
    this.currentProgress = 0,
    this.isClaimed = false,
    required this.coinReward,
  });

  bool get isCompleted => currentProgress >= maxProgress;
  double get progressRatio => (currentProgress / maxProgress).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'currentProgress': currentProgress,
    'isClaimed': isClaimed,
  };
}
