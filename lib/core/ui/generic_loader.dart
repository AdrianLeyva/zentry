import 'dart:math';

import 'package:flutter/material.dart';

class GenericLoader extends StatefulWidget {
  final double size;
  final String loadingText;

  const GenericLoader({
    super.key,
    this.size = 150,
    this.loadingText = 'SCANNING...',
  });

  @override
  State<GenericLoader> createState() => _GenericLoaderState();
}

class _GenericLoaderState extends State<GenericLoader>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorPrimary = theme.colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationController, _glowController]),
        builder: (context, child) {
          return CustomPaint(
            painter: _CyberSecurityPainter(
              _rotationController.value,
              glowValue: _glowAnimation.value,
              text: widget.loadingText,
              color: colorPrimary,
              textColor: colorPrimary,
            ),
          );
        },
      ),
    );
  }
}

class _CyberSecurityPainter extends CustomPainter {
  final double progress;
  final double glowValue;
  final String text;
  final Color color;
  final Color textColor;

  late final Paint _circlePaint;

  _CyberSecurityPainter(
    this.progress, {
    required this.glowValue,
    required this.text,
    required this.color,
    required this.textColor,
  }) {
    _circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseRadius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final rotation = (progress + i / 3) * 2 * pi;
      final radius = baseRadius * (0.5 + i * 0.25);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);

      const segments = 12;
      for (int j = 0; j < segments; j++) {
        final startAngle = (2 * pi / segments) * j;
        final lineLength = 15.0;

        final offsetStart = Offset(
          cos(startAngle) * radius,
          sin(startAngle) * radius,
        );
        final offsetEnd = Offset(
          cos(startAngle) * (radius + lineLength),
          sin(startAngle) * (radius + lineLength),
        );

        canvas.drawLine(offsetStart, offsetEnd, _circlePaint);
      }

      canvas.restore();
    }

    final maxRadius = baseRadius * 0.30 * glowValue;

    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(
              const Color(0xFFFFD700), const Color(0xFFFFA500), glowValue)!,
          Colors.orangeAccent.withOpacity(0.7 * glowValue),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * glowValue);

    canvas.drawCircle(center, maxRadius, corePaint);

    final ringPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8 * glowValue),
          Colors.orange.withOpacity(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * glowValue);

    canvas.drawCircle(center, maxRadius * 0.8, ringPaint);

    final coreCenterPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowValue);

    canvas.drawCircle(center, maxRadius * 0.25, coreCenterPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final offsetText =
        Offset(center.dx - textPainter.width / 2, size.height * 0.85);
    textPainter.paint(canvas, offsetText);
  }

  @override
  bool shouldRepaint(covariant _CyberSecurityPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowValue != glowValue ||
        oldDelegate.text != text ||
        oldDelegate.color != color ||
        oldDelegate.textColor != textColor;
  }
}
