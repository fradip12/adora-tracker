import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/app_locale_option.dart';
import '../enums/tracking_interval.dart';

@singleton
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyInterval = 'settings_interval';
  static const _keyBgTracking = 'settings_bg_tracking';
  static const _keyTerminatedState = 'settings_terminated_state';
  static const _keyPersistentNotif = 'settings_persistent_notif';
  static const _keyLocale = 'settings_locale';
  static const _keyIsTracking = 'tracker_is_tracking';
  static const _keyOnboardingDone = 'onboarding_done';

  TrackingInterval get interval =>
      .fromPrefValue(_prefs.getString(_keyInterval) ?? '');

  /// Getter
  bool get backgroundTracking => _prefs.getBool(_keyBgTracking) ?? true;
  bool get terminatedState => _prefs.getBool(_keyTerminatedState) ?? false;
  bool get onboardingDone => _prefs.getBool(_keyOnboardingDone) ?? false;
  bool get isTracking => _prefs.getBool(_keyIsTracking) ?? false;
  bool get persistentNotification =>
      _prefs.getBool(_keyPersistentNotif) ?? true;
  AppLocaleOption get locale =>
      .fromPrefValue(_prefs.getString(_keyLocale) ?? '');

  /// Setter
  Future<void> setInterval(TrackingInterval v) =>
      _prefs.setString(_keyInterval, v.prefValue);
  Future<void> setBackgroundTracking(bool v) =>
      _prefs.setBool(_keyBgTracking, v);
  Future<void> setTerminatedState(bool v) =>
      _prefs.setBool(_keyTerminatedState, v);
  Future<void> setPersistentNotification(bool v) =>
      _prefs.setBool(_keyPersistentNotif, v);
  Future<void> setIsTracking(bool v) => _prefs.setBool(_keyIsTracking, v);
  Future<void> setOnboardingDone() => _prefs.setBool(_keyOnboardingDone, true);
  Future<void> setLocale(AppLocaleOption v) =>
      _prefs.setString(_keyLocale, v.prefValue);
}
