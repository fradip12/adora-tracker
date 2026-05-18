import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../i18n/strings.g.dart';
import '../../../core/config/app_di.dart';
import '../../../core/data/database/app_database.dart';
import '../../../data/settings/enums/app_locale_option.dart';
import '../../../data/settings/enums/tracking_interval.dart';
import '../../../data/settings/services/settings_service.dart';

part 'settings_state.dart';
part 'settings_event.dart';
part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _service;

  SettingsBloc(this._service) : super(const .initial()) {
    on<_Init>(_onInit);
    on<_RefreshPermissions>(_onRefreshPermissions);
    on<_UpdateInterval>(_onUpdateInterval);
    on<_ToggleBackgroundTracking>(_onToggleBgTracking);
    on<_ToggleTerminatedState>(_onToggleTerminatedState);
    on<_TogglePersistentNotification>(_onTogglePersistentNotification);
    on<_ChangeLocale>(_onChangeLocale);
    on<_ClearData>(_onClearData);
  }

  Future<void> _onInit(_Init event, Emitter<SettingsState> emit) async {
    final locationStatus = await Permission.locationAlways.status;
    final notifStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    emit(
      .active(
        locationGranted: locationStatus.isGranted,
        notificationGranted: notifStatus.isGranted,
        batteryOptimizationDisabled: batteryStatus.isGranted,
        interval: _service.interval,
        backgroundTracking: _service.backgroundTracking,
        terminatedState: _service.terminatedState,
        persistentNotification: _service.persistentNotification,
        locale: _service.locale,
      ),
    );
  }

  Future<void> _onRefreshPermissions(
    _RefreshPermissions event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;

    final locationStatus = await Permission.locationAlways.status;
    final notifStatus = await Permission.notification.status;
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    emit(
      active.copyWith(
        locationGranted: locationStatus.isGranted,
        notificationGranted: notifStatus.isGranted,
        batteryOptimizationDisabled: batteryStatus.isGranted,
      ),
    );
  }

  Future<void> _onUpdateInterval(
    _UpdateInterval event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    await _service.setInterval(event.interval);
    emit(active.copyWith(interval: event.interval));
  }

  Future<void> _onToggleBgTracking(
    _ToggleBackgroundTracking event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    final next = !active.backgroundTracking;
    await _service.setBackgroundTracking(next);
    emit(active.copyWith(backgroundTracking: next));
  }

  Future<void> _onToggleTerminatedState(
    _ToggleTerminatedState event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    final next = !active.terminatedState;
    await _service.setTerminatedState(next);
    emit(active.copyWith(terminatedState: next));
  }

  Future<void> _onTogglePersistentNotification(
    _TogglePersistentNotification event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    final next = !active.persistentNotification;
    await _service.setPersistentNotification(next);
    emit(active.copyWith(persistentNotification: next));
  }

  Future<void> _onChangeLocale(
    _ChangeLocale event,
    Emitter<SettingsState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    await _service.setLocale(event.locale);
    LocaleSettings.setLocale(event.locale.locale);
    emit(active.copyWith(locale: event.locale));
  }

  Future<void> _onClearData(
    _ClearData event,
    Emitter<SettingsState> emit,
  ) async {
    await locator<AppDatabase>().deleteAll();
  }
}
