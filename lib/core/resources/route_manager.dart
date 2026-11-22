import 'package:material_ui/material_ui.dart';

import '../../features/catalog/presentation/view/view.dart';
import '../../features/splash/presentation/view/view.dart';
import 'route_names.dart';

export 'route_names.dart';



final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class AppRouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => const SplashView());
      case categoriesRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => const CategoriesView());

      default:
        return unDefinedRoute(settings);
    }
  }

  static Route<dynamic> unDefinedRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
