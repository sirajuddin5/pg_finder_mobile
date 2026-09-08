import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    AppLogger.d('${bloc.runtimeType} => Event: $event', tag: 'BLOC');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    AppLogger.d(
      '${bloc.runtimeType} => State: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
      tag: 'BLOC',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      '${bloc.runtimeType} => Unhandled Error: $error',
      tag: 'BLOC',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}