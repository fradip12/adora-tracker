import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_di.dart';
import '../../../core/data/database/app_database.dart';
import '../enums/gps_accuracy.dart';

const String kSessionIdKey = 'session_id';
const String kIntervalMsKey = 'interval_ms';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationForegroundTask());
}

class LocationForegroundTask extends TaskHandler {
  int? _sessionId;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // iOS location is driven from the main isolate by LocationForegroundService
    // because the secondary Flutter engine requires native plugin-registrant
    // wiring and is unreliable for CLLocationManager streams.
    if (Platform.isIOS) return;

    await configureDependencies();
    final sessionIdStr = await FlutterForegroundTask.getData<String>(
      key: kSessionIdKey,
    );
    if (sessionIdStr != null) _sessionId = int.tryParse(sessionIdStr);
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    if (Platform.isIOS) return;
    final sessionId = _sessionId;
    if (sessionId == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      final accuracy = GpsAccuracy.fromMeters(position.accuracy);
      await locator<AppDatabase>().insertCoordinate(
        parentId: sessionId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy.name,
      );
    } catch (_) {}
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}
