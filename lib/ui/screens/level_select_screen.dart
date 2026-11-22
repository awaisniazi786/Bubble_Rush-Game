import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/generators/level_generator.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import 'gameplay_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  final AudioService audioService;
  final ProgressService progressService;

  const LevelSelectScreen({
    super.key,
    required this.audioService,
    required this.progressService,
  });

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  late int _selectedWorldIndex;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Default to player's current unlocked level's world
    final currentUnlocked = widget.progressService.unlockedLevel;
    _selectedWorldIndex = ((currentUnlocked - 1) ~/ 50).clamp(0, LevelGenerator.worldNames.length - 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onLevelTapped(int level) {
    if (!widget.progressService.isLevelUnlocked(level)) {
      widget.audioService.playBounce();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Level $level is locked! Complete Level ${level - 1} first.'),
          backgroundColor: const Color(0xFF1E1038),
          duration: const Duration(milliseconds: 1500),
        ),
      );
      return;
    }

    widget.audioService.playClick();
    final levelData = LevelGenerator.generate(level);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameplayScreen(
          levelData: levelData,
          audioService: widget.audioService,
          progressService: widget.progressService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ps = widget.progressService;
    final startLevel = _selectedWorldIndex * 50 + 1;
    final endLevel = startLevel + 49;
    final worldName = LevelGenerator.worldNames[_selectedWorldIndex];

    return Scaffold(
      backgroundColor: GameColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () {
                        widget.audioService.playClick();
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'SECTOR ${_selectedWorldIndex + 1} / 16',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        color: GameColors.neonCyan,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: GameColors.neonGold, size: 18.0),
                          const SizedBox(width: 4.0),
                          Text(
                            '${ps.totalStars}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // World Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Column(
                  children: [
                    Text(
                      worldName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(color: GameColors.neonCyan, blurRadius: 14.0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      'Levels $startLevel - $endLevel',
                      style: const TextStyle(
                        color: GameColors.textSecondary,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),

              // Horizontal Sector Selector Carousel
              SizedBox(
                height: 40.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: LevelGenerator.worldNames.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedWorldIndex;
                    return GestureDetector(
                      onTap: () {
                        widget.audioService.playClick();
                        setState(() {
                          _selectedWorldIndex = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          gradient: isSelected ? GameColors.playButtonGradient : null,
                          color: isSelected ? null : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Sector ${index + 1}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14.0),

              // 50-Level Grid (5 columns)
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 50,
                  itemBuilder: (context, index) {
                    final level = startLevel + index;
                    final isUnlocked = ps.isLevelUnlocked(level);
                    final isCurrent = level == ps.unlockedLevel;
                    final stars = ps.getLevelStars(level);
                    final isBoss = level % 50 == 0;

                    return GestureDetector(
                      onTap: () => _onLevelTapped(level),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? (isCurrent
                                  ? GameColors.neonCyan.withValues(alpha: 0.25)
                                  : (isBoss
                                      ? GameColors.neonPurple.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.08)))
                              : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isCurrent
                                ? GameColors.neonCyan
                                : (isBoss
                                    ? GameColors.neonGold
                                    : (isUnlocked ? Colors.white30 : Colors.white10)),
                            width: isCurrent || isBoss ? 2.0 : 1.0,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: GameColors.neonCyan.withValues(alpha: 0.4),
                                    blurRadius: 10.0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isUnlocked)
                              const Icon(Icons.lock_rounded, color: Colors.white30, size: 20.0)
                            else if (isBoss)
                              const Icon(Icons.shield_rounded, color: GameColors.neonGold, size: 20.0)
                            else
                              Text(
                                '$level',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                  color: isCurrent ? GameColors.neonCyan : Colors.white,
                                ),
                              ),
                            const SizedBox(height: 4.0),

                            // Stars indicator
                            if (isUnlocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(3, (sIdx) {
                                  final earned = sIdx < stars;
                                  return Icon(
                                    earned ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: 11.0,
                                    color: earned ? GameColors.neonGold : Colors.white24,
                                  );
                                }),
                              ),
                          ],
                        ),
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
