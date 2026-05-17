part of 'history_bloc.dart';

@freezed
abstract class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;

  const factory HistoryState.loading({
    @Default(HistoryFilter.today) HistoryFilter filter,
  }) = _Loading;

  const factory HistoryState.active({
    @Default(HistoryFilter.today) HistoryFilter filter,
    @Default([]) List<CoordinateRecord> records,
    @Default(0) int pointCount,
    @Default(0.0) double distanceKm,
    @Default(0.0) double avgAccuracy,
  }) = _Active;
}
