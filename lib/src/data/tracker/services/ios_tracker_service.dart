import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_di.dart';
import '../../../core/data/database/app_database.dart';
import '../../../core/extension/ext_misc.dart';
import '../../settings/enums/tracking_interval.dart';
import '../enums/gps_accuracy.dart';
import '../workers/location_foreground_task.dart';
import 'tracker_service.dart';

class IosTrackerService implements TrackerService {
  StreamSubscription<Position>? _sub;
  int? _sessionId;
  Duration _interval = const Duration(seconds: 5);
  DateTime _lastInsertAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  bool get supportsTerminatedState => false;

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
        allowWifiLock: true,
      ),
    );
    await FlutterForegroundTask.saveData(
      key: kSessionIdKey,
      value: sessionId.toString(),
    );
    await FlutterForegroundTask.saveData(
      key: kIntervalMsKey,
      value: interval.duration.inMilliseconds,
    );

    await _startStream(sessionId, interval);

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
  Future<ServiceRequestResult> stop() async {
    await _stopStream();
    return FlutterForegroundTask.stopService();
  }

  @override
  Future<void> updateNotification(String text) =>
      FlutterForegroundTask.updateService(notificationText: text);

  Future<void> _startStream(int sessionId, TrackingInterval interval) async {
    await _sub?.cancel();
    _sessionId = sessionId;
    _interval = interval.duration;
    _lastInsertAt = DateTime.fromMillisecondsSinceEpoch(0);
    _sub = Geolocator.getPositionStream(
      locationSettings: AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        showBackgroundLocationIndicator: true,
      ),
    ).listen(_onPosition, onError: (_) {});
  }

  Future<void> _stopStream() async {
    await _sub?.cancel();
    _sub = null;
    _sessionId = null;
  }

  Future<void> _onPosition(Position position) async {
    final now = DateTime.now();
    if (now.difference(_lastInsertAt) < _interval) return;
    _lastInsertAt = now;
    final sessionId = _sessionId;
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
