import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/tracker/services/android_tracker_service.dart';
import '../../data/tracker/services/ios_tracker_service.dart';
import '../../data/tracker/services/tracker_service.dart';

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  TrackerService get trackerService =>
      Platform.isIOS ? IosTrackerService() : AndroidTrackerService();
}
