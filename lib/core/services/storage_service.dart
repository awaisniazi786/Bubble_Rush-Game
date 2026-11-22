import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booster.dart';

class StorageService {
  static const String _keyUnlockedLevel = 'unlocked_level';
  static const String _keyCoins = 'coins';
  static const String _keyStars = 'stars_map';
  static const String _keyHighScores = 'high_scores_map';
  static const String _keyBoosters = 'boosters_inventory';
  static const String _keyMusicVolume = 'music_volume';
  static const String _keySfxVolume = 'sfx_volume';
  static const String _keyMusicEnabled = 'music_enabled';
  static const String _keySfxEnabled = 'sfx_enabled';
  static const String _keyVibrationEnabled = 'vibration_enabled';
  static const String _keyReducedMotion = 'reduced_motion';
  static const String _keyLastRewardDate = 'last_reward_date';
  static const String _keyRewardStreak = 'reward_streak';
  static const String _keyAchievements = 'achievements_data';
  static const String _keyTotalPops = 'total_pops';
  static const String _keyTotalScore = 'total_score';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Level Progression
  int getUnlockedLevel() => _prefs.getInt(_keyUnlockedLevel) ?? 1;
  Future<void> saveUnlockedLevel(int level) async {
    if (level > getUnlockedLevel()) {
      await _prefs.setInt(_keyUnlockedLevel, level);
    }
  }

  // Coins
  int getCoins() => _prefs.getInt(_keyCoins) ?? 300;
  Future<void> saveCoins(int coins) async => await _prefs.setInt(_keyCoins, coins);

  // Stars Map: level -> stars (0..3)
  Map<int, int> getStarsMap() {
    final raw = _prefs.getString(_keyStars);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveStars(int level, int stars) async {
    final map = getStarsMap();
    if ((map[level] ?? 0) < stars) {
      map[level] = stars;
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(_keyStars, encoded);
    }
  }

  // High Scores Map: level -> score
  Map<int, int> getHighScores() {
    final raw = _prefs.getString(_keyHighScores);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveHighScore(int level, int score) async {
    final map = getHighScores();
    if ((map[level] ?? 0) < score) {
      map[level] = score;
      final encoded = jsonEncode(map.map((k, v) => MapEntry(k.toString(), v)));
      await _prefs.setString(_keyHighScores, encoded);
    }
  }

  // Boosters Inventory
  Map<BoosterType, int> getBoosters() {
    final raw = _prefs.getString(_keyBoosters);
    final defaults = {
      BoosterType.bomb: 2,
      BoosterType.rainbow: 1,
      BoosterType.lightning: 1,
      BoosterType.fire: 1,
      BoosterType.aimExtension: 2,
      BoosterType.extraShots: 2,
      BoosterType.colorSwap: 3,
      BoosterType.slowMotion: 1,
    };
    if (raw == null) return defaults;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final result = <BoosterType, int>{};
      for (final type in BoosterType.values) {
        result[type] = decoded[type.name] as int? ?? defaults[type] ?? 0;
      }
      return result;
    } catch (_) {
      return defaults;
    }
  }

  Future<void> saveBoosters(Map<BoosterType, int> boosters) async {
    final map = boosters.map((k, v) => MapEntry(k.name, v));
    await _prefs.setString(_keyBoosters, jsonEncode(map));
  }

  // Audio & Settings
  double getMusicVolume() => _prefs.getDouble(_keyMusicVolume) ?? 0.6;
  Future<void> saveMusicVolume(double val) async => await _prefs.setDouble(_keyMusicVolume, val);

  double getSfxVolume() => _prefs.getDouble(_keySfxVolume) ?? 0.8;
  Future<void> saveSfxVolume(double val) async => await _prefs.setDouble(_keySfxVolume, val);

  bool getMusicEnabled() => _prefs.getBool(_keyMusicEnabled) ?? true;
  Future<void> saveMusicEnabled(bool val) async => await _prefs.setBool(_keyMusicEnabled, val);

  bool getSfxEnabled() => _prefs.getBool(_keySfxEnabled) ?? true;
  Future<void> saveSfxEnabled(bool val) async => await _prefs.setBool(_keySfxEnabled, val);

  bool getVibrationEnabled() => _prefs.getBool(_keyVibrationEnabled) ?? true;
  Future<void> saveVibrationEnabled(bool val) async => await _prefs.setBool(_keyVibrationEnabled, val);

  bool getReducedMotion() => _prefs.getBool(_keyReducedMotion) ?? false;
  Future<void> saveReducedMotion(bool val) async => await _prefs.setBool(_keyReducedMotion, val);

  // Daily Rewards
  String? getLastRewardDate() => _prefs.getString(_keyLastRewardDate);
  Future<void> saveLastRewardDate(String date) async => await _prefs.setString(_keyLastRewardDate, date);

  int getRewardStreak() => _prefs.getInt(_keyRewardStreak) ?? 0;
  Future<void> saveRewardStreak(int streak) async => await _prefs.setInt(_keyRewardStreak, streak);

  // Achievements
  Map<String, dynamic> getAchievementsData() {
    final raw = _prefs.getString(_keyAchievements);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveAchievementsData(Map<String, dynamic> data) async {
    await _prefs.setString(_keyAchievements, jsonEncode(data));
  }

  // Statistics
  int getTotalPops() => _prefs.getInt(_keyTotalPops) ?? 0;
  Future<void> incrementTotalPops(int count) async => await _prefs.setInt(_keyTotalPops, getTotalPops() + count);

  int getTotalScore() => _prefs.getInt(_keyTotalScore) ?? 0;
  Future<void> addTotalScore(int score) async => await _prefs.setInt(_keyTotalScore, getTotalScore() + score);

  // Reset Progress
  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
