import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/data/database/app_database.dart';
import '../../../data/settings/services/settings_service.dart';
import '../../../data/tracker/enums/gps_accuracy.dart';
import '../../../data/tracker/services/location_foreground_service.dart';

part 'tracker_bloc.freezed.dart';
part 'tracker_event.dart';
part 'tracker_state.dart';

@injectable
class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final AppDatabase _db;
  final SettingsService _settings;

  StreamSubscription<List<TrackingCoordinate>>? _coordinateSub;
  StreamSubscription<Position>? _positionSub;

  TrackerBloc(this._db, this._settings) : super(const .initial()) {
    on<_Init>((event, emit) async {
      try {
        emit(const .active());
        final orphan = await _db.activeSession();
        if (orphan != null) await _resumeSession(orphan.id, emit);
      } catch (_) {
        emit(const .active());
      }
    });

    on<_ToggleTracking>((event, emit) async {
      final active = state.mapOrNull(active: (s) => s);
      if (active == null) return;

      if (active.isTracking) {
        await _stop(emit);
      } else {
        await _start(emit);
      }
    });

    on<_CoordinatesUpdated>((event, emit) {
      final coords = event.coordinates;
      if (coords.isEmpty) return;

      final last = coords.last;
      final accuracy = GpsAccuracy.values.byName(last.accuracy);

      final currentState = state.mapOrNull(active: (a) => a);
      if (currentState != null) {
        emit(
          currentState.copyWith(
            position: (
              lat: last.latitude,
              lng: last.longitude,
              accuracy: accuracy.toMeters,
            ),
            trackPoints: coords
                .map((c) => LatLng(c.latitude, c.longitude))
                .toList(),
          ),
        );
      }
    });

    on<_PositionStreamUpdate>((event, emit) {
      final currentState = state.mapOrNull(active: (a) => a);
      if (currentState == null) return;

      emit(
        currentState.copyWith(
          position: (
            lat: event.lat,
            lng: event.lng,
            accuracy: GpsAccuracy.fromMeters(event.accuracy).toMeters,
          ),
        ),
      );

      if (currentState.isTracking) {
        final statusText = LocationForegroundService.buildStatusText(
          backgroundTracking: _settings.backgroundTracking,
          terminatedState: _settings.terminatedState,
        );
        final notifText = _settings.persistentNotification
            ? '${event.lat.toStringAsFixed(5)}, ${event.lng.toStringAsFixed(5)} ±${GpsAccuracy.fromMeters(event.accuracy).toMeters.toStringAsFixed(0)}m · $statusText'
            : statusText;
        LocationForegroundService.updateNotification(notifText);
      }
    });

    on<_AppLifecycleChanged>((event, emit) async {
      final currentState = state.mapOrNull(active: (a) => a);
      if (currentState == null || !currentState.isTracking) return;

      switch (event.state) {
        case AppLifecycleState.paused:
          if (!_settings.backgroundTracking) {
            await LocationForegroundService.stop();
          }
        case AppLifecycleState.resumed:
          if (!_settings.backgroundTracking && currentState.sessionId != null) {
            await LocationForegroundService.start(
              currentState.sessionId!,
              _settings.interval,
              backgroundTracking: _settings.backgroundTracking,
              terminatedState: _settings.terminatedState,
            );
          }
        case AppLifecycleState.detached:
          if (!_settings.terminatedState) {
            await _stopSideEffects();
            emit(
              currentState.copyWith(
                isTracking: false,
                sessionId: null,
                trackPoints: [],
              ),
            );
          }
        default:
          break;
      }
    });
  }

  Future<void> _start(Emitter<TrackerState> emit) async {
    final sessionId = await _db.insertSession(DateTime.now().toIso8601String());
    await _recordCurrentPosition(sessionId);
    await _resumeSession(sessionId, emit);
  }

  Future<void> _recordCurrentPosition(int sessionId) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));
      final accuracy = GpsAccuracy.fromMeters(position.accuracy);
      await _db.insertCoordinate(
        parentId: sessionId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy.name,
      );
    } catch (_) {}
  }

  Future<void> _resumeSession(int sessionId, Emitter<TrackerState> emit) async {
    await LocationForegroundService.start(
      sessionId,
      _settings.interval,
      backgroundTracking: _settings.backgroundTracking,
      terminatedState: _settings.terminatedState,
    );

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(s.copyWith(isTracking: true, sessionId: sessionId, trackPoints: []));
    }

    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).listen((pos) {
          if (!isClosed) {
            add(
              .positionStreamUpdate(pos.latitude, pos.longitude, pos.accuracy),
            );
          }
        });

    _coordinateSub = _db.watchSession(sessionId).listen((coords) {
      if (!isClosed) add(.coordinatesUpdated(coords));
    });
  }

  Future<void> _stopSideEffects() async {
    await _coordinateSub?.cancel();
    _coordinateSub = null;
    await _positionSub?.cancel();
    _positionSub = null;

    final sessionId = state.mapOrNull(active: (a) => a)?.sessionId;
    await LocationForegroundService.stop();
    if (sessionId != null) await _db.closeSession(sessionId);
  }

  Future<void> _stop(Emitter<TrackerState> emit) async {
    final s = state.mapOrNull(active: (a) => a);
    await _stopSideEffects();
    if (s != null) {
      emit(s.copyWith(isTracking: false, sessionId: null, trackPoints: []));
    }
  }

  @override
  Future<void> close() {
    if (state.mapOrNull(active: (a) => a)?.isTracking == true) {
      _stopSideEffects();
    } else {
      _coordinateSub?.cancel();
      _positionSub?.cancel();
    }
    return super.close();
  }
}
