import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_di.dart';
import '../../../core/data/database/app_database.dart';
import '../../settings/enums/tracking_interval.dart';
import '../enums/gps_accuracy.dart';
import '../workers/location_foreground_task.dart';

class LocationForegroundService {
  static bool get supportsTerminatedState => !Platform.isIOS;

  static StreamSubscription<Position>? _iosSub;
  static int? _iosSessionId;
  static Duration _iosInterval = const Duration(seconds: 5);
  static DateTime _iosLastInsertAt = DateTime.fromMillisecondsSinceEpoch(0);

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
        autoRunOnBoot: terminatedState && !Platform.isIOS,
        allowWifiLock: true,
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
    _configure(
      interval: interval,
      terminatedState: terminatedState && supportsTerminatedState,
    );
    await FlutterForegroundTask.saveData(
      key: kSessionIdKey,
      value: sessionId.toString(),
    );
    await FlutterForegroundTask.saveData(
      key: kIntervalMsKey,
      value: interval.duration.inMilliseconds,
    );

    if (Platform.isIOS) {
      await _startIosStream(sessionId, interval);
    }

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

  static Future<ServiceRequestResult> stop() async {
    await _stopIosStream();
    return FlutterForegroundTask.stopService();
  }

  static Future<void> _startIosStream(
    int sessionId,
    TrackingInterval interval,
  ) async {
    await _iosSub?.cancel();
    _iosSessionId = sessionId;
    _iosInterval = interval.duration;
    _iosLastInsertAt = DateTime.fromMillisecondsSinceEpoch(0);
    _iosSub = Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        showBackgroundLocationIndicator: true,
      ),
    ).listen(_onIosPosition, onError: (_) {});
  }

  static Future<void> _stopIosStream() async {
    await _iosSub?.cancel();
    _iosSub = null;
    _iosSessionId = null;
  }

  static Future<void> _onIosPosition(Position position) async {
    final now = DateTime.now();
    if (now.difference(_iosLastInsertAt) < _iosInterval) return;
    _iosLastInsertAt = now;
    final sessionId = _iosSessionId;
    if (sessionId == null) return;
    try {
      final accuracy = GpsAccuracy.fromMeters(position.accuracy);
      await locator<AppDatabase>().insertCoordinate(
        parentId: sessionId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy.name,
      );
    } catch (_) {}
  }
}
