import 'dart:math';
import '../models/bubble.dart';
import '../models/level_data.dart';

class LevelGenerator {
  static const int totalLevels = 800;

  static const List<String> worldNames = [
    'Neon Genesis',       // Worlds 1-50
    'Cyber Pulse',        // Worlds 51-100
    'Plasma Grid',        // Worlds 101-150
    'Quantum Drift',      // Worlds 151-200
    'Hyperdrive',         // Worlds 201-250
    'Solar Flare',        // Worlds 251-300
    'Starlight Void',     // Worlds 301-350
    'Nebula Core',        // Worlds 351-400
    'Astral Gate',        // Worlds 401-450
    'Chrono Warp',        // Worlds 451-500
    'Vortex Surge',       // Worlds 501-550
    'Apex Horizon',       // Worlds 551-600
    'Neon Matrix',        // Worlds 601-650
    'Dark Matter',        // Worlds 651-700
    'Supernova',          // Worlds 701-750
    'Cosmic Singularity', // Worlds 751-800
  ];

  static LevelData generate(int levelNumber) {
    assert(levelNumber >= 1 && levelNumber <= totalLevels, 'Level must be between 1 and 800');

    final worldIndex = ((levelNumber - 1) ~/ 50).clamp(0, worldNames.length - 1);
    final worldName = worldNames[worldIndex];
    final isBossLevel = levelNumber % 50 == 0;

    // Deterministic RNG seeded by level number
    final rng = Random(levelNumber * 7919 + 1337);

    // Color progression
    final List<BubbleColor> availableColors;
    if (levelNumber <= 15) {
      availableColors = [BubbleColor.cyan, BubbleColor.pink, BubbleColor.gold];
    } else if (levelNumber <= 60) {
      availableColors = [BubbleColor.cyan, BubbleColor.pink, BubbleColor.gold, BubbleColor.green];
    } else if (levelNumber <= 180) {
      availableColors = [BubbleColor.cyan, BubbleColor.pink, BubbleColor.gold, BubbleColor.green, BubbleColor.purple];
    } else if (levelNumber <= 400) {
      availableColors = [BubbleColor.cyan, BubbleColor.pink, BubbleColor.gold, BubbleColor.green, BubbleColor.purple, BubbleColor.orange];
    } else {
      availableColors = BubbleColor.values.toList();
    }

    // Grid configuration
    const cols = 8;
    final rowCount = (6 + (levelNumber % 4) + (isBossLevel ? 2 : 0)).clamp(6, 11);
    final grid = <String, Bubble>{};

    final patternType = (levelNumber % 8);

    for (int r = 0; r < rowCount; r++) {
      final rowCols = (r % 2 == 0) ? cols : cols - 1;
      for (int c = 0; c < rowCols; c++) {
        final shouldPlace = _shouldPlaceBubble(patternType, r, c, rowCols, rowCount, isBossLevel, rng);
        if (!shouldPlace) continue;

        // Determine if special bubble
        BubbleType bType = BubbleType.normal;
        BubbleColor? bColor = availableColors[rng.nextInt(availableColors.length)];

        // Special bubble chances based on level
        final specialRoll = rng.nextDouble();
        if (levelNumber >= 20 && specialRoll < 0.04) {
          bType = BubbleType.bomb;
          bColor = null;
        } else if (levelNumber >= 40 && specialRoll < 0.07) {
          bType = BubbleType.rainbow;
          bColor = null;
        } else if (levelNumber >= 100 && specialRoll < 0.09) {
          bType = BubbleType.lightning;
          bColor = null;
        } else if (levelNumber >= 150 && specialRoll < 0.11) {
          bType = BubbleType.fire;
          bColor = null;
        }

        final id = 'b_${r}_${c}_$levelNumber';
        grid['${r}_$c'] = Bubble(
          id: id,
          row: r,
          col: c,
          color: bColor,
          type: bType,
        );
      }
    }

    // Ensure ceiling row has at least 4 bubbles so it's never empty
    final topRowCols = cols;
    int topCount = 0;
    for (int c = 0; c < topRowCols; c++) {
      if (grid.containsKey('0_$c')) topCount++;
    }
    if (topCount < 4) {
      for (int c = 0; c < topRowCols; c += 2) {
        if (!grid.containsKey('0_$c')) {
          grid['0_$c'] = Bubble(
            id: 'b_0_${c}_$levelNumber',
            row: 0,
            col: c,
            color: availableColors[c % availableColors.length],
            type: BubbleType.normal,
          );
        }
      }
    }

    // Shot calculations: based on total bubble count
    final totalBubbles = grid.length;
    final baseShots = (totalBubbles * 0.45).round() + 10;
    final shotsLimit = baseShots.clamp(20, 50);

    // Star score calculations
    final baseScore = totalBubbles * 150;
    final star1 = (baseScore * 0.5).round();
    final star2 = (baseScore * 0.8).round();
    final star3 = (baseScore * 1.2).round();

    final title = isBossLevel
        ? 'Sector Boss #$levelNumber'
        : 'Level $levelNumber • ${_getLevelSubtitle(patternType)}';

    return LevelData(
      levelNumber: levelNumber,
      title: title,
      worldNumber: worldIndex + 1,
      worldName: worldName,
      rows: rowCount,
      cols: cols,
      shotsLimit: shotsLimit,
      starThresholds: [star1, star2, star3],
      availableColors: availableColors,
      initialGrid: grid,
      isBossLevel: isBossLevel,
    );
  }

  static bool _shouldPlaceBubble(
    int pattern,
    int r,
    int c,
    int rowCols,
    int rowCount,
    bool isBoss,
    Random rng,
  ) {
    if (r == 0) return true; // Row 0 is ceiling anchor

    switch (pattern) {
      case 0: // Horizontal Bands
        return (r % 2 == 0) || (c > 0 && c < rowCols - 1);
      case 1: // Diamond / Hexagon Cluster
        final mid = rowCols / 2;
        final dist = (c - mid).abs();
        return dist <= (rowCount - r + 1);
      case 2: // V-Shape
        return (c <= r + 1) && (rowCols - 1 - c <= r + 1);
      case 3: // Crown / Fortress
        if (r == 1) return c % 2 == 0;
        return true;
      case 4: // Pockets and Columns
        return c % 3 != 1 || r < 3;
      case 5: // Honeycomb Checkerboard
        return (r + c) % 2 == 0 || r <= 2;
      case 6: // Spiral/Whirlpool Core
        if (r == rowCount - 1) return c > 1 && c < rowCols - 2;
        return true;
      case 7: // Boss Layout
        if (isBoss) {
          if (r >= rowCount - 2) return c >= 2 && c <= rowCols - 3;
        }
        return rng.nextDouble() > 0.15;
      default:
        return true;
    }
  }

  static String _getLevelSubtitle(int pattern) {
    switch (pattern) {
      case 0:
        return 'Neon Bands';
      case 1:
        return 'Crystal Diamond';
      case 2:
        return 'Vector Surge';
      case 3:
        return 'Cyber Crown';
      case 4:
        return 'Plasma Fortress';
      case 5:
        return 'Quantum Honeycomb';
      case 6:
        return 'Singularity Core';
      case 7:
        return 'Nova Shield';
      default:
        return 'Arcade Rush';
    }
  }
}
