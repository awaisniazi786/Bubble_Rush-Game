import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/booster.dart';
import '../models/daily_reward.dart';
import 'storage_service.dart';

class ProgressService extends ChangeNotifier {
  final StorageService _storage;

  int _unlockedLevel = 1;
  int _coins = 300;
  Map<int, int> _starsMap = {};
  Map<int, int> _highScores = {};
  Map<BoosterType, int> _boosters = {};
  bool _vibrationEnabled = true;
  bool _reducedMotion = false;

  int _rewardStreak = 0;
  String? _lastRewardDate;

  final List<Achievement> _achievements = [];
  final List<DailyQuest> _dailyQuests = [];

  ProgressService(this._storage);

  Future<void> init() async {
    _unlockedLevel = _storage.getUnlockedLevel();
    _coins = _storage.getCoins();
    _starsMap = _storage.getStarsMap();
    _highScores = _storage.getHighScores();
    _boosters = _storage.getBoosters();
    _vibrationEnabled = _storage.getVibrationEnabled();
    _reducedMotion = _storage.getReducedMotion();
    _rewardStreak = _storage.getRewardStreak();
    _lastRewardDate = _storage.getLastRewardDate();

    _initAchievements();
    _initDailyQuests();
    notifyListeners();
  }

  // Getters
  int get unlockedLevel => _unlockedLevel;
  int get coins => _coins;
  Map<int, int> get starsMap => _starsMap;
  Map<int, int> get highScores => _highScores;
  Map<BoosterType, int> get boosters => _boosters;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get reducedMotion => _reducedMotion;
  int get rewardStreak => _rewardStreak;
  List<Achievement> get achievements => _achievements;
  List<DailyQuest> get dailyQuests => _dailyQuests;

  int get totalStars => _starsMap.values.fold(0, (sum, s) => sum + s);

  int getBoosterCount(BoosterType type) => _boosters[type] ?? 0;

  int getLevelStars(int level) => _starsMap[level] ?? 0;
  int getLevelHighScore(int level) => _highScores[level] ?? 0;
  bool isLevelUnlocked(int level) => level <= _unlockedLevel;

  // Level Completion & Scoring
  Future<void> recordLevelComplete(int level, int score, int stars) async {
    // Update stars
    await _storage.saveStars(level, stars);
    _starsMap[level] = (_starsMap[level] ?? 0) < stars ? stars : (_starsMap[level] ?? stars);

    // Update high score
    await _storage.saveHighScore(level, score);
    _highScores[level] = (_highScores[level] ?? 0) < score ? score : (_highScores[level] ?? score);

    // Unlock next level up to 800
    if (level >= _unlockedLevel && level < 800) {
      _unlockedLevel = level + 1;
      await _storage.saveUnlockedLevel(_unlockedLevel);
    }

    // Award bonus coins for completion
    final coinsWon = 20 + (stars * 10);
    await addCoins(coinsWon);

    // Update stats & achievements
    await _storage.addTotalScore(score);
    updateAchievementProgress('lvl_1', 1);
    if (level >= 50) updateAchievementProgress('world_1', 1);
    if (level >= 250) updateAchievementProgress('world_5', 1);
    if (level >= 800) updateAchievementProgress('lvl_800', 1);
    updateAchievementProgress('stars_50', totalStars);
    updateAchievementProgress('stars_150', totalStars);

    notifyListeners();
  }

  // Currency & Boosters
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _storage.saveCoins(_coins);
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins < amount) return false;
    _coins -= amount;
    await _storage.saveCoins(_coins);
    notifyListeners();
    return true;
  }

  Future<bool> buyBooster(BoosterType type) async {
    final cost = type.costInCoins;
    if (_coins >= cost) {
      _coins -= cost;
      await _storage.saveCoins(_coins);
      _boosters[type] = (_boosters[type] ?? 0) + 1;
      await _storage.saveBoosters(_boosters);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> useBooster(BoosterType type) async {
    final current = _boosters[type] ?? 0;
    if (current > 0) {
      _boosters[type] = current - 1;
      await _storage.saveBoosters(_boosters);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> addBooster(BoosterType type, int count) async {
    _boosters[type] = (_boosters[type] ?? 0) + count;
    await _storage.saveBoosters(_boosters);
    notifyListeners();
  }

  // Daily Rewards
  bool get canClaimDailyReward {
    if (_lastRewardDate == null) return true;
    final today = _getTodayDateString();
    return _lastRewardDate != today;
  }

  int get nextRewardDayIndex => (_rewardStreak % 7);

  Future<bool> claimDailyReward() async {
    if (!canClaimDailyReward) return false;

    final today = _getTodayDateString();
    final item = DailyRewardItem.calendar[nextRewardDayIndex];

    await addCoins(item.coins);
    if (item.booster != null && item.boosterCount > 0) {
      await addBooster(item.booster!, item.boosterCount);
    }

    _rewardStreak++;
    _lastRewardDate = today;
    await _storage.saveRewardStreak(_rewardStreak);
    await _storage.saveLastRewardDate(today);

    notifyListeners();
    return true;
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Settings
  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _storage.saveVibrationEnabled(_vibrationEnabled);
    notifyListeners();
  }

  Future<void> toggleReducedMotion() async {
    _reducedMotion = !_reducedMotion;
    await _storage.saveReducedMotion(_reducedMotion);
    notifyListeners();
  }

  Future<void> resetAllData() async {
    await _storage.resetAll();
    _unlockedLevel = 1;
    _coins = 300;
    _starsMap.clear();
    _highScores.clear();
    _boosters = {
      BoosterType.bomb: 2,
      BoosterType.rainbow: 1,
      BoosterType.lightning: 1,
      BoosterType.fire: 1,
      BoosterType.aimExtension: 2,
      BoosterType.extraShots: 2,
      BoosterType.colorSwap: 3,
      BoosterType.slowMotion: 1,
    };
    _rewardStreak = 0;
    _lastRewardDate = null;
    _initAchievements();
    _initDailyQuests();
    notifyListeners();
  }

  // Achievements Setup
  void _initAchievements() {
    _achievements.clear();
    final saved = _storage.getAchievementsData();

    final defs = [
      Achievement(
        id: 'lvl_1',
        title: 'First Step',
        description: 'Complete Level 1 of Bubble Rush',
        icon: Icons.sports_esports_rounded,
        maxProgress: 1,
        coinReward: 50,
      ),
      Achievement(
        id: 'pops_50',
        title: 'Color Popper',
        description: 'Pop 50 bubbles',
        icon: Icons.bubble_chart_rounded,
        maxProgress: 50,
        coinReward: 80,
      ),
      Achievement(
        id: 'pops_500',
        title: 'Bubble Crusher',
        description: 'Pop 500 bubbles total',
        icon: Icons.flare_rounded,
        maxProgress: 500,
        coinReward: 200,
      ),
      Achievement(
        id: 'combo_3',
        title: 'Combo Initiate',
        description: 'Achieve a 3x match combo streak',
        icon: Icons.electric_bolt_rounded,
        maxProgress: 3,
        coinReward: 100,
      ),
      Achievement(
        id: 'combo_6',
        title: 'Combo Legend',
        description: 'Achieve a massive 6x match combo',
        icon: Icons.auto_awesome,
        maxProgress: 6,
        coinReward: 250,
      ),
      Achievement(
        id: 'stars_50',
        title: 'Star Collector',
        description: 'Collect 50 stars across levels',
        icon: Icons.star_rounded,
        maxProgress: 50,
        coinReward: 150,
      ),
      Achievement(
        id: 'stars_150',
        title: 'Galaxy Conqueror',
        description: 'Collect 150 stars across levels',
        icon: Icons.military_tech_rounded,
        maxProgress: 150,
        coinReward: 350,
      ),
      Achievement(
        id: 'world_1',
        title: 'Sector 1 Veteran',
        description: 'Clear Level 50 Boss in Neon Genesis',
        icon: Icons.workspace_premium_rounded,
        maxProgress: 1,
        coinReward: 250,
      ),
      Achievement(
        id: 'world_5',
        title: 'Hyperdrive Ace',
        description: 'Clear Level 250 in Hyperdrive',
        icon: Icons.rocket_launch_rounded,
        maxProgress: 1,
        coinReward: 400,
      ),
      Achievement(
        id: 'lvl_800',
        title: 'Cosmic Singularity Master',
        description: 'Complete all 800 levels!',
        icon: Icons.diamond_rounded,
        maxProgress: 1,
        coinReward: 1000,
      ),
    ];

    for (final a in defs) {
      if (saved.containsKey(a.id)) {
        final data = saved[a.id] as Map<String, dynamic>;
        a.currentProgress = data['currentProgress'] as int? ?? 0;
        a.isClaimed = data['isClaimed'] as bool? ?? false;
      }
      _achievements.add(a);
    }
  }

  void updateAchievementProgress(String id, int value) {
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final a = _achievements[idx];
      if (value > a.currentProgress) {
        a.currentProgress = value.clamp(0, a.maxProgress);
        _saveAchievements();
        notifyListeners();
      }
    }
  }

  Future<bool> claimAchievement(String id) async {
    final idx = _achievements.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final a = _achievements[idx];
      if (a.isCompleted && !a.isClaimed) {
        a.isClaimed = true;
        await addCoins(a.coinReward);
        _saveAchievements();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void _saveAchievements() {
    final map = {for (var a in _achievements) a.id: a.toJson()};
    _storage.saveAchievementsData(map);
  }

  // Daily Quests Setup
  void _initDailyQuests() {
    _dailyQuests.clear();
    _dailyQuests.addAll([
      DailyQuest(
        id: 'dq_pop_cyan',
        title: 'Cyan Overload',
        description: 'Pop 25 Cyan bubbles',
        icon: Icons.bubble_chart_rounded,
        targetValue: 25,
        rewardCoins: 60,
      ),
      DailyQuest(
        id: 'dq_win_levels',
        title: 'Stage Winner',
        description: 'Win 2 levels with 3 stars',
        icon: Icons.emoji_events_rounded,
        targetValue: 2,
        rewardCoins: 80,
      ),
      DailyQuest(
        id: 'dq_use_booster',
        title: 'Special Agent',
        description: 'Use any booster in gameplay',
        icon: Icons.bolt_rounded,
        targetValue: 1,
        rewardCoins: 50,
      ),
    ]);
  }

  void updateQuestProgress(String id, int increment) {
    final idx = _dailyQuests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final q = _dailyQuests[idx];
      if (!q.isCompleted) {
        q.currentValue = (q.currentValue + increment).clamp(0, q.targetValue);
        notifyListeners();
      }
    }
  }

  Future<bool> claimDailyQuest(String id) async {
    final idx = _dailyQuests.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final q = _dailyQuests[idx];
      if (q.isCompleted && !q.isClaimed) {
        q.isClaimed = true;
        await addCoins(q.rewardCoins);
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
