import 'dart:ui';

extension MiscColorX on Color {
  Color withOpacityPercent(double percent) {
    int alpha = (255 * (percent / 100)).toInt();
    return withAlpha(alpha);
  }
}
