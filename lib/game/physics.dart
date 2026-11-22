import 'dart:math';
import 'package:flutter/material.dart';
import '../core/models/bubble.dart';
import 'hex_grid.dart';

class TrajectoryResult {
  final List<Offset> path;
  final Point<int> targetCell;
  final Bubble? hitBubble;
  final bool hitCeiling;

  TrajectoryResult({
    required this.path,
    required this.targetCell,
    this.hitBubble,
    this.hitCeiling = false,
  });
}

class PhysicsEngine {
  static TrajectoryResult calculateTrajectory({
    required Offset startPos,
    required double angle, // radians, negative is upward
    required Map<String, Bubble> grid,
    required double boardWidth,
    required double bubbleRadius,
    int maxBounces = 32,
    double ceilingOffset = 0,
  }) {
    final hexGrid = HexGrid(bubbleRadius, originY: ceilingOffset);
    final minX = bubbleRadius;
    final maxX = boardWidth - bubbleRadius;
    final minY = ceilingOffset + bubbleRadius;

    final path = <Offset>[startPos];
    var currentPos = startPos;
    var currentDir = Offset(cos(angle), sin(angle));

    // Ensure we are aiming upwards
    if (currentDir.dy >= 0) {
      currentDir = Offset(currentDir.dx, -0.05);
    }

    int bounces = 0;
    const stepSize = 4.0;
    const maxSteps = 20000;

    for (int step = 0; step < maxSteps; step++) {
      final nextPos = currentPos + currentDir * stepSize;

      // 1. Check wall bounces
      if (nextPos.dx <= minX) {
        // Hit left wall
        final t = (minX - currentPos.dx) / currentDir.dx;
        final bouncePt = currentPos + currentDir * t;
        path.add(bouncePt);
        currentPos = bouncePt;
        currentDir = Offset(-currentDir.dx, currentDir.dy);
        bounces++;
        if (bounces > maxBounces) break;
        continue;
      } else if (nextPos.dx >= maxX) {
        // Hit right wall
        final t = (maxX - currentPos.dx) / currentDir.dx;
        final bouncePt = currentPos + currentDir * t;
        path.add(bouncePt);
        currentPos = bouncePt;
        currentDir = Offset(-currentDir.dx, currentDir.dy);
        bounces++;
        if (bounces > maxBounces) break;
        continue;
      }

      // 2. Check collision with bubbles on board
      Bubble? collidedBubble;
      for (final b in grid.values) {
        final center = hexGrid.getBubbleCenter(b.row, b.col);
        final dist = (nextPos - center).distance;
        // Collision threshold: center-to-center distance <= 2 * R (with small epsilon)
        if (dist <= bubbleRadius * 1.92) {
          collidedBubble = b;
          break;
        }
      }

      if (collidedBubble != null) {
        path.add(nextPos);
        final targetCell = _findBestSnapCell(
          hitPos: nextPos,
          collidedBubble: collidedBubble,
          hexGrid: hexGrid,
          grid: grid,
        );
        return TrajectoryResult(
          path: path,
          targetCell: targetCell,
          hitBubble: collidedBubble,
          hitCeiling: false,
        );
      }

      // 3. Check ceiling collision
      if (nextPos.dy <= minY) {
        final t = (minY - currentPos.dy) / currentDir.dy;
        final ceilingPt = currentPos + currentDir * t;
        path.add(ceilingPt);

        // Find closest column on row 0
        final targetCol = ((ceilingPt.dx - bubbleRadius) / (bubbleRadius * 2))
            .round()
            .clamp(0, HexGrid.evenCols - 1);

        return TrajectoryResult(
          path: path,
          targetCell: Point(0, targetCol),
          hitCeiling: true,
        );
      }

      currentPos = nextPos;
    }

    path.add(currentPos);
    // Fallback snap cell if ray exhausted
    final fallbackCol = ((currentPos.dx - bubbleRadius) / (bubbleRadius * 2))
        .round()
        .clamp(0, HexGrid.evenCols - 1);
    return TrajectoryResult(
      path: path,
      targetCell: Point(0, fallbackCol),
      hitCeiling: true,
    );
  }

  static Point<int> _findBestSnapCell({
    required Offset hitPos,
    required Bubble collidedBubble,
    required HexGrid hexGrid,
    required Map<String, Bubble> grid,
  }) {
    final neighbors = HexGrid.getNeighbors(collidedBubble.row, collidedBubble.col);
    Point<int>? bestCell;
    double minDistance = double.infinity;

    for (final n in neighbors) {
      final key = '${n.x}_${n.y}';
      if (!grid.containsKey(key)) {
        final center = hexGrid.getBubbleCenter(n.x, n.y);
        final d = (hitPos - center).distance;
        if (d < minDistance) {
          minDistance = d;
          bestCell = n;
        }
      }
    }

    if (bestCell != null) return bestCell;

    // Secondary fallback: search any adjacent ring
    for (int r = max(0, collidedBubble.row - 1); r <= collidedBubble.row + 1; r++) {
      final maxC = (r % 2 == 0) ? HexGrid.evenCols : HexGrid.oddCols;
      for (int c = 0; c < maxC; c++) {
        final key = '${r}_$c';
        if (!grid.containsKey(key)) {
          final center = hexGrid.getBubbleCenter(r, c);
          final d = (hitPos - center).distance;
          if (d < minDistance) {
            minDistance = d;
            bestCell = Point(r, c);
          }
        }
      }
    }

    return bestCell ?? Point(collidedBubble.row + 1, collidedBubble.col);
  }
}
