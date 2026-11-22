import 'bubble.dart';

class LevelData {
  final int levelNumber;
  final String title;
  final int worldNumber;
  final String worldName;
  final int rows;
  final int cols;
  final int shotsLimit;
  final List<int> starThresholds; // [star1, star2, star3]
  final List<BubbleColor> availableColors;
  final Map<String, Bubble> initialGrid; // Key: "r_c"
  final bool isBossLevel;

  LevelData({
    required this.levelNumber,
    required this.title,
    required this.worldNumber,
    required this.worldName,
    required this.rows,
    required this.cols,
    required this.shotsLimit,
    required this.starThresholds,
    required this.availableColors,
    required this.initialGrid,
    this.isBossLevel = false,
  });

  int get bubbleCount => initialGrid.length;

  int calculateStars(int score) {
    if (score >= starThresholds[2]) return 3;
    if (score >= starThresholds[1]) return 2;
    if (score >= starThresholds[0]) return 1;
    return 0;
  }
}
