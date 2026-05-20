import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../core/models/result.dart';
import '../../../data/history/enums/history_filter.dart';
import '../../../data/history/models/session_summary.dart';
import '../../../data/history/repository/history_repository.dart';

part 'history_state.dart';
part 'history_event.dart';
part 'history_bloc.freezed.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository _repository;

  HistoryBloc(this._repository) : super(const .initial()) {
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

    final result = await _repository.fetchSummaries(filter);

    switch (result) {
      case Ok(:final value):
        final sessions = value;
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

      case Error(:final error):
        emit(.error(filter: filter, exception: error));
    }
  }
}
