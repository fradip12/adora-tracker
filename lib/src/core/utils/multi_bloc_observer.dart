import 'package:flutter_bloc/flutter_bloc.dart';

/// Composite [BlocObserver] that broadcasts all bloc lifecycle events
/// to multiple observers, allowing logging systems to work simultaneously.
class MultiBlocObserver extends BlocObserver {
  MultiBlocObserver(this._observers);

  final List<BlocObserver> _observers;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    for (final o in _observers) {
      o.onCreate(bloc);
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    for (final o in _observers) {
      o.onEvent(bloc, event);
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    for (final o in _observers) {
      o.onChange(bloc, change);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    for (final o in _observers) {
      o.onTransition(bloc, transition);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    for (final o in _observers) {
      o.onError(bloc, error, stackTrace);
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    for (final o in _observers) {
      o.onClose(bloc);
    }
  }
}
