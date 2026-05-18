part of 'tracker_bloc.dart';

@freezed
sealed class TrackerEvent with _$TrackerEvent {
  const factory TrackerEvent.init() = _Init;
  const factory TrackerEvent.toggleTracking() = _ToggleTracking;
  const factory TrackerEvent.tick() = _Tick;
  const factory TrackerEvent.coordinatesUpdated(
    List<TrackingCoordinate> coordinates,
  ) = _CoordinatesUpdated;
  const factory TrackerEvent.positionStreamUpdate(
    double lat,
    double lng,
    double accuracy,
  ) = _PositionStreamUpdate;
}
