import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../settings/enums/tracking_interval.dart';

abstract class TrackerService {
  bool get supportsTerminatedState;

  String buildStatusText({
    required bool backgroundTracking,
    required bool terminatedState,
  });

  Future<ServiceRequestResult> start(
    int sessionId,
    TrackingInterval interval, {
    required bool backgroundTracking,
    required bool terminatedState,
  });

  Future<ServiceRequestResult> stop();

  Future<void> updateNotification(String text);
}
