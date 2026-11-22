import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../widgets/glass_panel.dart';
import '../widgets/neon_button.dart';
import 'how_to_play_dialog.dart';

class SettingsDialog extends StatefulWidget {
  final AudioService audioService;
  final ProgressService progressService;

  const SettingsDialog({
    super.key,
    required this.audioService,
    required this.progressService,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  @override
  Widget build(BuildContext context) {
    final audio = widget.audioService;
    final progress = widget.progressService;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: GlassPanel(
        padding: const EdgeInsets.all(22.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings_rounded, color: GameColors.neonCyan, size: 26.0),
                      SizedBox(width: 10.0),
                      Text(
                        'SETTINGS',
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
              const SizedBox(height: 20.0),

              // Music Volume
              _buildSliderRow(
                icon: audio.isMusicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                title: 'Music Volume',
                value: audio.isMusicEnabled ? audio.musicVolume : 0.0,
                onChanged: (val) async {
                  await audio.setMusicVolume(val);
                  setState(() {});
                },
                onToggle: () async {
                  await audio.toggleMusic();
                  setState(() {});
                },
              ),
              const SizedBox(height: 16.0),

              // SFX Volume
              _buildSliderRow(
                icon: audio.isSfxEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                title: 'Sound FX',
                value: audio.isSfxEnabled ? audio.sfxVolume : 0.0,
                onChanged: (val) async {
                  await audio.setSfxVolume(val);
                  setState(() {});
                },
                onToggle: () async {
                  await audio.toggleSfx();
                  setState(() {});
                },
              ),
              const SizedBox(height: 20.0),

              // Toggles
              _buildSwitchRow(
                icon: Icons.vibration_rounded,
                title: 'Vibration Haptics',
                value: progress.vibrationEnabled,
                onChanged: (_) async {
                  await progress.toggleVibration();
                  setState(() {});
                },
              ),
              const SizedBox(height: 12.0),
              _buildSwitchRow(
                icon: Icons.animation_rounded,
                title: 'Reduced Motion',
                value: progress.reducedMotion,
                onChanged: (_) async {
                  await progress.toggleReducedMotion();
                  setState(() {});
                },
              ),
              const SizedBox(height: 24.0),

              // How To Play
              NeonButton(
                text: 'HOW TO PLAY',
                icon: Icons.help_outline_rounded,
                isSecondary: true,
                height: 48.0,
                fontSize: 15.0,
                glowColor: GameColors.neonCyan,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const HowToPlayDialog(),
                  );
                },
              ),
              const SizedBox(height: 12.0),

              // Reset Progress
              NeonButton(
                text: 'RESET PROGRESS',
                icon: Icons.delete_forever_rounded,
                isSecondary: true,
                height: 48.0,
                fontSize: 15.0,
                glowColor: GameColors.neonPink,
                onPressed: () => _confirmReset(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(icon, color: GameColors.neonCyan, size: 22.0),
                  onPressed: onToggle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14.0),
                ),
              ],
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(color: GameColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13.0),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: GameColors.neonCyan,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            overlayColor: GameColors.neonCyan.withValues(alpha: 0.2),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: GameColors.neonPurple, size: 20.0),
              const SizedBox(width: 10.0),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14.0),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: GameColors.neonCyan,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140D2B),
        title: const Text('Reset All Progress?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently reset your unlocked levels, high scores, coins, and boosters. Are you sure?',
          style: TextStyle(color: GameColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('RESET ALL', style: TextStyle(color: GameColors.neonPink, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await widget.progressService.resetAllData();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
