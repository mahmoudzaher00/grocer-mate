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
import '../constants/duration_constants.dart';
import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/system_ui_styles.dart';
import '../widgets/status_views/offline_banner.dart';
import 'app_di.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConnectivityBloc>.value(value: instance<ConnectivityBloc>()),
        BlocProvider<ThemeBloc>.value(value: instance<ThemeBloc>()),
        BlocProvider<CartBloc>.value(value: instance<CartBloc>()),
        BlocProvider<OutboxBloc>.value(value: instance<OutboxBloc>()),
      ],
      child: ScreenUtilInit(designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true, builder: (_, _) => const _AppMaterial()),
    );
  }
}

class _AppMaterial extends StatelessWidget {
  const _AppMaterial();

  @override
  Widget build(BuildContext context) {
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
          themeAnimationDuration: reduceMotion ? Duration.zero : DurationConstants.themeAnimationDuration,
          themeAnimationCurve: Curves.easeOutCubic,
          builder: (context, child) => _AppContent(child: child!),
          navigatorObservers: [routeObserver],
          navigatorKey: rootNavigatorKey,
          onGenerateRoute: AppRouteGenerator.getRoute,
          initialRoute: splashRoute,
        );
      },
    );
  }
}

class _AppContent extends StatelessWidget {
  const _AppContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final systemUiOverlayStyle = brightness == Brightness.dark ? SystemUiStyles.onDarkBackground : SystemUiStyles.onLightBackground;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: SkeletonizerConfig(
        data: appSkeletonizerConfig.copyWith(brightness: brightness),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: QueuedCheckoutCoordinator(child: OfflineBannerLayout(child: child)),
        ),
      ),
    );
  }
}
