import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../widgets/glass_panel.dart';

class DailyQuestsDialog extends StatefulWidget {
  final ProgressService progressService;
  final AudioService audioService;

  const DailyQuestsDialog({
    super.key,
    required this.progressService,
    required this.audioService,
  });

  @override
  State<DailyQuestsDialog> createState() => _DailyQuestsDialogState();
}

class _DailyQuestsDialogState extends State<DailyQuestsDialog> {
  @override
  Widget build(BuildContext context) {
    final quests = widget.progressService.dailyQuests;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.flag_rounded, color: GameColors.neonCyan, size: 26.0),
                    SizedBox(width: 10.0),
                    Text(
                      'DAILY MISSIONS',
                      style: TextStyle(
                        fontSize: 20.0,
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

            // Quests List
            ...quests.map((quest) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: quest.isCompleted ? GameColors.neonGreen.withValues(alpha: 0.4) : Colors.white12,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(quest.icon, color: GameColors.neonPurple, size: 28.0),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 15.0),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            quest.description,
                            style: const TextStyle(fontSize: 12.0, color: GameColors.textSecondary),
                          ),
                          const SizedBox(height: 6.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3.0),
                            child: LinearProgressIndicator(
                              value: quest.progressRatio,
                              minHeight: 5.0,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(GameColors.neonGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    if (quest.isClaimed)
                      const Icon(Icons.check_circle_rounded, color: GameColors.neonGreen, size: 24.0)
                    else if (quest.isCompleted)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.neonGreen,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        ),
                        onPressed: () async {
                          await widget.progressService.claimDailyQuest(quest.id);
                          await widget.audioService.playStar();
                          setState(() {});
                        },
                        child: Text('+${quest.rewardCoins} 🪙', style: const TextStyle(fontWeight: FontWeight.w900)),
                      )
                    else
                      Text(
                        '${quest.currentValue}/${quest.targetValue}',
                        style: const TextStyle(color: Colors.white60, fontWeight: FontWeight.w700, fontSize: 12.0),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
