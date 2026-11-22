import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/generators/level_generator.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../dialogs/achievements_dialog.dart';
import '../dialogs/daily_quests_dialog.dart';
import '../dialogs/daily_rewards_dialog.dart';
import '../dialogs/settings_dialog.dart';
import 'gameplay_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudioService audioService;
  final ProgressService progressService;
  const HomeScreen({super.key, required this.audioService, required this.progressService});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _world;
  late final ScrollController _scroll;
  @override
  void initState() {
    super.initState();
    _world = (widget.progressService.unlockedLevel - 1) ~/ 50;
    _scroll = ScrollController(initialScrollOffset: ((widget.progressService.unlockedLevel - 1) % 50 * 106.0 - 100).clamp(0.0, 5000.0));
    widget.audioService.playMenuMusic();
  }
  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  void _play(int level) {
    if (!widget.progressService.isLevelUnlocked(level)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complete Level ${level - 1} to unlock this stage.'), duration: const Duration(seconds: 2)));
      return;
    }
    widget.audioService.playClick();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GameplayScreen(levelData: LevelGenerator.generate(level), audioService: widget.audioService, progressService: widget.progressService)));
  }
  void _dialog(Widget child) {
    widget.audioService.playClick();
    showDialog<void>(context: context, builder: (_) => child);
  }
  void _changeWorld(int delta) {
    if (_world + delta < 0 || _world + delta >= 16) return;
    setState(() => _world += delta);
    _scroll.jumpTo(0);
  }
  @override
  Widget build(BuildContext context) {
    final ps = widget.progressService;
    return AnimatedBuilder(animation: ps, builder: (context, _) => Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF191744), Color(0xFF080E24), Color(0xFF24204D)])),
        child: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 10, 10, 4), child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/images/bubble_rush_icon.png', width: 44, height: 44)),
            const SizedBox(width: 10),
            const Expanded(child: Text('BUBBLE RUSH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 19, letterSpacing: 1))),
            _stat(Icons.monetization_on_rounded, '${ps.coins}', const Color(0xFFFFCF60)),
            IconButton(tooltip: 'Settings', onPressed: () => _dialog(SettingsDialog(audioService: widget.audioService, progressService: ps)), icon: const Icon(Icons.settings_rounded, color: Colors.white70)),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), child: Container(
            padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
            child: Row(children: [
              const Icon(Icons.explore_rounded, color: GameColors.neonCyan, size: 32), const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('YOUR NEXT ADVENTURE', style: TextStyle(fontSize: 10, letterSpacing: 1.6, color: Colors.white60, fontWeight: FontWeight.w700)),
                Text('Level ${ps.unlockedLevel}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
                Text('${ps.totalStars} stars collected • 800 levels', style: const TextStyle(fontSize: 11, color: Colors.white60)),
              ])),
              FilledButton(onPressed: () => _play(ps.unlockedLevel), style: FilledButton.styleFrom(backgroundColor: GameColors.neonCyan, foregroundColor: const Color(0xFF101B37), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)), child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.w900))),
            ]),
          )),
          Row(children: [
            IconButton(tooltip: 'Previous world', onPressed: _world > 0 ? () => _changeWorld(-1) : null, icon: const Icon(Icons.chevron_left_rounded)),
            Expanded(child: Column(children: [
              Text('WORLD ${_world + 1} / 16', style: const TextStyle(fontSize: 10, color: GameColors.neonCyan, letterSpacing: 2, fontWeight: FontWeight.w800)),
              Text(LevelGenerator.worldNames[_world], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text('Levels ${_world * 50 + 1}–${_world * 50 + 50}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ])),
            IconButton(tooltip: 'Next world', onPressed: _world < 15 ? () => _changeWorld(1) : null, icon: const Icon(Icons.chevron_right_rounded)),
          ]),
          const SizedBox(height: 8),
          Expanded(child: LayoutBuilder(builder: (context, box) {
            final w = box.maxWidth;
            return ListView.builder(controller: _scroll, padding: const EdgeInsets.only(top: 16, bottom: 24), itemCount: 50, itemExtent: 106, itemBuilder: (context, index) {
              final level = _world * 50 + index + 1;
              final unlocked = ps.isLevelUnlocked(level);
              final current = level == ps.unlockedLevel;
              final stars = ps.getLevelStars(level);
              final x = w / 2 + sin(index * pi / 2) * w * .24;
              final nextX = w / 2 + sin((index + 1) * pi / 2) * w * .24;
              final color = current ? GameColors.neonCyan : unlocked ? const Color(0xFFB598FF) : const Color(0xFF514F72);
              return Stack(clipBehavior: Clip.none, children: [
                if (index < 49) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _TrailPainter(x, nextX, unlocked)))),
                Positioned(left: x - 35, top: 0, width: 70, child: Semantics(button: true, label: 'Level $level, ${unlocked ? '$stars stars' : 'locked'}', child: GestureDetector(onTap: () => _play(level), child: Column(children: [
                  Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: current ? [const Color(0xFF79F4FF), const Color(0xFF159ABF)] : unlocked ? [const Color(0xFFB795F7), const Color(0xFF6A48AF)] : [const Color(0xFF45445F), const Color(0xFF29283F)]),
                    border: Border.all(color: current ? Colors.white : color, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .4), offset: const Offset(0, 5), blurRadius: 0), if (current) BoxShadow(color: color.withValues(alpha: .35), blurRadius: 24)]),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      if (!unlocked) const Icon(Icons.lock_rounded, size: 16, color: Colors.white38),
                      Text('$level', style: TextStyle(fontSize: unlocked ? 25 : 17, fontWeight: FontWeight.w900, color: current ? const Color(0xFF10213A) : unlocked ? Colors.white : Colors.white54)),
                    ])),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (s) => Icon(s < stars ? Icons.star_rounded : Icons.star_outline_rounded, size: 17, color: s < stars ? const Color(0xFFFFD166) : Colors.white24))),
                ])))),
                if (current) Positioned(left: x < w / 2 ? x + 43 : x - 112, top: 22, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: GameColors.neonCyan.withValues(alpha: .14), borderRadius: BorderRadius.circular(20)), child: const Text('YOU ARE HERE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: GameColors.neonCyan)))),
              ]);
            });
          })),
          Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), decoration: const BoxDecoration(color: Color(0xFF14172F), border: Border(top: BorderSide(color: Colors.white12))), child: Row(children: [
            _nav('Rewards', Icons.card_giftcard_rounded, const Color(0xFFFFCF60), () => _dialog(DailyRewardsDialog(progressService: ps, audioService: widget.audioService))),
            _nav('Missions', Icons.flag_rounded, GameColors.neonCyan, () => _dialog(DailyQuestsDialog(progressService: ps, audioService: widget.audioService))),
            _nav('Badges', Icons.emoji_events_rounded, const Color(0xFFC6A4FF), () => _dialog(AchievementsDialog(progressService: ps, audioService: widget.audioService))),
          ])),
        ])),
      ),
    ));
  }
  Widget _stat(IconData icon, String value, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 19), const SizedBox(width: 4), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800))]);
  Widget _nav(String title, IconData icon, Color color, VoidCallback tap) => Expanded(child: TextButton(onPressed: tap, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 3), Text(title, style: const TextStyle(fontSize: 11, color: Colors.white70))])));
}
class _TrailPainter extends CustomPainter {
  final double x, nextX;
  final bool unlocked;
  _TrailPainter(this.x, this.nextX, this.unlocked);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = (unlocked ? GameColors.neonCyan : Colors.white).withValues(alpha: unlocked ? .3 : .1)..strokeWidth = 5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(x, 60)..cubicTo(x, 90, nextX, 80, nextX, 112), p);
  }
  @override
  bool shouldRepaint(covariant _TrailPainter old) => x != old.x || nextX != old.nextX || unlocked != old.unlocked;
}
