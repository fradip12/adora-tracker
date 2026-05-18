import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../core/data/database/app_database.dart';
import '../../../data/history/enums/history_filter.dart';
import '../../../data/history/models/session_summary.dart';

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

    final rawSessions = await _fetchSessions(filter);
    final sessions = await Future.wait(
      rawSessions.map((s) async {
        final coords = await _db.coordsForSession(s.id);
        return SessionSummary(
          session: s,
          coordinates: coords,
          distanceKm: SessionSummary.computeDistanceKm(coords),
        );
      }),
    );

    final totalPoints = sessions.fold(0, (sum, s) => sum + s.pointCount);
    final totalDistanceKm = sessions.fold<double>(
      0,
      (sum, s) => sum + s.distanceKm,
    );
    final allCoords = sessions.expand((s) => s.coordinates).toList();
    final avgAccuracy = allCoords.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (sum, s) => sum + s.avgAccuracyMeters) /
              sessions.length;

    emit(
      .active(
        filter: filter,
        sessions: sessions,
        totalPoints: totalPoints,
        totalDistanceKm: totalDistanceKm,
        avgAccuracy: avgAccuracy,
      ),
    );
  }

  Future<List<TrackingSession>> _fetchSessions(HistoryFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return switch (filter) {
      HistoryFilter.today => _db.sessionsByDateRange(
        today,
        today.add(const Duration(days: 1)),
      ),
      HistoryFilter.yesterday => _db.sessionsByDateRange(
        today.subtract(const Duration(days: 1)),
        today,
      ),
      HistoryFilter.thisWeek => _db.sessionsByDateRange(
        today.subtract(Duration(days: today.weekday - 1)),
        today.add(const Duration(days: 1)),
      ),
      HistoryFilter.all => _db.allSessions(),
    };
  }
}
