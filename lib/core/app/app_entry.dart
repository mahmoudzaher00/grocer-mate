import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:material_ui/material_ui.dart';

import '../resources/route_manager.dart';
import 'app_constants.dart';
import 'app_theme.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 AppEntry - build');

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'GrocerMate',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (context, widgets) {
          return SkeletonizerConfig(
            data: appSkeletonizerConfig,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: widgets!,
            ),
          );
        },
        navigatorObservers: [routeObserver],
        navigatorKey: AppConstants.navigatorKey,
        onGenerateRoute: AppRouteGenerator.getRoute,
        initialRoute: splashRoute,
      ),
    );
  }
}
