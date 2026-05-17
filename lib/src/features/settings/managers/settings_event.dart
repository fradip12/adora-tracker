part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.init() = _Init;
  const factory SettingsEvent.refreshPermissions() = _RefreshPermissions;
  const factory SettingsEvent.updateInterval(TrackingInterval interval) =
      _UpdateInterval;
  const factory SettingsEvent.toggleBackgroundTracking() =
      _ToggleBackgroundTracking;
  const factory SettingsEvent.toggleTerminatedState() = _ToggleTerminatedState;
  const factory SettingsEvent.togglePersistentNotification() =
      _TogglePersistentNotification;
  const factory SettingsEvent.changeLocale(AppLocaleOption locale) =
      _ChangeLocale;
  const factory SettingsEvent.clearData() = _ClearData;
}
