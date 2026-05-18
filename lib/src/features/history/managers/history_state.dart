part of 'history_bloc.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;

  const factory HistoryState.loading({
    @Default(HistoryFilter.today) HistoryFilter filter,
  }) = _Loading;

  const factory HistoryState.active({
    @Default(HistoryFilter.today) HistoryFilter filter,
    @Default([]) List<SessionSummary> sessions,
    @Default(0) int totalPoints,
    @Default(0.0) double totalDistanceKm,
    @Default(0.0) double avgAccuracy,
  }) = _Active;
}
