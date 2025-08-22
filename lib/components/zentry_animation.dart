import 'package:flutter/material.dart';

class ZentryAnimation extends StatefulWidget {
  final double size;

  const ZentryAnimation({super.key, this.size = 200});

  @override
  State<ZentryAnimation> createState() => _ZentryAnimationState();
}

class _ZentryAnimationState extends State<ZentryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ZentryPainter(glowValue: _glowAnimation.value),
          );
        },
      ),
    );
  }
}

class _ZentryPainter extends CustomPainter {
  final double glowValue;

  _ZentryPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width * 0.4;

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(
              const Color(0xFFFFD700), const Color(0xFFFFA500), glowValue)!,
          Colors.orangeAccent.withValues(alpha: 0.7 * glowValue),
          Colors.transparent,
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * glowValue);

    canvas.drawCircle(center, maxRadius, corePaint);

    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8 * glowValue),
          Colors.orange.withValues(alpha: 0.0),
        ],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glowValue);

    canvas.drawCircle(center, maxRadius * 0.8, ringPaint);

    final coreCenterPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowValue);

    canvas.drawCircle(center, maxRadius * 0.25, coreCenterPaint);
  }

  @override
  bool shouldRepaint(covariant _ZentryPainter oldDelegate) {
    return oldDelegate.glowValue != glowValue;
  }
}
