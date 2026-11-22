import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';
import '../widgets/star_rating_bar.dart';

class VictoryDialog extends StatelessWidget {
  final int levelNumber;
  final int score;
  final int stars;
  final int coinsEarned;
  final bool isNewHighScore;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const VictoryDialog({
    super.key,
    required this.levelNumber,
    required this.score,
    required this.stars,
    required this.coinsEarned,
    this.isNewHighScore = false,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(26.0),
        borderColor: GameColors.neonGold.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Header
            const Text(
              'VICTORY!',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w900,
                color: GameColors.neonGold,
                letterSpacing: 3.0,
                shadows: [
                  Shadow(color: GameColors.neonGold, blurRadius: 20.0),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Level $levelNumber Cleared',
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20.0),

            // Stars
            StarRatingBar(
              stars: stars,
              starSize: 48.0,
              animate: true,
            ),
            const SizedBox(height: 20.0),

            // Score Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOTAL SCORE',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: GameColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      fontSize: 34.0,
                      fontWeight: FontWeight.w900,
                      color: GameColors.neonCyan,
                      shadows: [
                        Shadow(color: GameColors.neonCyan, blurRadius: 14.0),
                      ],
                    ),
                  ),
                  if (isNewHighScore) ...[
                    const SizedBox(height: 4.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        gradient: GameColors.goldGradient,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Coins Earned
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded, color: GameColors.neonGold, size: 24.0),
                const SizedBox(width: 8.0),
                Text(
                  '+$coinsEarned Coins',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26.0),

            // Action Buttons
            if (levelNumber < 800) ...[
              NeonButton(
                text: 'NEXT LEVEL',
                icon: Icons.skip_next_rounded,
                gradient: GameColors.goldGradient,
                glowColor: GameColors.neonGold,
                onPressed: onNextLevel,
              ),
              const SizedBox(height: 12.0),
            ],
            Row(
              children: [
                Expanded(
                  child: NeonButton(
                    text: 'REPLAY',
                    icon: Icons.replay_rounded,
                    isSecondary: true,
                    fontSize: 15.0,
                    onPressed: onReplay,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: NeonButton(
                    text: 'MAP',
                    icon: Icons.map_rounded,
                    isSecondary: true,
                    fontSize: 15.0,
                    onPressed: onHome,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
