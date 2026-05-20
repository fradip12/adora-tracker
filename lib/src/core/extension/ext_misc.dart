import 'dart:ui';

extension MiscColorX on Color {
  Color withOpacityPercent(double percent) {
    int alpha = (255 * (percent / 100)).toInt();
    return withAlpha(alpha);
  }
}

String buildTrackingStatusText({
  required bool backgroundTracking,
  required bool terminatedState,
}) {
  final parts = <String>['Tracking active'];
  if (backgroundTracking) parts.add('background ON');
  if (terminatedState) parts.add('continues after close');
  return parts.join(' · ');
}
