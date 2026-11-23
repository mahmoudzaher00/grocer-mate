// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'app_logger.dart';
//
// typedef BlocErrorReporter = void Function(Object error, StackTrace stackTrace, String reason);
//
// class AppBlocObserver extends BlocObserver {
//   AppBlocObserver({this.errorReporter});
//
//   final BlocErrorReporter? errorReporter;
//
//   @override
//   void onCreate(BlocBase bloc) {
//     super.onCreate(bloc);
//     AppLogger.i('${bloc.runtimeType} (onCreate)');
//   }
//
//   @override
//   void onChange(BlocBase bloc, Change change) {
//     super.onChange(bloc, change);
//     final msg = '${bloc.runtimeType} (onChange), ${change.currentState.runtimeType} ==> ${change.nextState.runtimeType}';
//     if (change.nextState.runtimeType.toString().contains('Failed')) {
//       AppLogger.e(msg);
//     } else {
//       AppLogger.d(msg);
//     }
//   }
//
//   @override
//   void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
//     AppLogger.e('${bloc.runtimeType} (onError)', error: error, stackTrace: stackTrace);
//     errorReporter?.call(error, stackTrace, '${bloc.runtimeType} onError');
//     super.onError(bloc, error, stackTrace);
//   }
//
//   @override
//   void onClose(BlocBase bloc) {
//     super.onClose(bloc);
//     AppLogger.w('${bloc.runtimeType} (onClose)');
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    AppLogger.i('${bloc.runtimeType} (onCreate)');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    final message =
        '${bloc.runtimeType} (onChange), '
        '${change.currentState.runtimeType} ==> '
        '${change.nextState.runtimeType}';

    if (change.nextState.runtimeType.toString().contains('Failed')) {
      AppLogger.e(message);
    } else {
      AppLogger.d(message);
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      '${bloc.runtimeType} (onError)',
      error: error,
      stackTrace: stackTrace,
    );

    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    AppLogger.w('${bloc.runtimeType} (onClose)');
  }
}
