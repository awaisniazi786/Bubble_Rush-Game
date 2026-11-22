import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/game_colors.dart';
import 'core/services/audio_service.dart';
import 'core/services/progress_service.dart';
import 'core/services/storage_service.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for optimal mobile arcade experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Immersive edge-to-edge transparent system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  final storageService = StorageService();
  await storageService.init();

  final audioService = AudioService(storageService);
  await audioService.init();

  final progressService = ProgressService(storageService);
  await progressService.init();

  runApp(
    BubbleRushApp(
      storageService: storageService,
      audioService: audioService,
      progressService: progressService,
    ),
  );
}

class BubbleRushApp extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final ProgressService progressService;

  const BubbleRushApp({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.progressService,
  });

  @override
  State<BubbleRushApp> createState() => _BubbleRushAppState();
}

class _BubbleRushAppState extends State<BubbleRushApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.audioService.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      widget.audioService.resumeMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Rush',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.background,
        colorScheme: const ColorScheme.dark(
          primary: GameColors.neonCyan,
          secondary: GameColors.neonPurple,
          surface: GameColors.panelGlass,
        ),
        textTheme: ThemeData.dark().textTheme,
      ),
      builder: (context, child) => Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: child ?? const SizedBox.shrink())),
      home: SplashScreen(
        audioService: widget.audioService,
        progressService: widget.progressService,
      ),
    );
  }
}
