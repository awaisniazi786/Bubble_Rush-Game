import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubble_rush/core/models/bubble.dart';
import 'package:bubble_rush/core/models/level_data.dart';
import 'package:bubble_rush/core/services/audio_service.dart';
import 'package:bubble_rush/core/services/progress_service.dart';
import 'package:bubble_rush/core/services/storage_service.dart';
import 'package:bubble_rush/game/physics.dart';
import 'package:bubble_rush/ui/screens/gameplay_screen.dart';
import 'package:bubble_rush/ui/widgets/bubble_widget.dart';

void main() {
  test('Descending ceiling moves collision and snap coordinates together', () {
    final grid = {'0_3': Bubble(id: 'anchor', row: 0, col: 3, color: BubbleColor.cyan)};
    TrajectoryResult trace(double offset) => PhysicsEngine.calculateTrajectory(
      startPos: Offset(140, 420 + offset), angle: -pi / 2,
      grid: grid, boardWidth: 320, bubbleRadius: 20, ceilingOffset: offset,
    );
    final before = trace(0);
    final after = trace(45);
    expect(after.targetCell, before.targetCell);
    expect(after.hitBubble?.id, 'anchor');
    expect(after.path.last.dy - before.path.last.dy, closeTo(45, .01));
    expect(grid.containsKey('${after.targetCell.x}_${after.targetCell.y}'), false);
  });

  testWidgets('Single tap launches a visible shooter and matching bubbles pop', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();
    final progress = ProgressService(storage);
    await progress.init();
    // An uninitialized audio service is silent and does not touch platform channels.
    final audio = AudioService(storage);
    final level = LevelData(levelNumber: 1, title: 'Tap regression', worldNumber: 1,
      worldName: 'Test', rows: 1, cols: 8, shotsLimit: 12,
      starThresholds: [100, 200, 300], availableColors: [BubbleColor.cyan],
      initialGrid: {
        '0_3': Bubble(id: 'a', row: 0, col: 3, color: BubbleColor.cyan),
        '0_4': Bubble(id: 'b', row: 0, col: 4, color: BubbleColor.cyan),
      });
    await tester.pumpWidget(MaterialApp(home: GameplayScreen(levelData: level, audioService: audio, progressService: progress)));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(GlossyBubbleWidget), findsNWidgets(4));
    await tester.tapAt(const Offset(180, 220));
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.text('11'), findsOneWidget); // Tap consumed exactly one shot.
    for (int i = 0; i < 45; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byType(GlossyBubbleWidget), findsNWidgets(2)); // Only current/next remain.
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
