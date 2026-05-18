import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../settings/enums/tracking_interval.dart';
import '../workers/location_foreground_task.dart';

class LocationForegroundService {
  static void _configure({
    required TrackingInterval interval,
    required bool terminatedState,
  }) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'adora_tracking',
        channelName: 'Adora Tracking',
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(
          interval.duration.inMilliseconds,
        ),
        autoRunOnBoot: terminatedState,
      ),
    );
  }

  static String buildStatusText({
    required bool backgroundTracking,
    required bool terminatedState,
  }) {
    final parts = <String>['Tracking active'];
    if (backgroundTracking) parts.add('background ON');
    if (terminatedState) parts.add('continues after close');
    return parts.join(' · ');
  }

  static Future<ServiceRequestResult> start(
    int sessionId,
    TrackingInterval interval, {
    required bool backgroundTracking,
    required bool terminatedState,
  }) async {
    await FlutterForegroundTask.requestNotificationPermission();
    _configure(interval: interval, terminatedState: terminatedState);
    await FlutterForegroundTask.saveData(
      key: 'session_id',
      value: sessionId.toString(),
    );
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Adora',
      notificationText: buildStatusText(
        backgroundTracking: backgroundTracking,
        terminatedState: terminatedState,
      ),
      callback: startCallback,
    );
  }

  static Future<void> updateNotification(String text) =>
      FlutterForegroundTask.updateService(notificationText: text);

  static Future<ServiceRequestResult> stop() =>
      FlutterForegroundTask.stopService();
}
