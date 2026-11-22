import 'dart:math';
import 'package:flutter/material.dart';
import '../core/models/bubble.dart';

class HexGrid {
  static const int evenCols = 8;
  static const int oddCols = 7;

  final double originY;
  final double bubbleRadius;
  final double rowHeight; // R * sqrt(3)

  HexGrid(this.bubbleRadius, {this.originY = 0}) : rowHeight = bubbleRadius * sqrt(3);

  static double calculateRadius(double boardWidth) {
    // 8 bubbles across on even rows: 8 * (2R) = 16R => R = boardWidth / 16
    return boardWidth / (evenCols * 2);
  }

  Offset getBubbleCenter(int row, int col) {
    final isEven = (row % 2 == 0);
    final x = isEven
        ? bubbleRadius + col * (bubbleRadius * 2)
        : (bubbleRadius * 2) + col * (bubbleRadius * 2);
    final y = originY + bubbleRadius + row * rowHeight;
    return Offset(x, y);
  }

  static bool isValidCell(int row, int col) {
    if (row < 0) return false;
    final maxC = (row % 2 == 0) ? evenCols : oddCols;
    return col >= 0 && col < maxC;
  }

  static List<Point<int>> getNeighbors(int r, int c) {
    final isEven = (r % 2 == 0);
    final offsets = isEven
        ? [
            const Point(0, -1),  // Left
            const Point(0, 1),   // Right
            const Point(-1, -1), // Top-Left
            const Point(-1, 0),  // Top-Right
            const Point(1, -1),  // Bottom-Left
            const Point(1, 0),   // Bottom-Right
          ]
        : [
            const Point(0, -1),  // Left
            const Point(0, 1),   // Right
            const Point(-1, 0),  // Top-Left
            const Point(-1, 1),  // Top-Right
            const Point(1, 0),   // Bottom-Left
            const Point(1, 1),   // Bottom-Right
          ];

    final neighbors = <Point<int>>[];
    for (final off in offsets) {
      final nr = r + off.x;
      final nc = c + off.y;
      if (isValidCell(nr, nc)) {
        neighbors.add(Point(nr, nc));
      }
    }
    return neighbors;
  }

  // Find all connected bubbles of the same color (Match 3+)
  static List<Point<int>> findMatches(
    Map<String, Bubble> grid,
    int startRow,
    int startCol,
    BubbleColor targetColor,
  ) {
    final visited = <String>{};
    final queue = <Point<int>>[Point(startRow, startCol)];
    final matched = <Point<int>>[];

    visited.add('${startRow}_$startCol');

    while (queue.isNotEmpty) {
      final curr = queue.removeAt(0);
      matched.add(curr);

      for (final neighbor in getNeighbors(curr.x, curr.y)) {
        final key = '${neighbor.x}_${neighbor.y}';
        if (visited.contains(key)) continue;

        final bubble = grid[key];
        if (bubble != null) {
          // Normal matching color or Rainbow special bubble
          if (bubble.color == targetColor || bubble.type == BubbleType.rainbow) {
            visited.add(key);
            queue.add(neighbor);
          }
        }
      }
    }

    return matched;
  }

  // Find all floating disconnected bubbles that must fall
  static List<Point<int>> findFloatingBubbles(Map<String, Bubble> grid) {
    final connectedToCeiling = <String>{};
    final queue = <Point<int>>[];

    // Start flood fill from all bubbles in row 0
    for (final entry in grid.entries) {
      final b = entry.value;
      if (b.row == 0) {
        connectedToCeiling.add(entry.key);
        queue.add(Point(b.row, b.col));
      }
    }

    // Traverse connected network
    while (queue.isNotEmpty) {
      final curr = queue.removeAt(0);
      for (final neighbor in getNeighbors(curr.x, curr.y)) {
        final key = '${neighbor.x}_${neighbor.y}';
        if (!connectedToCeiling.contains(key) && grid.containsKey(key)) {
          connectedToCeiling.add(key);
          queue.add(neighbor);
        }
      }
    }

    // Any bubble in grid NOT in connectedToCeiling is floating!
    final floating = <Point<int>>[];
    for (final entry in grid.entries) {
      if (!connectedToCeiling.contains(entry.key)) {
        floating.add(Point(entry.value.row, entry.value.col));
      }
    }

    return floating;
  }

  // Find all bubbles in Bomb blast radius (2 cells)
  static List<Point<int>> getBombRadius(Map<String, Bubble> grid, int r, int c) {
    final affected = <Point<int>>[];
    final visited = <String>{'${r}_$c'};
    final queue = <Point<int>>[Point(r, c)];

    // BFS depth 2
    int depth = 0;
    while (queue.isNotEmpty && depth < 2) {
      final levelSize = queue.length;
      for (int i = 0; i < levelSize; i++) {
        final curr = queue.removeAt(0);
        for (final n in getNeighbors(curr.x, curr.y)) {
          final key = '${n.x}_${n.y}';
          if (!visited.contains(key)) {
            visited.add(key);
            queue.add(n);
            if (grid.containsKey(key)) {
              affected.add(n);
            }
          }
        }
      }
      depth++;
    }

    return affected;
  }

  // Find all bubbles in lightning row(s)
  static List<Point<int>> getLightningRow(Map<String, Bubble> grid, int row) {
    final affected = <Point<int>>[];
    for (int r = row; r <= row; r++) {
      final maxC = (r % 2 == 0) ? evenCols : oddCols;
      for (int c = 0; c < maxC; c++) {
        if (grid.containsKey('${r}_$c')) {
          affected.add(Point(r, c));
        }
      }
    }
    return affected;
  }
}
