import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/config/app_di.dart';
import '../../../core/data/database/app_database.dart';
import '../enums/gps_accuracy.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationForegroundTask());
}

class LocationForegroundTask extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await configureDependencies();
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    try {
      final sessionIdStr =
          await FlutterForegroundTask.getData<String>(key: 'session_id');
      if (sessionIdStr == null) return;
      final sessionId = int.parse(sessionIdStr);

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

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
