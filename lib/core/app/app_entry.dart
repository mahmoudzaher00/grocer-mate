import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../features/cart/presentation/manager/bloc.dart';
import '../../features/checkout/presentation/manager/outbox/bloc.dart';
import '../../features/checkout/presentation/widgets/queued_checkout_coordinator.dart';
import '../blocs/connectivity/bloc.dart';
import '../blocs/theme/bloc.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import 'app_constants.dart';
import 'app_di.dart';
import '../widgets/status_views/offline_banner.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🧱 AppEntry - build');

    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>.value(value: instance<ConnectivityBloc>()),
        BlocProvider<ThemeBloc>.value(value: instance<ThemeBloc>()),
        BlocProvider<CartBloc>.value(value: instance<CartBloc>()),
        BlocProvider<OutboxBloc>.value(value: instance<OutboxBloc>()),
      ],
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
                themeAnimationCurve: Curves.easeOutCubic,
                builder: (context, widgets) {
                  final brightness = Theme.of(context).brightness;
                  final systemUiOverlayStyle = brightness == Brightness.dark ? AppConstants.statusBarOnDarkBackground : AppConstants.statusBarOnLightBackground;

                  return AnnotatedRegion<SystemUiOverlayStyle>(
                    value: systemUiOverlayStyle,
                    child: SkeletonizerConfig(
                      data: appSkeletonizerConfig.copyWith(brightness: brightness),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
                        child: QueuedCheckoutCoordinator(
                          child: Stack(
                            children: [
                              Positioned.fill(child: widgets!),
                              const PositionedDirectional(
                                top: 0,
                                start: 0,
                                end: 0,
                                child: SafeArea(bottom: false, child: IgnorePointer(child: OfflineBanner())),
                              ),
                            ],
                          ),
                        ),
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
