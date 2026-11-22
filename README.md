# ⚡ BUBBLE RUSH — Premium Neon Arcade Game

A complete, production-quality, high-performance arcade bubble shooter built with **Flutter & Dart**. Features a futuristic neon aesthetic, custom physics & raycast aiming, polyphonic audio system, 16 worlds with **800 fully-validated playable levels**, special power-up boosters, offline local persistence, daily rewards, achievements, and VIP particle effects.

---

## 🌟 Game Highlights

- **Futuristic Neon Visuals**: Deep midnight-blue backgrounds (`#090B1A`), electric cyan, hot magenta, radiant gold, glassmorphic panels, and glowing 3D spherical bubbles.
- **Precision Hexagonal Bubble Physics**:
  - Accurate staggered hexagonal grid (8 columns on even rows, 7 columns on odd rows).
  - Real-time raycast trajectory with multi-wall bounces and landing reticle.
  - Sub-pixel grid snap and collision detection.
  - Match-3+ flood fill popping algorithms.
  - BFS ceiling-connectivity detection: detached/floating bubbles drop with gravity acceleration for massive score multipliers!
- **Exactly 800 Designed Levels**:
  - 16 distinct Sectors/Worlds (50 levels per world).
  - Deterministic data-driven progression curve with milestone Boss levels every 50 levels.
  - 100% verified and validated by automated test suites.
- **Power Boosters & Special Bubbles**:
  - **Bomb**: 3x3 blast radius detonation with shockwave particles.
  - **Rainbow**: Chromatic bubble that matches and triggers any adjacent color cluster.
  - **Lightning**: Pierces and vaporizes entire horizontal rows.
  - **Fire Ball**: Blazes straight up, destroying all bubbles in its path.
  - **Super Aim**: Extends trajectory lines across 4 wall bounces.
  - **Color Swap**: Tap the preview bubble or swap button to swap shooter bubbles.
  - **Extra Shots**: Emergency +5 shots to save challenging runs.
- **Complete Audio System**:
  - Built-in 14 audio assets (looping menu synthwave, energetic gameplay track, bubble launch, pop, wall bounce, combo chimes, explosions, lightning zaps, fire whoosh, victory fanfare, game over).
  - Polyphonic sound effects pool with pitch scaling for combo streaks.
  - Independent music and SFX volume sliders + mute toggles.
  - Automatic pause/resume when backgrounding the app.
- **Player Progression & Offline Persistence**:
  - Local save with `SharedPreferences` for stars, high scores, coins, boosters inventory, and unlocked levels.
  - 7-Day Daily Login Reward Calendar with timestamp protection.
  - 10 In-Game Achievements with coin claims.
  - Daily Missions system.
  - Settings with Haptic Vibration and Reduced Motion accessibility toggles.

---

## 📂 Architecture & Folder Structure

```text
bubble_rush/
├── assets/
│   └── audio/                       # 14 Real 16-bit PCM WAV audio files
│       ├── pop.wav, launch.wav, bounce.wav, combo.wav, bomb.wav
│       ├── lightning.wav, fire.wav, rainbow.wav, click.wav, star.wav
│       ├── victory.wav, game_over.wav, menu_music.wav, gameplay_music.wav
├── lib/
│   ├── main.dart                    # App entry point, lifecycle observer & theme
│   ├── core/
│   │   ├── constants/
│   │   │   ├── game_colors.dart     # Neon arcade palette, gradients & shadows
│   │   │   └── audio_assets.dart    # Audio file paths
│   │   ├── models/
│   │   │   ├── bubble.dart          # Bubble model, types, and colors
│   │   │   ├── booster.dart         # Booster enum, descriptions, icons, costs
│   │   │   ├── level_data.dart      # Level metadata and star calculation
│   │   │   ├── achievement.dart     # Achievement definitions & progress tracking
│   │   │   └── daily_reward.dart    # 7-day reward calendar & daily quests
│   │   ├── services/
│   │   │   ├── storage_service.dart # Local persistence via SharedPreferences
│   │   │   ├── audio_service.dart   # Polyphonic SFX & BGM audio manager
│   │   │   └── progress_service.dart# Central player state & economy provider
│   │   └── generators/
│   │       └── level_generator.dart # 800-level deterministic generator & patterns
│   ├── game/
│   │   ├── hex_grid.dart            # Hexagonal math, neighbors, match-3, floating drops
│   │   ├── physics.dart             # Raycasting, wall reflection, snap collision
│   │   └── particle_system.dart     # Pops, shockwaves, confetti, floating numbers
│   └── ui/
│       ├── widgets/
│       │   ├── bubble_widget.dart   # 3D glossy bubble CustomPainter
│       │   ├── trajectory_painter.dart # Aiming laser & target reticle painter
│       │   ├── particle_painter.dart# CustomPainter for 60 FPS visual effects
│       │   ├── neon_button.dart     # Tactile neon glass button with spring scale
│       │   ├── glass_panel.dart     # Frosted glass panel with backdrop blur
│       │   └── star_rating_bar.dart # 3-star rating display
│       ├── dialogs/
│       │   ├── pause_dialog.dart    # Pause menu with audio toggles
│       │   ├── victory_dialog.dart  # Win screen with stars & coin rewards
│       │   ├── game_over_dialog.dart# Out-of-shots dialog with retry / +5 shots
│       │   ├── daily_rewards_dialog.dart # 7-day claimable calendar
│       │   ├── achievements_dialog.dart  # Badges & coin claims
│       │   ├── daily_quests_dialog.dart  # Daily missions
│       │   ├── settings_dialog.dart # Sliders, mute toggles, data reset
│       │   └── how_to_play_dialog.dart   # Illustrated game instructions
│       └── screens/
│           ├── splash_screen.dart   # Cinematic animated welcome screen
│           ├── home_screen.dart     # Main arcade lobby
│           ├── level_select_screen.dart # 800 levels map across 16 sectors
│           └── gameplay_screen.dart # Core 60 FPS playable shooter engine
├── test/
│   └── widget_test.dart             # Unit test suite verifying all 800 levels & physics
├── tool/
│   ├── generate_audio.dart          # Audio synthesis script for game sounds
│   └── validate_levels.dart         # Standalone level validator
└── pubspec.yaml                     # Dependencies and asset declarations
```

---

## 🚀 How to Run the Game

### Prerequisites
1. **Flutter SDK**: Version 3.16+ (tested on Flutter 3.44.4 / Dart 3.12.2).
2. **Android Studio** or VS Code with Flutter extension.
3. **Android Device** or **Android Emulator** (API 24+ recommended).

### Running in Android Studio / Terminal
```bash
# 1. Clone or open the repository
cd bubble_rush

# 2. Get dependencies
flutter pub get

# 3. Check for errors
flutter analyze

# 4. Run the comprehensive test suite (validates all 800 levels)
flutter test

# 5. Launch the game on connected Android device or Emulator
flutter run
```

### Running on Android Emulator
1. Open **Android Studio** -> **Device Manager** -> Start any Android Virtual Device (AVD).
2. Run `flutter run -d android` in your terminal.
3. The game will launch in portrait mode with smooth 60 FPS rendering.

---

## 🎮 How to Play

1. **Aim**: Touch and drag anywhere on the screen. The neon trajectory laser will show the flight path including wall reflections and indicate the exact landing bubble position.
2. **Shoot**: Release your finger to fire the bubble into the cluster.
3. **Match 3**: Connect 3 or more bubbles of the same color to pop them.
4. **Combos**: Make consecutive matches to build your combo multiplier up to 6x+ for massive high scores.
5. **Drop Floating Bubbles**: Sever the connection between ceiling anchor bubbles and clusters below to make disconnected bubbles drop off-screen for huge bonus points!
6. **Use Boosters**: Tap the booster icons at the bottom (Bomb, Rainbow, Lightning, Fire, Super Aim) before shooting to activate their special powers.

---

## 🛠️ Adding or Customizing Levels

All 800 levels are generated deterministically in [level_generator.dart](file:///e:/bubble_rush/lib/core/generators/level_generator.dart).

To add more levels (e.g. increase to 1,000 levels):
1. In `level_generator.dart`, update `static const int totalLevels = 1000;`.
2. Add new world names to `worldNames` (each world encompasses 50 levels).
3. The layout patterns (`_shouldPlaceBubble`) and color progression automatically scale with `levelNumber`.
4. Run `flutter test` to automatically validate that all new levels are non-empty, have valid colors, valid bounds, and valid star scores!
