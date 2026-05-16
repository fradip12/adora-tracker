import 'dart:ui';

class PendingRipple {
  PendingRipple({
    required this.center,
    required this.color,
    required this.radius,
  });

  final Offset center;
  final Color color;
  final double radius;
}
