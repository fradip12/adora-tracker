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
  StreamSubscription<Position>? _positionSub;
  Timer? _durationTimer;

  TrackerBloc(this._db, this._settings) : super(const .initial()) {
    on<_Init>(_onInit);
    on<_ToggleTracking>(_onToggleTracking);
    on<_Tick>(_onTick);
    on<_CoordinatesUpdated>(_onCoordinatesUpdated);
    on<_PositionStreamUpdate>(_onPositionStreamUpdate);
  }

  Future<void> _onInit(_Init event, Emitter<TrackerState> emit) async {
    try {
      final todayCoords = await _db.coordsToday();
      emit(
        .active(
          todayPoints: todayCoords.length,
          todayDistanceM: _totalDistance(todayCoords),
        ),
      );
      final orphan = await _db.activeSession();
      if (orphan != null) await _resumeSession(orphan.id, emit);
    } catch (_) {
      emit(const .active());
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
    if (s != null) {
      emit(s.copyWith(todayDurationSeconds: s.todayDurationSeconds + 1));
    }
  }

  void _onPositionStreamUpdate(
    _PositionStreamUpdate event,
    Emitter<TrackerState> emit,
  ) {
    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(
        s.copyWith(
          position: (
            lat: event.lat,
            lng: event.lng,
            accuracy: GpsAccuracy.fromMeters(event.accuracy).toMeters,
          ),
        ),
      );
    }
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
          trackPoints: coords
              .map((c) => LatLng(c.latitude, c.longitude))
              .toList(),
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

    // Emit tracking state FIRST, before wiring the stream
    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(s.copyWith(isTracking: true, sessionId: sessionId, trackPoints: []));
    }

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const .tick());
    });

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((pos) {
      if (!isClosed) add(.positionStreamUpdate(pos.latitude, pos.longitude, pos.accuracy));
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
    _durationTimer?.cancel();
    _durationTimer = null;

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
    if (state.mapOrNull(active: (a) => a)?.isTracking == true) {
      _stopSideEffects();
    } else {
      _coordinateSub?.cancel();
      _positionSub?.cancel();
      _durationTimer?.cancel();
    }
    return super.close();
  }
}
