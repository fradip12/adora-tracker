import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../settings/enums/tracking_interval.dart';
import '../workers/location_foreground_task.dart';

class LocationForegroundService {
  static void _configure(TrackingInterval interval) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'adaro_tracking',
        channelName: 'Adaro Tracking',
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction:
            ForegroundTaskEventAction.repeat(interval.duration.inMilliseconds),
      ),
    );
  }

  static Future<ServiceRequestResult> start(
    int sessionId,
    TrackingInterval interval,
  ) async {
    _configure(interval);
    await FlutterForegroundTask.saveData(
      key: 'session_id',
      value: sessionId.toString(),
    );
    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Adaro',
      notificationText: 'Location tracking is active',
      callback: startCallback,
    );
  }

  static Future<ServiceRequestResult> stop() =>
      FlutterForegroundTask.stopService();
}
