import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';
import '../../core/generators/level_generator.dart';
import '../../core/models/booster.dart';
import '../../core/models/bubble.dart';
import '../../core/models/level_data.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import '../../game/hex_grid.dart';
import '../../game/particle_system.dart';
import '../../game/physics.dart';
import '../dialogs/game_over_dialog.dart';
import '../dialogs/pause_dialog.dart';
import '../dialogs/victory_dialog.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/particle_painter.dart';
import '../widgets/star_rating_bar.dart';
import '../widgets/trajectory_painter.dart';

class GameplayScreen extends StatefulWidget {
  final LevelData levelData;
  final AudioService audioService;
  final ProgressService progressService;

  const GameplayScreen({
    super.key,
    required this.levelData,
    required this.audioService,
    required this.progressService,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  late Map<String, Bubble> _grid;
  late int _shotsRemaining;
  int _score = 0;
  int _comboStreak = 0;

  bool _paused = false;
  bool _levelEnded = false;
  bool _dangerReached = false;
  double _ceilingOffset = 0;
  int _shotsFired = 0;
  int _lastTick = 0;

  // Aiming & Physics
  bool _isAiming = false;
  double _aimAngle = -pi / 2;
  TrajectoryResult? _trajectory;
  Offset _launcherPos = Offset.zero;
  double _bubbleRadius = 20.0;
  double _boardWidth = 0.0;
  double _boardHeight = 0.0;

  // Shooter bubbles
  Bubble? _currentBubble;
  Bubble? _nextBubble;
  BoosterType? _selectedBooster;
  bool _superAimActive = false;

  // Projectile state
  bool _isShooting = false;
  Offset _projectilePos = Offset.zero;
  List<Offset> _projectileWaypoints = [];
  int _projectileWaypointIndex = 0;
  double _projectileProgress = 0.0;
  Point<int>? _projectileTargetCell;

  // Falling bubbles
  final List<Bubble> _fallingBubbles = [];

  // Particle System & Ticker
  final ParticleManager _particleManager = ParticleManager();
  late AnimationController _gameTicker;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _initLevel();

    _gameTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _gameTicker.addListener(_onGameTick);

    // Switch to gameplay music
    widget.audioService.playGameMusic();
  }

  void _initLevel() {
    _grid = widget.levelData.initialGrid.map((key, b) => MapEntry(key, b.copyWith()));
    _levelEnded = false;
    _dangerReached = false;
    _ceilingOffset = 0;
    _shotsFired = 0;
    _trajectory = null;
    _isAiming = false;
    _shotsRemaining = widget.levelData.shotsLimit;
    _score = 0;
    _comboStreak = 0;
    _fallingBubbles.clear();
    _particleManager.clear();
    _selectedBooster = null;
    _superAimActive = false;
    _isShooting = false;

    _currentBubble = _createRandomShooterBubble();
    _nextBubble = _createRandomShooterBubble();
  }

  Bubble _createRandomShooterBubble([BoosterType? booster]) {
    final colorsOnBoard = _getRemainingColors();
    final colorList = colorsOnBoard.isNotEmpty ? colorsOnBoard : widget.levelData.availableColors;
    final color = colorList[_rng.nextInt(colorList.length)];

    BubbleType type = BubbleType.normal;
    BubbleColor? bubbleColor = color;

    if (booster != null) {
      switch (booster) {
        case BoosterType.bomb:
          type = BubbleType.bomb;
          bubbleColor = null;
          break;
        case BoosterType.rainbow:
          type = BubbleType.rainbow;
          bubbleColor = null;
          break;
        case BoosterType.lightning:
          type = BubbleType.lightning;
          bubbleColor = null;
          break;
        case BoosterType.fire:
          type = BubbleType.fire;
          bubbleColor = null;
          break;
        default:
          break;
      }
    }

    return Bubble(
      id: 'shooter_${DateTime.now().microsecondsSinceEpoch}',
      row: -1,
      col: -1,
      color: bubbleColor,
      type: type,
    );
  }

  List<BubbleColor> _getRemainingColors() {
    final set = <BubbleColor>{};
    for (final b in _grid.values) {
      if (b.color != null) set.add(b.color!);
    }
    return set.toList();
  }

  void _onGameTick() {
    final now = _gameTicker.lastElapsedDuration?.inMicroseconds ?? 0;
    final dt = _lastTick == 0 ? 0.0 : ((now - _lastTick) / 1000000).clamp(0.0, .05);
    _lastTick = now;
    if (_paused || _levelEnded || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _particleManager.update(dt);

    // Update projectile movement
    if (_isShooting && _projectileWaypoints.isNotEmpty) {
      final p1 = _projectileWaypoints[_projectileWaypointIndex];
      final p2 = _projectileWaypoints[_projectileWaypointIndex + 1];
      final segDist = (p2 - p1).distance;
      const speed = 1800.0; // px/sec

      _projectileProgress += (speed * dt) / max(segDist, 1.0);

      if (_projectileProgress >= 1.0) {
        _projectileWaypointIndex++;
        _projectileProgress = 0.0;

        if (_projectileWaypointIndex >= _projectileWaypoints.length - 1) {
          // Reached destination target cell!
          _projectilePos = _projectileWaypoints.last;
          _isShooting = false;
          _onProjectileLanded();
        } else {
          // Bounce occurred
          widget.audioService.playBounce();
          _projectilePos = _projectileWaypoints[_projectileWaypointIndex];
        }
      } else {
        _projectilePos = Offset.lerp(p1, p2, _projectileProgress)!;
      }
    }

    // Update falling bubbles
    if (_fallingBubbles.isNotEmpty) {
      for (final fb in _fallingBubbles) {
        fb.fallVelocity = Offset(fb.fallVelocity.dx, fb.fallVelocity.dy + 750.0 * dt);
        fb.fallOffset += fb.fallVelocity * dt;
        fb.opacity = (fb.opacity - 0.7 * dt).clamp(0.0, 1.0);
      }
      _fallingBubbles.removeWhere((fb) => fb.fallOffset.dy > _boardHeight + 100 || fb.opacity <= 0.0);
    }

    setState(() {});
  }

  void _onPanStart(DragStartDetails details) {
    if (_isShooting || _paused || _levelEnded) return;
    _updateAim(details.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isShooting || _paused || _levelEnded) return;
    _updateAim(details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isShooting || _paused || _levelEnded || !_isAiming) return;
    _shootBubble();
  }

  void _updateAim(Offset touchPos) {
    if (touchPos.dy >= _launcherPos.dy - _bubbleRadius) return;
    final diff = touchPos - _launcherPos;
    var angle = atan2(diff.dy, diff.dx);

    // Only allow aiming upwards with side angle clamps
    if (angle > -0.18 && angle <= pi / 2) angle = -0.18;
    if (angle < -pi + 0.18 || angle > pi / 2) angle = -pi + 0.18;

    _aimAngle = angle;
    _isAiming = true;

    // Calculate trajectory
    _trajectory = PhysicsEngine.calculateTrajectory(
      startPos: _launcherPos,
      angle: _aimAngle,
      grid: _grid,
      boardWidth: _boardWidth,
      bubbleRadius: _bubbleRadius,
      maxBounces: 32,
      ceilingOffset: _ceilingOffset,
    );
  }

  void _shootBubble() {
    if (_trajectory == null || _currentBubble == null || _isShooting || _paused || _levelEnded || _shotsRemaining <= 0 || _trajectory!.path.length < 2) return;

    _shotsRemaining--;
    _isShooting = true;
    _isAiming = false;
    _projectileWaypoints = List<Offset>.from(_trajectory!.path);
    _projectileWaypointIndex = 0;
    _projectileProgress = 0.0;
    _projectilePos = _launcherPos;
    _projectileTargetCell = _trajectory!.targetCell;

    widget.audioService.playLaunch();
  }

  void _onProjectileLanded() {
    if (_projectileTargetCell == null || _currentBubble == null) return;

    final targetRow = _projectileTargetCell!.x;
    final targetCol = _projectileTargetCell!.y;
    final key = '${targetRow}_$targetCol';
    final hexGrid = HexGrid(_bubbleRadius, originY: _ceilingOffset);
    final hitCenter = hexGrid.getBubbleCenter(targetRow, targetCol);

    final firedBubble = _currentBubble!;

    // 1. Process Special Booster / Bubble effects
    if (firedBubble.type == BubbleType.bomb) {
      widget.audioService.playBomb();
      _particleManager.addBombDetonation(hitCenter);

      final affected = HexGrid.getBombRadius(_grid, targetRow, targetCol);
      int count = 0;
      for (final pt in affected) {
        final k = '${pt.x}_${pt.y}';
        final b = _grid.remove(k);
        if (b != null) {
          count++;
          _particleManager.addPopExplosion(hexGrid.getBubbleCenter(pt.x, pt.y), b.color?.color ?? Colors.orange);
        }
      }
      _addScore(count * 150, hitCenter, label: 'BOMB x$count!');
      widget.progressService.updateQuestProgress('dq_use_booster', 1);

    } else if (firedBubble.type == BubbleType.lightning) {
      widget.audioService.playLightning();
      _particleManager.addLightningShockwave(hitCenter);

      final affected = HexGrid.getLightningRow(_grid, targetRow);
      int count = 0;
      for (final pt in affected) {
        final k = '${pt.x}_${pt.y}';
        final b = _grid.remove(k);
        if (b != null) {
          count++;
          _particleManager.addPopExplosion(hexGrid.getBubbleCenter(pt.x, pt.y), GameColors.neonCyan);
        }
      }
      _addScore(count * 200, hitCenter, label: 'LIGHTNING ROW!');
      widget.progressService.updateQuestProgress('dq_use_booster', 1);

    } else if (firedBubble.type == BubbleType.fire) {
      widget.audioService.playFire();
      _particleManager.addBombDetonation(hitCenter);

      // Fire clears direct vertical column up to ceiling
      int count = 0;
      for (int r = 0; r <= targetRow; r++) {
        final maxC = (r % 2 == 0) ? HexGrid.evenCols : HexGrid.oddCols;
        final c = targetCol.clamp(0, maxC - 1);
        final k = '${r}_$c';
        final b = _grid.remove(k);
        if (b != null) {
          count++;
          _particleManager.addPopExplosion(hexGrid.getBubbleCenter(r, c), GameColors.neonOrange);
        }
      }
      _addScore(count * 220, hitCenter, label: 'FIRE BURST!');
      widget.progressService.updateQuestProgress('dq_use_booster', 1);

    } else {
      // Normal bubble or Rainbow bubble
      final placedBubble = Bubble(
        id: firedBubble.id,
        row: targetRow,
        col: targetCol,
        color: firedBubble.color,
        type: firedBubble.type,
      );
      _grid[key] = placedBubble;

      if (firedBubble.type == BubbleType.rainbow) {
        // Rainbow matches any adjacent color
        widget.audioService.playRainbow();
        final neighbors = HexGrid.getNeighbors(targetRow, targetCol);
        final neighborColors = <BubbleColor>{};
        for (final n in neighbors) {
          final nb = _grid['${n.x}_${n.y}'];
          if (nb != null && nb.color != null) neighborColors.add(nb.color!);
        }

        final matchKeys = <String>{key};
        for (final nc in neighborColors) {
          final matches = HexGrid.findMatches(_grid, targetRow, targetCol, nc);
          for (final m in matches) {
            matchKeys.add('${m.x}_${m.y}');
          }
        }

        if (matchKeys.length >= 3) {
          _popBubbles(matchKeys, hexGrid, hitCenter);
        }
        widget.progressService.updateQuestProgress('dq_use_booster', 1);

      } else {
        // Standard Match 3+ Check
        final targetColor = firedBubble.color!;
        final matches = HexGrid.findMatches(_grid, targetRow, targetCol, targetColor);

        if (matches.length >= 3) {
          final matchKeys = matches.map((pt) => '${pt.x}_${pt.y}').toSet();
          _popBubbles(matchKeys, hexGrid, hitCenter);
        } else {
          // Missed match
          _comboStreak = 0;
          widget.audioService.playBounce();
        }
      }
    }

    // 2. Drop Floating Bubbles (Bubbles that lost ceiling connection)
    _dropFloatingBubbles(hexGrid);

    // 3. Replenish shooter bubble
    _superAimActive = false;
    _selectedBooster = null;
    final remaining = _getRemainingColors();
    _currentBubble = _nextBubble;
    if (_currentBubble?.color != null && !remaining.contains(_currentBubble!.color)) {
      _currentBubble = _createRandomShooterBubble();
    }
    _nextBubble = _createRandomShooterBubble();
    _shotsFired++;
    if (_shotsFired % 3 == 0) _ceilingOffset += _bubbleRadius * .65;
    _trajectory = null;

    // 4. Check Level End Conditions
    _checkLevelState();
  }

  void _popBubbles(Set<String> keys, HexGrid hexGrid, Offset hitCenter) {
    _comboStreak++;
    widget.audioService.playPop(combo: _comboStreak);

    int count = 0;
    for (final k in keys) {
      final b = _grid.remove(k);
      if (b != null) {
        count++;
        if (b.color == BubbleColor.cyan) {
          widget.progressService.updateQuestProgress('dq_pop_cyan', 1);
        }
        _particleManager.addPopExplosion(
          hexGrid.getBubbleCenter(b.row, b.col),
          b.color?.color ?? GameColors.neonCyan,
        );
      }
    }

    final points = count * 100 * _comboStreak;
    final label = _comboStreak > 1 ? '+$points (COMBO x$_comboStreak!)' : '+$points';
    _addScore(points, hitCenter, label: label);

    widget.progressService.updateAchievementProgress('combo_3', _comboStreak);
    widget.progressService.updateAchievementProgress('combo_6', _comboStreak);
  }

  void _dropFloatingBubbles(HexGrid hexGrid) {
    final floating = HexGrid.findFloatingBubbles(_grid);
    if (floating.isEmpty) return;

    for (final pt in floating) {
      final key = '${pt.x}_${pt.y}';
      final b = _grid.remove(key);
      if (b != null) {
        b.isFalling = true;
        b.fallOffset = hexGrid.getBubbleCenter(b.row, b.col);
        b.fallVelocity = Offset(
          (_rng.nextDouble() * 120.0) - 60.0,
          -100.0 - _rng.nextDouble() * 100.0,
        );
        _fallingBubbles.add(b);
      }
    }

    final dropPoints = floating.length * 200;
    _addScore(
      dropPoints,
      _launcherPos - const Offset(0, 160.0),
      label: '+DROP x${floating.length} ($dropPoints!)',
    );
    widget.audioService.playStar();
  }

  void _addScore(int points, Offset pos, {String? label}) {
    _score += points;
    if (label != null) {
      _particleManager.addFloatingText(pos, label, GameColors.neonGold);
    }
  }

  void _checkLevelState() {
    if (_levelEnded) return;
    final hex = HexGrid(_bubbleRadius, originY: _ceilingOffset);
    _dangerReached = _grid.values.any((b) => hex.getBubbleCenter(b.row, b.col).dy + _bubbleRadius >= _launcherPos.dy - 62);
    if (_grid.isEmpty) {
      _levelEnded = true;
      // VICTORY!
      _particleManager.addConfetti(_boardWidth);
      widget.audioService.playVictory();

      final stars = widget.levelData.calculateStars(_score);
      final coins = 20 + (max(stars, 1) * 10);
      final oldHigh = widget.progressService.getLevelHighScore(widget.levelData.levelNumber);

      widget.progressService.recordLevelComplete(
        widget.levelData.levelNumber,
        _score,
        max(stars, 1),
      );

      if (stars == 3) {
        widget.progressService.updateQuestProgress('dq_win_levels', 1);
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => VictoryDialog(
          levelNumber: widget.levelData.levelNumber,
          score: _score,
          stars: max(stars, 1),
          coinsEarned: coins,
          isNewHighScore: _score > oldHigh,
          onNextLevel: () {
            Navigator.of(context).pop();
            final nextLvl = widget.levelData.levelNumber + 1;
            if (nextLvl > 800) { Navigator.of(context).pop(); return; }
            if (nextLvl <= 800) {
              final nextData = LevelGenerator.generate(nextLvl);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameplayScreen(
                    levelData: nextData,
                    audioService: widget.audioService,
                    progressService: widget.progressService,
                  ),
                ),
              );
            }
          },
          onReplay: () {
            Navigator.of(context).pop();
            _initLevel();
          },
          onHome: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );

    } else if (_shotsRemaining <= 0 || _dangerReached) {
      _levelEnded = true;
      // GAME OVER
      widget.audioService.playGameOver();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameOverDialog(
          dangerReached: _dangerReached,
          levelNumber: widget.levelData.levelNumber,
          currentScore: _score,
          targetScore: widget.levelData.starThresholds[0],
          remainingBubbles: _grid.length,
          playerCoins: widget.progressService.coins,
          onBuyExtraShots: () async {
            if (_dangerReached) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bubbles reached the danger line. Retry this level.')));
              return;
            }
            final ok = await widget.progressService.spendCoins(100);
            if (ok && mounted) {
              Navigator.of(context).pop();
              setState(() {
                _shotsRemaining += 5;
                _levelEnded = false;
              });
              widget.audioService.playStar();
            }
          },
          onRetry: () {
            Navigator.of(context).pop();
            _initLevel();
          },
          onQuit: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  void _swapShooterBubbles() {
    if (_isShooting || _paused || _levelEnded || _currentBubble == null || _nextBubble == null) return;
    widget.audioService.playClick();
    setState(() {
      final temp = _currentBubble;
      _currentBubble = _nextBubble;
      _nextBubble = temp;
    });
  }

  void _activateBooster(BoosterType type) async {
    if (_isShooting || _paused || _levelEnded) return;

    if (type == BoosterType.slowMotion) return;
    if (type == BoosterType.extraShots) {
      final ok = await widget.progressService.useBooster(type);
      if (!mounted) return;
      if (ok) {
        widget.audioService.playStar();
        setState(() => _shotsRemaining += 5);
      } else {
        _promptBuyBooster(type);
      }
      return;
    }

    if (type == BoosterType.colorSwap) {
      final ok = await widget.progressService.useBooster(type);
      if (!mounted) return;
      if (ok) {
        widget.audioService.playClick();
        _swapShooterBubbles();
      } else {
        _promptBuyBooster(type);
      }
      return;
    }

    if (type == BoosterType.aimExtension) {
      final ok = await widget.progressService.useBooster(type);
      if (!mounted) return;
      if (ok) {
        widget.audioService.playStar();
        setState(() {
          _superAimActive = true;
          if (_isAiming) _updateAim(_launcherPos + Offset(cos(_aimAngle) * 200, sin(_aimAngle) * 200));
        });
      } else {
        _promptBuyBooster(type);
      }
      return;
    }

    // Special bubble projectile boosters (Bomb, Rainbow, Lightning, Fire)
    final ok = await widget.progressService.useBooster(type);
    if (!mounted) return;
    if (ok) {
      widget.audioService.playStar();
      setState(() {
        _selectedBooster = type;
        _currentBubble = _createRandomShooterBubble(type);
      });
    } else {
      _promptBuyBooster(type);
    }
  }

  void _promptBuyBooster(BoosterType type) {
    widget.audioService.playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF140D2B),
        title: Text('Get ${type.title}?', style: const TextStyle(color: Colors.white)),
        content: Text(
          '${type.description}\n\nCost: ${type.costInCoins} Coins (You have: ${widget.progressService.coins})',
          style: const TextStyle(color: GameColors.textSecondary),
        ),
        actions: [
          TextButton(
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('BUY & USE', style: TextStyle(color: GameColors.neonGold, fontWeight: FontWeight.bold)),
            onPressed: () async {
              final ok = await widget.progressService.buyBooster(type);
              if (!mounted) return;
      if (ok) {
                if (ctx.mounted) Navigator.of(ctx).pop();
                _activateBooster(type);
              } else {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Not enough coins!')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTicker.removeListener(_onGameTick);
    _gameTicker.dispose();
    widget.audioService.playMenuMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.levelData.calculateStars(_score);
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: GameColors.backgroundGradient),
        child: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Row(children: [
            IconButton(tooltip: 'Pause', icon: const Icon(Icons.pause_rounded), onPressed: _pauseGame),
            Expanded(child: Column(children: [Text('LEVEL ${widget.levelData.levelNumber}', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 17)), StarRatingBar(stars: stars, starSize: 17)])),
            Column(children: [const Text('SCORE', style: TextStyle(fontSize: 9, color: Colors.white54)), Text('$_score', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: GameColors.neonCyan))]),
          ])),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            // Keep all initial rows and the launcher visible on short phones too.
            _bubbleRadius = min(constraints.maxWidth / 16, max(8.0, (constraints.maxHeight - 170) / ((widget.levelData.rows - 1) * sqrt(3) + 2)));
            _boardWidth = _bubbleRadius * 16;
            _boardHeight = constraints.maxHeight;
            _launcherPos = Offset(_boardWidth / 2, _boardHeight - 64);
            final hex = HexGrid(_bubbleRadius, originY: _ceilingOffset);
            return Align(alignment: Alignment.topCenter, child: SizedBox(width: _boardWidth, height: _boardHeight, child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                if (_isShooting || _paused || _levelEnded) return;
                _updateAim(details.localPosition);
                if (_isAiming) _shootBubble();
              },
              onPanStart: _onPanStart, onPanUpdate: _onPanUpdate, onPanEnd: _onPanEnd,
              onPanCancel: () => setState(() => _isAiming = false),
              child: Stack(clipBehavior: Clip.hardEdge, children: [
                Positioned(top: _launcherPos.dy - 62, left: 0, right: 0, child: IgnorePointer(child: Container(height: 1, color: GameColors.neonPink.withValues(alpha: .5)))),
                if (_isAiming && _trajectory != null && _currentBubble != null)
                  Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: TrajectoryPainter(path: _trajectory!.path, color: _currentBubble!.color?.color ?? GameColors.neonCyan, bubbleRadius: _bubbleRadius, targetCenter: hex.getBubbleCenter(_trajectory!.targetCell.x, _trajectory!.targetCell.y), pulse: _gameTicker.value)))),
                ..._grid.values.map((b) { final c = hex.getBubbleCenter(b.row, b.col); return Positioned(left: c.dx - _bubbleRadius, top: c.dy - _bubbleRadius, child: IgnorePointer(child: GlossyBubbleWidget(bubble: b, radius: _bubbleRadius))); }),
                ..._fallingBubbles.map((b) => Positioned(left: b.fallOffset.dx - _bubbleRadius, top: b.fallOffset.dy - _bubbleRadius, child: IgnorePointer(child: Opacity(opacity: b.opacity, child: GlossyBubbleWidget(bubble: b, radius: _bubbleRadius))))),
                Positioned(left: _launcherPos.dx - 35, top: _launcherPos.dy - 35, child: IgnorePointer(child: Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: GameColors.neonCyan.withValues(alpha: .08), border: Border.all(color: GameColors.neonCyan.withValues(alpha: .5), width: 2), boxShadow: [BoxShadow(color: GameColors.neonCyan.withValues(alpha: .18), blurRadius: 20)])))),
                if (_currentBubble != null) Positioned(left: (_isShooting ? _projectilePos.dx : _launcherPos.dx) - _bubbleRadius, top: (_isShooting ? _projectilePos.dy : _launcherPos.dy) - _bubbleRadius, child: IgnorePointer(child: GlossyBubbleWidget(bubble: _currentBubble!, radius: _bubbleRadius))),
                Positioned(left: max(0.0, _launcherPos.dx - 105), top: _launcherPos.dy - 24, child: Semantics(button: true, label: 'Swap next bubble', child: GestureDetector(onTap: _swapShooterBubbles, child: SizedBox(width: 48, height: 54, child: Column(children: [if (_nextBubble != null) GlossyBubbleWidget(bubble: _nextBubble!, radius: 15), const Icon(Icons.swap_horiz_rounded, size: 20, color: Colors.white70)]))))),
                Positioned(right: 8, top: _launcherPos.dy - 20, child: IgnorePointer(child: Column(children: [Text('$_shotsRemaining', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: _shotsRemaining <= 5 ? GameColors.neonPink : Colors.white)), const Text('SHOTS', style: TextStyle(fontSize: 9, color: Colors.white54))]))),
                const Positioned(bottom: 3, left: 0, right: 0, child: IgnorePointer(child: Text('Tap to shoot • Drag to aim • Match 3+', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white54)))),
                Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: ParticlePainter(particleManager: _particleManager, animationValue: _gameTicker.value)))),
              ]),
            )));
          })),
          Container(margin: const EdgeInsets.fromLTRB(10, 6, 10, 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white12)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _buildBoosterItem(BoosterType.bomb), _buildBoosterItem(BoosterType.rainbow), _buildBoosterItem(BoosterType.lightning), _buildBoosterItem(BoosterType.fire), _buildBoosterItem(BoosterType.aimExtension), _buildBoosterItem(BoosterType.extraShots),
          ])),
        ])),
      ),
    );
  }

  Future<void> _pauseGame() async {
    if (_paused || _levelEnded) return;
    _paused = true;
    await showDialog<void>(context: context, builder: (_) => PauseDialog(
      levelNumber: widget.levelData.levelNumber, currentScore: _score, audioService: widget.audioService,
      onResume: () => Navigator.of(context).pop(),
      onRestart: () { Navigator.of(context).pop(); _initLevel(); },
      onQuit: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
    ));
    if (mounted) { _paused = false; _lastTick = _gameTicker.lastElapsedDuration?.inMicroseconds ?? 0; }
  }

  Widget _buildBoosterItem(BoosterType type) {
    final ps = widget.progressService;
    final count = ps.getBoosterCount(type);
    final isSelected = _selectedBooster == type || (type == BoosterType.aimExtension && _superAimActive);

    return GestureDetector(
      onTap: () => _activateBooster(type),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: isSelected ? type.color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? type.color : Colors.white12,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(color: type.color.withValues(alpha: 0.5), blurRadius: 10.0),
                    ]
                  : null,
            ),
            child: Icon(type.icon, color: type.color, size: 20.0),
          ),
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(3.0),
              decoration: BoxDecoration(
                color: count > 0 ? GameColors.neonPurple : Colors.white24,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16.0, minHeight: 16.0),
              child: Center(
                child: Text(
                  count > 0 ? '$count' : '+',
                  style: const TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
