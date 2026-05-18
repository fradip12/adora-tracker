part of 'tracker_bloc.dart';

@freezed
abstract class TrackerState with _$TrackerState {
  const factory TrackerState.initial() = _Initial;

  const factory TrackerState.active({
    @Default(null) int? sessionId,
    @Default(null) ({double lat, double lng, double accuracy})? position,
    @Default(false) bool isTracking,
    @Default(0) int todayPoints,
    @Default(0.0) double todayDistanceM,
    @Default(0) int todayDurationSeconds,
    @Default([]) List<LatLng> trackPoints,
  }) = _Active;
}
