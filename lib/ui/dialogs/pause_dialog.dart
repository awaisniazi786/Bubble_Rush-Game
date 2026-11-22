import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/services/audio_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';

class PauseDialog extends StatelessWidget {
  final int levelNumber;
  final int currentScore;
  final AudioService audioService;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseDialog({
    super.key,
    required this.levelNumber,
    required this.currentScore,
    required this.audioService,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'GAME PAUSED',
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.w900,
                color: GameColors.neonCyan,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(color: GameColors.neonCyan, blurRadius: 16.0),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Level $levelNumber • Score: $currentScore',
              style: const TextStyle(
                color: GameColors.textSecondary,
                fontSize: 15.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24.0),

            // Sound Quick Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildQuickToggle(
                  icon: audioService.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                  label: 'Music',
                  isActive: audioService.isMusicEnabled,
                  onTap: () async {
                    await audioService.toggleMusic();
                    (context as Element).markNeedsBuild();
                  },
                ),
                const SizedBox(width: 24.0),
                _buildQuickToggle(
                  icon: audioService.isSfxEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  label: 'Sound',
                  isActive: audioService.isSfxEnabled,
                  onTap: () async {
                    await audioService.toggleSfx();
                    (context as Element).markNeedsBuild();
                  },
                ),
              ],
            ),
            const SizedBox(height: 28.0),

            // Resume Button
            NeonButton(
              text: 'RESUME',
              icon: Icons.play_arrow_rounded,
              glowColor: GameColors.neonCyan,
              onPressed: onResume,
            ),
            const SizedBox(height: 12.0),

            // Restart Button
            NeonButton(
              text: 'RESTART',
              icon: Icons.replay_rounded,
              isSecondary: true,
              glowColor: GameColors.neonOrange,
              onPressed: onRestart,
            ),
            const SizedBox(height: 12.0),

            // Quit / Level Select
            NeonButton(
              text: 'EXIT TO MAP',
              icon: Icons.map_rounded,
              isSecondary: true,
              glowColor: Colors.white38,
              onPressed: onQuit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isActive ? GameColors.neonPurple.withValues(alpha: 0.25) : Colors.white10,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isActive ? GameColors.neonPurple : Colors.white24,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? GameColors.neonCyan : Colors.white54,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontWeight: FontWeight.w700,
                fontSize: 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
