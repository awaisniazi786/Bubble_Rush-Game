import 'package:flutter/material.dart';
import '../../core/constants/game_colors.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color glowColor;
  final double width;
  final double height;
  final double fontSize;
  final bool isSecondary;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.gradient,
    this.glowColor = GameColors.neonCyan,
    this.width = double.infinity,
    this.height = 54.0,
    this.fontSize = 18.0,
    this.isSecondary = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    final defaultGrad = widget.gradient ??
        (widget.isSecondary
            ? LinearGradient(
                colors: [
                  const Color(0xFF1E1538).withValues(alpha: 0.9),
                  const Color(0xFF140D2A).withValues(alpha: 0.9),
                ],
              )
            : GameColors.playButtonGradient);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _animController.forward() : null,
        onTapUp: isEnabled
            ? (_) {
                _animController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: isEnabled ? () => _animController.reverse() : null,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isEnabled ? defaultGrad : null,
            color: isEnabled ? null : Colors.white10,
            borderRadius: BorderRadius.circular(28.0),
            border: Border.all(
              color: isEnabled
                  ? (widget.isSecondary
                      ? widget.glowColor.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.7))
                  : Colors.white24,
              width: 1.8,
            ),
            boxShadow: isEnabled
                ? [
                    BoxWeighting.glow(
                      widget.glowColor.withValues(alpha: widget.isSecondary ? 0.3 : 0.6),
                      blur: widget.isSecondary ? 10 : 20,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: isEnabled ? Colors.white : Colors.white38,
                    size: widget.fontSize * 1.2,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w800,
                    color: isEnabled ? Colors.white : Colors.white38,
                    letterSpacing: 1.2,
                    shadows: isEnabled
                        ? [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BoxWeighting {
  static BoxShadow glow(Color color, {double blur = 16}) {
    return BoxShadow(
      color: color,
      blurRadius: blur,
      spreadRadius: 1,
      offset: Offset.zero,
    );
  }
}
