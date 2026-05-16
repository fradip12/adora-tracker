import 'package:flutter/material.dart';

class CRippleOverlay extends StatelessWidget {
  const CRippleOverlay({
    required this.controller,
    required this.center,
    required this.radius,
    required this.color,
    super.key,
  });

  final AnimationController controller;
  final Offset center;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, _) {
            final t = Curves.easeOutCubic.transform(controller.value);
            return CustomPaint(
              painter: _RipplePainter(
                center: center,
                maxRadius: radius,
                color: color,
                progress: t,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  _RipplePainter({
    required this.center,
    required this.maxRadius,
    required this.color,
    required this.progress,
  });

  final Offset center;
  final double maxRadius;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawCircle(center, maxRadius * progress, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.center != center ||
      old.maxRadius != maxRadius;
}
