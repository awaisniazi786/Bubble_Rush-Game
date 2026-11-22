import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_rush/core/generators/level_generator.dart';
import 'package:bubble_rush/core/models/bubble.dart';
import 'package:bubble_rush/game/hex_grid.dart';

void main() {
  group('800 Level Generation & Solvability Validation', () {
    test('All 800 levels generate with valid parameters and non-empty grids', () {
      expect(LevelGenerator.totalLevels, 800);
      expect(LevelGenerator.worldNames.length, 16);

      for (int lvl = 1; lvl <= 800; lvl++) {
        final data = LevelGenerator.generate(lvl);

        expect(data.levelNumber, lvl);
        expect(data.worldNumber, ((lvl - 1) ~/ 50) + 1);
        expect(data.worldName.isNotEmpty, true);
        expect(data.shotsLimit, greaterThanOrEqualTo(15));
        expect(data.initialGrid.isNotEmpty, true, reason: 'Level $lvl grid must not be empty');
        expect(data.availableColors.length, greaterThanOrEqualTo(3));
        expect(data.starThresholds.length, 3);
        expect(data.starThresholds[0] < data.starThresholds[1], true);
        expect(data.starThresholds[1] < data.starThresholds[2], true);

        // Milestone boss levels
        if (lvl % 50 == 0) {
          expect(data.isBossLevel, true, reason: 'Level $lvl should be a milestone boss level');
        }

        // Validate all bubbles have valid positions
        for (final entry in data.initialGrid.entries) {
          final b = entry.value;
          expect(b.row, greaterThanOrEqualTo(0));
          final maxC = (b.row % 2 == 0) ? HexGrid.evenCols : HexGrid.oddCols;
          expect(b.col, greaterThanOrEqualTo(0));
          expect(b.col, lessThan(maxC));
        }
      }
    });
  });

  group('HexGrid Game Mechanics Tests', () {
    test('Neighbor calculations match hexagonal coordinate geometry', () {
      // Row 0 (even, 8 cols): (0, 0)
      final n00 = HexGrid.getNeighbors(0, 0);
      // Valid neighbors should only include (0, 1), (1, 0)
      expect(n00.contains(const Point(0, 1)), true);
      expect(n00.contains(const Point(1, 0)), true);
      expect(n00.contains(const Point(-1, 0)), false); // Negative rows invalid

      // Row 1 (odd, 7 cols): (1, 3)
      final n13 = HexGrid.getNeighbors(1, 3);
      expect(n13.contains(const Point(1, 2)), true); // Left
      expect(n13.contains(const Point(1, 4)), true); // Right
      expect(n13.contains(const Point(0, 3)), true); // Top-Left
      expect(n13.contains(const Point(0, 4)), true); // Top-Right
      expect(n13.contains(const Point(2, 3)), true); // Bottom-Left
      expect(n13.contains(const Point(2, 4)), true); // Bottom-Right
    });

    test('Match-3 flood fill correctly identifies connected bubbles of same color', () {
      final grid = <String, Bubble>{
        '0_0': Bubble(id: 'b1', row: 0, col: 0, color: BubbleColor.cyan),
        '0_1': Bubble(id: 'b2', row: 0, col: 1, color: BubbleColor.cyan),
        '1_0': Bubble(id: 'b3', row: 1, col: 0, color: BubbleColor.cyan),
        '0_2': Bubble(id: 'b4', row: 0, col: 2, color: BubbleColor.pink),
      };

      final matches = HexGrid.findMatches(grid, 0, 0, BubbleColor.cyan);
      expect(matches.length, 3);
      expect(matches.contains(const Point(0, 0)), true);
      expect(matches.contains(const Point(0, 1)), true);
      expect(matches.contains(const Point(1, 0)), true);
      expect(matches.contains(const Point(0, 2)), false); // Pink does not match
    });

    test('Floating bubble drop detection identifies disconnected clusters', () {
      final grid = <String, Bubble>{
        // Ceiling anchor
        '0_0': Bubble(id: 'b1', row: 0, col: 0, color: BubbleColor.cyan),
        '1_0': Bubble(id: 'b2', row: 1, col: 0, color: BubbleColor.cyan),
        // Disconnected floating cluster far down
        '4_3': Bubble(id: 'b3', row: 4, col: 3, color: BubbleColor.gold),
        '4_4': Bubble(id: 'b4', row: 4, col: 4, color: BubbleColor.gold),
      };

      final floating = HexGrid.findFloatingBubbles(grid);
      expect(floating.length, 2);
      expect(floating.contains(const Point(4, 3)), true);
      expect(floating.contains(const Point(4, 4)), true);
      expect(floating.contains(const Point(0, 0)), false);
      expect(floating.contains(const Point(1, 0)), false);
    });
  });
}
