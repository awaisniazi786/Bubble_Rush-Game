import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';

class GameOverDialog extends StatelessWidget {
  final bool dangerReached;
  final int levelNumber;
  final int currentScore;
  final int targetScore;
  final int remainingBubbles;
  final int playerCoins;
  final VoidCallback onBuyExtraShots;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  const GameOverDialog({
    super.key,
    this.dangerReached = false,
    required this.levelNumber,
    required this.currentScore,
    required this.targetScore,
    required this.remainingBubbles,
    required this.playerCoins,
    required this.onBuyExtraShots,
    required this.onRetry,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    const extraShotsCost = 100;
    final canAffordShots = playerCoins >= extraShotsCost;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(26.0),
        borderColor: GameColors.neonPink.withValues(alpha: 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              dangerReached ? 'DANGER LINE!' : 'OUT OF SHOTS!',
              style: const TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w900,
                color: GameColors.neonPink,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: GameColors.neonPink, blurRadius: 18.0),
                ],
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              'Level $levelNumber • $remainingBubbles bubbles left',
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20.0),

            // Score Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'FINAL SCORE',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: GameColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        currentScore.toString(),
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 32.0, width: 1.0, color: Colors.white24),
                  Column(
                    children: [
                      const Text(
                        'TARGET',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: GameColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        targetScore.toString(),
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: GameColors.neonGold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22.0),

            // Continue only when the board has not reached the danger line.
            if (!dangerReached) NeonButton(
              text: '+5 SHOTS ($extraShotsCost Coins)',
              icon: Icons.add_circle_outline_rounded,
              gradient: canAffordShots ? GameColors.goldGradient : null,
              glowColor: GameColors.neonGold,
              onPressed: canAffordShots ? onBuyExtraShots : null,
            ),
            const SizedBox(height: 12.0),

            // Retry Button
            NeonButton(
              text: 'RETRY LEVEL',
              icon: Icons.replay_rounded,
              glowColor: GameColors.neonCyan,
              onPressed: onRetry,
            ),
            const SizedBox(height: 12.0),

            // Exit Button
            NeonButton(
              text: 'EXIT TO MAP',
              icon: Icons.map_rounded,
              isSecondary: true,
              fontSize: 15.0,
              onPressed: onQuit,
            ),
          ],
        ),
      ),
    );
  }
}
