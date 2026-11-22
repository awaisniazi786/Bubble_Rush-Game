import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/progress_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final AudioService audioService;
  final ProgressService progressService;
  const SplashScreen({super.key, required this.audioService, required this.progressService});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _intro;
  Timer? _timer;
  bool _entered = false;
  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _timer = Timer(const Duration(milliseconds: 1800), _enter);
  }
  void _enter() {
    if (!mounted || _entered) return;
    _entered = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(transitionDuration: const Duration(milliseconds: 450), pageBuilder: (_, animation, secondary) => HomeScreen(audioService: widget.audioService, progressService: widget.progressService), transitionsBuilder: (_, animation, secondary, child) => FadeTransition(opacity: animation, child: child)));
  }
  @override
  void dispose() { _timer?.cancel(); _intro.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(body: Container(
    width: double.infinity,
    decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.2), radius: 1.1, colors: [Color(0xFF30236A), Color(0xFF080E24)])),
    child: SafeArea(child: Column(children: [
      const Spacer(flex: 3),
      FadeTransition(opacity: _intro, child: ScaleTransition(scale: Tween<double>(begin: .88, end: 1).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic)), child: Column(children: [
        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(48), boxShadow: [BoxShadow(color: const Color(0xFF734BFF).withValues(alpha: .35), blurRadius: 70, spreadRadius: 8)]), child: ClipRRect(borderRadius: BorderRadius.circular(48), child: Image.asset('assets/images/bubble_rush_icon.png', width: 180, height: 180))),
        const SizedBox(height: 26),
        const Text('BUBBLE', style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 6)),
        const Text('RUSH', style: TextStyle(fontSize: 49, height: 1, fontWeight: FontWeight.w900, letterSpacing: 9, color: Color(0xFF6CE8FF))),
        const SizedBox(height: 16),
        const Text('A LITTLE AIM. A LOT OF POP.', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.white60)),
      ]))),
      const Spacer(flex: 2),
      SizedBox(width: 180, child: AnimatedBuilder(animation: _intro, builder: (_, child) => ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _intro.value, minHeight: 5, color: const Color(0xFF6CE8FF), backgroundColor: Colors.white12)))),
      const SizedBox(height: 14),
      const Text('800 levels of colorful adventure', style: TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 36),
    ])),
  ));
}
