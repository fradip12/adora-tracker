part of 'history_bloc.dart';

@freezed
sealed class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.load() = _Load;
  const factory HistoryEvent.filterChanged(HistoryFilter filter) =
      _FilterChanged;
  const factory HistoryEvent.refresh() = _Refresh;
}
