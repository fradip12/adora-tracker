import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import '../../../core/data/database/app_database.dart';
import '../../../data/history/enums/history_filter.dart';
import '../../../data/tracker/enums/gps_accuracy.dart';

part 'history_state.dart';
part 'history_event.dart';
part 'history_bloc.freezed.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final AppDatabase _db;

  HistoryBloc(this._db) : super(const .initial()) {
    on<_Load>(_onLoad);
    on<_FilterChanged>(_onFilterChanged);
    on<_Refresh>(_onRefresh);
  }

  Future<void> _onLoad(_Load event, Emitter<HistoryState> emit) async {
    await _loadWithFilter(.today, emit);
  }

  Future<void> _onFilterChanged(
    _FilterChanged event,
    Emitter<HistoryState> emit,
  ) async {
    await _loadWithFilter(event.filter, emit);
  }

  Future<void> _onRefresh(_Refresh event, Emitter<HistoryState> emit) async {
    final currentFilter = state.mapOrNull(active: (s) => s.filter) ?? .today;
    await _loadWithFilter(currentFilter, emit);
  }

  Future<void> _loadWithFilter(
    HistoryFilter filter,
    Emitter<HistoryState> emit,
  ) async {
    emit(.loading(filter: filter));

    final ascending = await _fetchRecords(filter);
    final records = ascending.reversed.toList();

    final pointCount = records.length;
    final distanceKm = _totalDistanceKm(ascending);
    final avgAccuracy = records.isEmpty
        ? 0.0
        : records
                .map((r) => GpsAccuracy.values.byName(r.accuracy).toMeters)
                .reduce((a, b) => a + b) /
            records.length;

    emit(
      .active(
        filter: filter,
        records: records,
        pointCount: pointCount,
        distanceKm: distanceKm,
        avgAccuracy: avgAccuracy,
      ),
    );
  }

  Future<List<TrackingCoordinate>> _fetchRecords(HistoryFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (filter) {
      HistoryFilter.today =>
        _db.coordsByDateRange(today, today.add(const Duration(days: 1))),
      HistoryFilter.yesterday => _db.coordsByDateRange(
          today.subtract(const Duration(days: 1)),
          today,
        ),
      HistoryFilter.thisWeek => _db.coordsByDateRange(
          today.subtract(Duration(days: today.weekday - 1)),
          today.add(const Duration(days: 1)),
        ),
      HistoryFilter.all => _db.allCoords(),
    };
  }

  double _totalDistanceKm(List<TrackingCoordinate> coords) {
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
    return total / 1000;
  }
}
