import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../core/data/database/coordinate_dao.dart';
import '../../../core/data/models/coordinate_record.dart';

part 'tracker_state.dart';
part 'tracker_event.dart';
part 'tracker_bloc.freezed.dart';

@injectable
class TrackerBloc extends Bloc<TrackerEvent, TrackerState> {
  final CoordinateDao _dao;

  StreamSubscription<Position>? _positionSub;
  Position? _lastPosition;
  double _sessionDistanceM = 0;
  int _sessionPoints = 0;
  Timer? _durationTimer;

  TrackerBloc(this._dao) : super(const TrackerState.initial()) {
    on<_Init>(_onInit);
    on<_ToggleTracking>(_onToggleTracking);
    on<_Tick>(_onTick);
    on<_PositionUpdate>(_onPositionUpdate);
  }

  Future<void> _onInit(_Init event, Emitter<TrackerState> emit) async {
    try {
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final records = await _dao.queryByDateRange(
        dayStart,
        dayStart.add(const Duration(days: 1)),
      );
      _sessionPoints = records.length;
      _sessionDistanceM = _totalDistance(records);
      emit(
        TrackerState.active(
          todayPoints: _sessionPoints,
          todayDistanceM: _sessionDistanceM,
        ),
      );
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
      _stop(emit);
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

  Future<void> _onPositionUpdate(
    _PositionUpdate event,
    Emitter<TrackerState> emit,
  ) async {
    final pos = event.position;
    if (_lastPosition != null) {
      _sessionDistanceM += Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
    }
    _lastPosition = pos;
    _sessionPoints++;

    await _dao.insert(
      CoordinateRecord(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: DateTime.now(),
      ),
    );

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) {
      emit(
        s.copyWith(
          position: pos,
          todayPoints: _sessionPoints,
          todayDistanceM: _sessionDistanceM,
        ),
      );
    }
  }

  Future<void> _start(Emitter<TrackerState> emit) async {
    final perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(const TrackerEvent.tick());
    });

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
          if (!isClosed) add(TrackerEvent.positionUpdate(pos));
        }, onError: (_) {});

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) emit(s.copyWith(isTracking: true));
  }

  void _stop(Emitter<TrackerState> emit) {
    _positionSub?.cancel();
    _positionSub = null;
    _durationTimer?.cancel();
    _durationTimer = null;
    _lastPosition = null;

    final s = state.mapOrNull(active: (a) => a);
    if (s != null) emit(s.copyWith(isTracking: false));
  }

  double _totalDistance(List<CoordinateRecord> records) {
    if (records.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < records.length; i++) {
      total += Geolocator.distanceBetween(
        records[i - 1].latitude,
        records[i - 1].longitude,
        records[i].latitude,
        records[i].longitude,
      );
    }
    return total;
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
