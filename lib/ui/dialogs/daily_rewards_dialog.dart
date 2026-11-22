import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/models/daily_reward.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';

class DailyRewardsDialog extends StatefulWidget {
  final ProgressService progressService;
  final AudioService audioService;

  const DailyRewardsDialog({
    super.key,
    required this.progressService,
    required this.audioService,
  });

  @override
  State<DailyRewardsDialog> createState() => _DailyRewardsDialogState();
}

class _DailyRewardsDialogState extends State<DailyRewardsDialog> {
  bool _claimedInSession = false;

  @override
  Widget build(BuildContext context) {
    final ps = widget.progressService;
    final canClaim = ps.canClaimDailyReward && !_claimedInSession;
    final currentDayIdx = ps.nextRewardDayIndex;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: GameColors.neonCyan, size: 24.0),
                    SizedBox(width: 10.0),
                    Text(
                      'DAILY REWARDS',
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

            // 7-day grid
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              alignment: WrapAlignment.center,
              children: List.generate(7, (index) {
                final item = DailyRewardItem.calendar[index];
                final isCurrent = index == currentDayIdx;
                final isPassed = index < currentDayIdx || (!canClaim && isCurrent);
                final isSpecialDay7 = index == 6;

                return Container(
                  width: isSpecialDay7 ? 260.0 : 76.0,
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6.0),
                  decoration: BoxDecoration(
                    color: isCurrent && canClaim
                        ? GameColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: isCurrent && canClaim
                          ? GameColors.neonCyan
                          : (isSpecialDay7 ? GameColors.neonGold : Colors.white12),
                      width: isCurrent && canClaim ? 2.0 : 1.0,
                    ),
                    boxShadow: isCurrent && canClaim
                        ? [
                            BoxShadow(
                              color: GameColors.neonCyan.withValues(alpha: 0.3),
                              blurRadius: 10.0,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Day ${item.day}',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w800,
                          color: isCurrent ? GameColors.neonCyan : GameColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Icon(
                        isSpecialDay7
                            ? Icons.card_giftcard_rounded
                            : (item.booster != null
                                ? Icons.auto_awesome
                                : Icons.monetization_on_rounded),
                        color: isSpecialDay7
                            ? GameColors.neonGold
                            : (item.booster != null ? GameColors.neonPurple : GameColors.neonGold),
                        size: 26.0,
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        isSpecialDay7 ? 'MEGA VAULT' : '+${item.coins}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      if (isPassed) ...[
                        const SizedBox(height: 4.0),
                        const Icon(Icons.check_circle_rounded, color: GameColors.neonGreen, size: 14.0),
                      ],
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 24.0),

            // Claim Button
            NeonButton(
              text: canClaim ? 'CLAIM TODAY\'S REWARD!' : 'ALREADY CLAIMED TODAY',
              icon: Icons.check_circle_outline_rounded,
              gradient: canClaim ? GameColors.goldGradient : null,
              glowColor: GameColors.neonGold,
              onPressed: canClaim
                  ? () async {
                      await widget.progressService.claimDailyReward();
                      await widget.audioService.playStar();
                      setState(() {
                        _claimedInSession = true;
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Reward Claimed Successfully!'),
                            backgroundColor: GameColors.neonPurple,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
