import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../../core/extension/ext_misc.dart';
import '../../settings/enums/tracking_interval.dart';
import '../workers/location_foreground_task.dart';
import 'tracker_service.dart';

class AndroidTrackerService implements TrackerService {
  @override
  bool get supportsTerminatedState => true;

  void _configure({
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
        allowWifiLock: true,
      ),
    );
  }

  @override
  String buildStatusText({
    required bool backgroundTracking,
    required bool terminatedState,
  }) => buildTrackingStatusText(
    backgroundTracking: backgroundTracking,
    terminatedState: terminatedState,
  );

  @override
  Future<ServiceRequestResult> start(
    int sessionId,
    TrackingInterval interval, {
    required bool backgroundTracking,
    required bool terminatedState,
  }) async {
    await FlutterForegroundTask.requestNotificationPermission();
    _configure(interval: interval, terminatedState: terminatedState);
    await FlutterForegroundTask.saveData(
      key: kSessionIdKey,
      value: sessionId.toString(),
    );
    await FlutterForegroundTask.saveData(
      key: kIntervalMsKey,
      value: interval.duration.inMilliseconds,
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

  @override
  Future<ServiceRequestResult> stop() => FlutterForegroundTask.stopService();

  @override
  Future<void> updateNotification(String text) =>
      FlutterForegroundTask.updateService(notificationText: text);
}
