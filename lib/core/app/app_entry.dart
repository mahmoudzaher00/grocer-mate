import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../blocs/theme/bloc.dart';
import '../resources/route_manager.dart';
import 'app_constants.dart';
import 'app_di.dart';
import 'app_theme.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 AppEntry - build');

    return BlocProvider<ThemeBloc>.value(
      value: instance<ThemeBloc>(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          final reduceMotion = WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

          return BlocBuilder<ThemeBloc, ThemeState>(
            buildWhen: (previous, current) => previous.themeMode != current.themeMode,
            builder: (context, state) {
              return MaterialApp(
                title: 'GrocerMate',
                debugShowCheckedModeBanner: false,
                theme: buildLightTheme(),
                darkTheme: buildDarkTheme(),
                themeMode: state.themeMode,
                themeAnimationDuration: reduceMotion ? Duration.zero : AppConstants.themeAnimationDuration,
                themeAnimationCurve: Curves.easeInOutCubic,
                builder: (context, widgets) {
                  final systemUiOverlayStyle = Theme.of(context).brightness == Brightness.dark ? AppConstants.statusBarOnDarkBackground : AppConstants.statusBarOnLightBackground;

                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: systemUiOverlayStyle,
                    child: SkeletonizerConfig(
                      data: appSkeletonizerConfig,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: widgets!,
                      ),
                    ),
                  );
                },
                navigatorObservers: [routeObserver],
                navigatorKey: AppConstants.navigatorKey,
                onGenerateRoute: AppRouteGenerator.getRoute,
                initialRoute: splashRoute,
              );
            },
          );
        },
      ),
    );
  }
}
