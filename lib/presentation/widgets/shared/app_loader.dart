import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AppLoader extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final String semanticsLabel;

  const AppLoader({
    super.key,
    this.size = 28,
    this.color = AppColors.primary,
    this.strokeWidth = 3,
    this.semanticsLabel = 'Loading',
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color;
    return Semantics(
      label: widget.semanticsLabel,
      liveRegion: true,
      child: SizedBox(
        height: widget.size,
        width: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = _controller.value;
            final angle = t * math.pi * 2;
            final pulse = 0.92 + 0.08 * math.sin((t * math.pi * 2));

            return Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: pulse,
                child: CustomPaint(
                  painter: _LoaderPainter(
                    progress: t,
                    color: baseColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _LoaderPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) / 2) - strokeWidth / 2;
    final circleRect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(circleRect, 0, math.pi * 2, false, backgroundPaint);

    final startAngle = -math.pi / 2 + (progress * 0.35);
    final sweepAngle = math.pi * 1.55;
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: [
        color.withValues(alpha: 0.05),
        color.withValues(alpha: 0.95),
        color.withValues(alpha: 0.12),
      ],
      stops: const [0.0, 0.55, 1.0],
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(circleRect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
