import 'package:audioplayers/audioplayers.dart';
import '../constants/audio_assets.dart';
import 'storage_service.dart';

class AudioService {
  final StorageService _storage;

  AudioPlayer? _bgmPlayer;
  final List<AudioPlayer> _sfxPool = [];
  int _sfxPoolIndex = 0;
  static const int _poolSize = 8;

  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.6;
  double _sfxVolume = 0.8;
  String? _currentBgmTrack;

  AudioService(this._storage);

  Future<void> init() async {
    _musicVolume = _storage.getMusicVolume();
    _sfxVolume = _storage.getSfxVolume();
    _isMusicEnabled = _storage.getMusicEnabled();
    _isSfxEnabled = _storage.getSfxEnabled();

    try {
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer?.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer?.setVolume(_isMusicEnabled ? _musicVolume : 0.0);

      // Initialize SFX pool for polyphonic rapid sound effects
      for (int i = 0; i < _poolSize; i++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        _sfxPool.add(p);
      }
    } catch (_) {
      // Audio fallback: silence on environments without native audio device
    }
  }

  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Background Music
  Future<void> playMenuMusic() async {
    await _playBgm(AudioAssets.menuMusic);
  }

  Future<void> playGameMusic() async {
    await _playBgm(AudioAssets.gameplayMusic);
  }

  Future<void> _playBgm(String assetPath) async {
    if (_currentBgmTrack == assetPath && _bgmPlayer?.state == PlayerState.playing) {
      return;
    }
    _currentBgmTrack = assetPath;
    if (!_isMusicEnabled || _bgmPlayer == null) return;

    try {
      await _bgmPlayer?.stop();
      await _bgmPlayer?.setVolume(_musicVolume);
      await _bgmPlayer?.play(AssetSource(assetPath));
    } catch (_) {
      // Graceful error handling
    }
  }

  Future<void> stopMusic() async {
    try {
      await _bgmPlayer?.stop();
      _currentBgmTrack = null;
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _bgmPlayer?.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled && _bgmPlayer != null && _currentBgmTrack != null) {
      try {
        await _bgmPlayer?.resume();
      } catch (_) {}
    }
  }

  // Sound Effects
  Future<void> playPop({int combo = 1}) async {
    // Pitch increases with combo level for that satisfying arcade escalation!
    final rate = (1.0 + (combo - 1) * 0.08).clamp(1.0, 1.8);
    await _playSfx(AudioAssets.pop, playbackRate: rate);
  }

  Future<void> playLaunch() async => await _playSfx(AudioAssets.launch);
  Future<void> playBounce() async => await _playSfx(AudioAssets.bounce);
  Future<void> playCombo() async => await _playSfx(AudioAssets.combo);
  Future<void> playBomb() async => await _playSfx(AudioAssets.bomb);
  Future<void> playLightning() async => await _playSfx(AudioAssets.lightning);
  Future<void> playFire() async => await _playSfx(AudioAssets.fire);
  Future<void> playRainbow() async => await _playSfx(AudioAssets.rainbow);
  Future<void> playClick() async => await _playSfx(AudioAssets.click);
  Future<void> playStar() async => await _playSfx(AudioAssets.star);
  Future<void> playVictory() async => await _playSfx(AudioAssets.victory);
  Future<void> playGameOver() async => await _playSfx(AudioAssets.gameOver);

  Future<void> _playSfx(String assetPath, {double playbackRate = 1.0}) async {
    if (!_isSfxEnabled || _sfxPool.isEmpty) return;

    try {
      final player = _sfxPool[_sfxPoolIndex];
      _sfxPoolIndex = (_sfxPoolIndex + 1) % _sfxPool.length;

      await player.stop();
      await player.setVolume(_sfxVolume);
      await player.setPlaybackRate(playbackRate);
      await player.play(AssetSource(assetPath));
    } catch (_) {
      // Audio driver non-fatal exception
    }
  }

  // Volume & Toggle Settings
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _storage.saveMusicVolume(_musicVolume);
    if (_isMusicEnabled) {
      try {
        await _bgmPlayer?.setVolume(_musicVolume);
      } catch (_) {}
    }
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _storage.saveSfxVolume(_sfxVolume);
  }

  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    await _storage.saveMusicEnabled(_isMusicEnabled);
    if (_isMusicEnabled) {
      if (_currentBgmTrack != null) {
        await _bgmPlayer?.setVolume(_musicVolume);
        await _bgmPlayer?.resume();
      } else {
        await playMenuMusic();
      }
    } else {
      await _bgmPlayer?.pause();
    }
  }

  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    await _storage.saveSfxEnabled(_isSfxEnabled);
  }

  void dispose() {
    _bgmPlayer?.dispose();
    for (final p in _sfxPool) {
      p.dispose();
    }
    _sfxPool.clear();
  }
}
