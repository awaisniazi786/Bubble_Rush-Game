import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(22.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sports_esports_rounded, color: GameColors.neonCyan, size: 26.0),
                      SizedBox(width: 10.0),
                      Text(
                        'HOW TO PLAY',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              Expanded(
                child: ListView(
                  children: [
                    _buildTutorialCard(
                      icon: Icons.touch_app_rounded,
                      color: GameColors.neonCyan,
                      title: '1. Tap to Shoot',
                      description: 'Tap a target above the launcher to fire the current bubble. You can also drag to aim, then release to shoot. Use the swap icon to exchange the current and next colors.',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTutorialCard(
                      icon: Icons.bubble_chart_rounded,
                      color: GameColors.bubblePink,
                      title: '2. Match 3 to Pop',
                      description: 'Connect 3 or more bubbles of the same color to pop them and score points! Chain consecutive pops for combo multipliers.',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTutorialCard(
                      icon: Icons.sync_alt_rounded,
                      color: GameColors.neonGold,
                      title: '3. Wall Bounces',
                      description: 'Bounce your bubbles off the side walls to reach tricky pockets and clear hidden ceiling anchors.',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTutorialCard(
                      icon: Icons.arrow_downward_rounded,
                      color: GameColors.neonPurple,
                      title: '4. Drop Disconnected Bubbles',
                      description: 'Pop the top anchors to drop disconnected bubbles. The ceiling moves down every 3 shots. Keep bubbles above the pink danger line!',
                    ),
                    const SizedBox(height: 12.0),
                    _buildTutorialCard(
                      icon: Icons.auto_awesome,
                      color: GameColors.neonGreen,
                      title: '5. Special Boosters',
                      description: 'Tap boosters at the bottom: Bomb (3x3 blast), Rainbow (matches all), Lightning (row clear), Fire (pierces all), and Super Aim.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              NeonButton(
                text: 'GOT IT, LET\'S PLAY!',
                height: 48.0,
                glowColor: GameColors.neonCyan,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: GameColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
