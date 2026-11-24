import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'core/app/app_di.dart';
import 'core/app/app_entry.dart';
import 'core/utils/logging/bloc_observer.dart';
import 'core/utils/logging/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  try {
    await initializeDependencies();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  } on Object catch (error, stackTrace) {
    AppLogger.e('Application initialization failed.', error: error, stackTrace: stackTrace);
    rethrow;
  }

  runApp(const AppEntry());
}
