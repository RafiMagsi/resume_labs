import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AnimatedAIButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;

  const AnimatedAIButton({
    super.key,
    required this.onPressed,
    this.size = 60,
  });

  @override
  State<AnimatedAIButton> createState() => _AnimatedAIButtonState();
}

class _AnimatedAIButtonState extends State<AnimatedAIButton>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _borderController;
  late AnimationController _iconController;

  @override
  void initState() {
    super.initState();

    // Gradient animation - smooth color transition
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Border glow animation - pulsing border effect
    _borderController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Icon animation - continuous rotation + scale
    _iconController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _borderController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _gradientController,
          _borderController,
          _iconController,
        ]),
        builder: (context, child) {
          // Gradient animation
          final gradientValue = _gradientController.value;
          final Color color1 = Color.lerp(
            AppColors.primary,
            const Color(0xFF7C3AED),
            (math.sin(gradientValue * math.pi * 2) + 1) / 2,
          )!;
          final Color color2 = Color.lerp(
            const Color(0xFF8B5CF6),
            AppColors.primary,
            (math.sin(gradientValue * math.pi * 2 + math.pi / 2) + 1) / 2,
          )!;

          // Border glow animation
          final borderValue = _borderController.value;
          final glowOpacity = (math.sin(borderValue * math.pi * 2) + 1) / 2;
          final glowWidth = 2 + (glowOpacity * 2);

          // Icon animation
          final iconValue = _iconController.value;
          final iconRotation = iconValue * math.pi * 2;
          final iconScale =
              0.9 + (math.sin(iconValue * math.pi * 2) + 1) / 4 * 0.2;

          return SizedBox(
            width: 160,
            height: widget.size,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                // Animated gradient background
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2],
                ),
                // Animated border glow
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(
                      (255 * glowOpacity * 0.6).toInt(),
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withAlpha(
                      (255 * (1 - glowOpacity) * 0.4).toInt(),
                    ),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        AppColors.white.withAlpha((glowOpacity * 180).toInt()),
                    width: glowWidth,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    Transform.rotate(
                      angle: iconRotation,
                      child: Transform.scale(
                        scale: iconScale,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomPaint(
                            painter: _GlitterStarsPainter(
                              progress: iconValue,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Text
                    const Flexible(
                      child: Text(
                        'AI Resume',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlitterStarsPainter extends CustomPainter {
  const _GlitterStarsPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawStar(
      canvas,
      center: Offset(size.width * 0.50, size.height * 0.48),
      radius: size.width * (0.29 + 0.04 * _pulse(progress)),
      opacity: 0.95,
      points: 4,
    );

    _drawStar(
      canvas,
      center: Offset(size.width * 0.78, size.height * 0.22),
      radius: size.width * (0.12 + 0.025 * _pulse(progress + 0.35)),
      opacity: 0.72,
      points: 4,
    );

    _drawStar(
      canvas,
      center: Offset(size.width * 0.22, size.height * 0.76),
      radius: size.width * (0.10 + 0.02 * _pulse(progress + 0.68)),
      opacity: 0.62,
      points: 4,
    );

    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.42 + 0.28 * _pulse(progress + 0.18))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.28),
      size.width * 0.035,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.72),
      size.width * 0.026,
      dotPaint,
    );
  }

  double _pulse(double value) {
    final normalized = value % 1;
    return (math.sin(normalized * math.pi * 2) + 1) / 2;
  }

  void _drawStar(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double opacity,
    required int points,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final innerRadius = radius * 0.28;
    final totalPoints = points * 2;

    for (var i = 0; i < totalPoints; i++) {
      final currentRadius = i.isEven ? radius : innerRadius;
      final angle = -math.pi / 2 + (math.pi * 2 * i / totalPoints);
      final point = Offset(
        center.dx + math.cos(angle) * currentRadius,
        center.dy + math.sin(angle) * currentRadius,
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlitterStarsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
