import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../widgets/glass_panel.dart';

class AchievementsDialog extends StatefulWidget {
  final ProgressService progressService;
  final AudioService audioService;

  const AchievementsDialog({
    super.key,
    required this.progressService,
    required this.audioService,
  });

  @override
  State<AchievementsDialog> createState() => _AchievementsDialogState();
}

class _AchievementsDialogState extends State<AchievementsDialog> {
  @override
  Widget build(BuildContext context) {
    final achievements = widget.progressService.achievements;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: GameColors.neonGold, size: 28.0),
                      SizedBox(width: 10.0),
                      Text(
                        'ACHIEVEMENTS',
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

              // Achievement List
              Expanded(
                child: ListView.separated(
                  itemCount: achievements.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final item = achievements[index];
                    return Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: item.isCompleted ? GameColors.neonCyan.withValues(alpha: 0.4) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: item.isCompleted
                                  ? GameColors.neonCyan.withValues(alpha: 0.2)
                                  : Colors.white10,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.isCompleted ? GameColors.neonCyan : Colors.white38,
                              size: 26.0,
                            ),
                          ),
                          const SizedBox(width: 14.0),

                          // Text & Progress
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    color: GameColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: LinearProgressIndicator(
                                    value: item.progressRatio,
                                    minHeight: 6.0,
                                    backgroundColor: Colors.white12,
                                    valueColor: const AlwaysStoppedAnimation<Color>(GameColors.neonCyan),
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${item.currentProgress}/${item.maxProgress}',
                                  style: const TextStyle(
                                    fontSize: 10.0,
                                    color: GameColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10.0),

                          // Claim Button or Reward Info
                          if (item.isClaimed)
                            const Icon(Icons.check_circle_rounded, color: GameColors.neonGreen, size: 24.0)
                          else if (item.isCompleted)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GameColors.neonGold,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              ),
                              onPressed: () async {
                                await widget.progressService.claimAchievement(item.id);
                                await widget.audioService.playStar();
                                setState(() {});
                              },
                              child: Text(
                                '+${item.coinReward} 🪙',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.0),
                              ),
                            )
                          else
                            Row(
                              children: [
                                const Icon(Icons.monetization_on_rounded, color: GameColors.neonGold, size: 16.0),
                                const SizedBox(width: 4.0),
                                Text(
                                  '${item.coinReward}',
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
