import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/data/database/app_database.dart';
import '../../../data/settings/services/settings_service.dart';
import '../../../data/tracker/enums/gps_accuracy.dart';
import '../../../data/tracker/services/location_foreground_service.dart';

part 'tracker_state.dart';
part 'tracker_event.dart';
part 'tracker_bloc.freezed.dart';

@injectable
class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final AppDatabase _db;
  final SettingsService _settings;

  StreamSubscription<List<TrackingCoordinate>>? _coordinateSub;
  Timer? _durationTimer;

  TrackerBloc(this._db, this._settings) : super(const TrackerState.initial()) {
    on<_Init>(_onInit);
    on<_ToggleTracking>(_onToggleTracking);
    on<_Tick>(_onTick);
    on<_CoordinatesUpdated>(_onCoordinatesUpdated);
  }

  Future<void> _onInit(_Init event, Emitter<TrackerState> emit) async {
    try {
      final todayCoords = await _db.coordsToday();
      emit(
        TrackerState.active(
          todayPoints: todayCoords.length,
          todayDistanceM: _totalDistance(todayCoords),
        ),
      );
      final orphan = await _db.activeSession();
      if (orphan != null) await _resumeSession(orphan.id, emit);
    } catch (_) {
      emit(const TrackerState.active());
    }
  }

  Future<void> _onToggleTracking(
    _ToggleTracking event,
    Emitter<TrackerState> emit,
  ) async {
    final active = state.mapOrNull(active: (s) => s);
    if (active == null) return;
    if (active.isTracking) {
      await _stop(emit);
    } else {
      await _start(emit);
    }
  }

  void _onTick(_Tick event, Emitter<TrackerState> emit) {
    final s = state.mapOrNull(active: (a) => a);
    if (s != null) emit(s.copyWith(todayDurationSeconds: s.todayDurationSeconds + 1));
  }

  void _onCoordinatesUpdated(
    _CoordinatesUpdated event,
    Emitter<TrackerState> emit,
  ) {
    final coords = event.coordinates;
    if (coords.isEmpty) return;

    final last = coords.last;
    final accuracy = GpsAccuracy.values.byName(last.accuracy);

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(
        s.copyWith(
          position: (
            lat: last.latitude,
            lng: last.longitude,
            accuracy: accuracy.toMeters,
          ),
          trackPoints: coords.map((c) => LatLng(c.latitude, c.longitude)).toList(),
          todayPoints: coords.length,
          todayDistanceM: _totalDistance(coords),
        ),
      );
    }
  }

  Future<void> _start(Emitter<TrackerState> emit) async {
    final sessionId = await _db.insertSession(DateTime.now().toIso8601String());
    await _resumeSession(sessionId, emit);
  }

  Future<void> _resumeSession(int sessionId, Emitter<TrackerState> emit) async {
    await LocationForegroundService.start(sessionId, _settings.interval);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const TrackerEvent.tick());
    });

    _coordinateSub = _db.watchSession(sessionId).listen((coords) {
      if (!isClosed) add(TrackerEvent.coordinatesUpdated(coords));
    });

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(s.copyWith(isTracking: true, sessionId: sessionId, trackPoints: []));
    }
  }

  Future<void> _stop(Emitter<TrackerState> emit) async {
    final s = state.mapOrNull(active: (a) => a);

    await _coordinateSub?.cancel();
    _coordinateSub = null;
    _durationTimer?.cancel();
    _durationTimer = null;

    await LocationForegroundService.stop();
    if (s?.sessionId != null) await _db.closeSession(s!.sessionId!);

    if (s != null) {
      emit(s.copyWith(isTracking: false, sessionId: null, trackPoints: []));
    }
  }

  double _totalDistance(List<TrackingCoordinate> coords) {
    if (coords.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < coords.length; i++) {
      total += Geolocator.distanceBetween(
        coords[i - 1].latitude,
        coords[i - 1].longitude,
        coords[i].latitude,
        coords[i].longitude,
      );
    }
    return total;
  }

  @override
  Future<void> close() {
    _coordinateSub?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
