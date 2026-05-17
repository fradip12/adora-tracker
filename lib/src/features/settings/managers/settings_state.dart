part of 'settings_bloc.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = _Initial;

  const factory SettingsState.active({
    @Default(false) bool locationGranted,
    @Default(false) bool notificationGranted,
    @Default(false) bool batteryOptimizationDisabled,
    @Default(TrackingInterval.s30) TrackingInterval interval,
    @Default(true) bool backgroundTracking,
    @Default(false) bool terminatedState,
    @Default(true) bool persistentNotification,
    @Default(AppLocaleOption.english) AppLocaleOption locale,
  }) = _Active;
}
