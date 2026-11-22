import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';

class StarRatingBar extends StatelessWidget {
  final int stars;
  final double starSize;
  final bool animate;

  const StarRatingBar({
    super.key,
    required this.stars,
    this.starSize = 36.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final earned = index < stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            earned ? Icons.star_rounded : Icons.star_border_rounded,
            size: index == 1 ? starSize * 1.25 : starSize,
            color: earned ? GameColors.neonGold : Colors.white24,
            shadows: earned
                ? [
                    Shadow(
                      color: GameColors.neonGold.withValues(alpha: 0.8),
                      blurRadius: 16.0,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
