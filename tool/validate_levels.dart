// ignore_for_file: avoid_print
import 'dart:math';
import 'package:bubble_rush/core/generators/level_generator.dart';
import 'package:bubble_rush/core/models/bubble.dart';
import 'package:bubble_rush/game/hex_grid.dart';

void main() {
  print('Starting comprehensive validation of Bubble Rush 800 Levels...');

  int totalBubblesAllLevels = 0;
  int bossCount = 0;

  for (int lvl = 1; lvl <= 800; lvl++) {
    final data = LevelGenerator.generate(lvl);

    assert(data.levelNumber == lvl, 'Level number mismatch');
    assert(data.worldNumber == ((lvl - 1) ~/ 50) + 1, 'World number calculation error');
    assert(data.worldName.isNotEmpty, 'World name missing');
    assert(data.shotsLimit >= 15, 'Level $lvl has too few shots');
    assert(data.initialGrid.isNotEmpty, 'Level $lvl grid is empty');
    assert(data.availableColors.length >= 3, 'Level $lvl must have at least 3 colors');
    assert(data.starThresholds.length == 3, 'Star thresholds incomplete');
    assert(data.starThresholds[0] < data.starThresholds[1], 'Star 1 must be < Star 2');
    assert(data.starThresholds[1] < data.starThresholds[2], 'Star 2 must be < Star 3');

    if (lvl % 50 == 0) {
      assert(data.isBossLevel, 'Level $lvl should be boss');
      bossCount++;
    }

    totalBubblesAllLevels += data.initialGrid.length;

    // Validate bounds of every bubble
    for (final entry in data.initialGrid.entries) {
      final b = entry.value;
      assert(b.row >= 0, 'Negative row in level $lvl');
      final maxC = (b.row % 2 == 0) ? HexGrid.evenCols : HexGrid.oddCols;
      assert(b.col >= 0 && b.col < maxC, 'Invalid column ${b.col} in row ${b.row} in level $lvl');
    }
  }

  print('PASSED: All 800 levels successfully validated!');
  print('Total worlds: ${LevelGenerator.worldNames.length} (16)');
  print('Milestone boss levels: $bossCount (16)');
  print('Average bubbles per level: ${(totalBubblesAllLevels / 800).toStringAsFixed(1)}');

  // Validate HexGrid mechanics
  print('\nValidating HexGrid neighbor & match mechanics...');
  final n00 = HexGrid.getNeighbors(0, 0);
  assert(n00.contains(const Point(0, 1)));
  assert(n00.contains(const Point(1, 0)));

  final testGrid = <String, Bubble>{
    '0_0': Bubble(id: 'b1', row: 0, col: 0, color: BubbleColor.cyan),
    '0_1': Bubble(id: 'b2', row: 0, col: 1, color: BubbleColor.cyan),
    '1_0': Bubble(id: 'b3', row: 1, col: 0, color: BubbleColor.cyan),
    '0_2': Bubble(id: 'b4', row: 0, col: 2, color: BubbleColor.pink),
  };
  final matches = HexGrid.findMatches(testGrid, 0, 0, BubbleColor.cyan);
  assert(matches.length == 3);

  // Validate floating bubble detection
  final floatingGrid = <String, Bubble>{
    '0_0': Bubble(id: 'b1', row: 0, col: 0, color: BubbleColor.cyan),
    '1_0': Bubble(id: 'b2', row: 1, col: 0, color: BubbleColor.cyan),
    '5_2': Bubble(id: 'b3', row: 5, col: 2, color: BubbleColor.gold),
    '5_3': Bubble(id: 'b4', row: 5, col: 3, color: BubbleColor.gold),
  };
  final dropped = HexGrid.findFloatingBubbles(floatingGrid);
  assert(dropped.length == 2);
  assert(dropped.contains(const Point(5, 2)));
  assert(dropped.contains(const Point(5, 3)));

  print('PASSED: HexGrid geometry, Match-3 BFS, and floating bubble detection 100% verified!');
}
