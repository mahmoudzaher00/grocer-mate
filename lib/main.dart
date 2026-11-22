import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'core/app/app_di.dart';
import 'core/app/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const AppEntry());
}
