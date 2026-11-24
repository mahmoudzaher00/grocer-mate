import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/cart/presentation/view/view.dart';
import '../../features/catalog/domain/entities/category.dart';
import '../../features/catalog/domain/entities/product.dart';
import '../../features/catalog/presentation/manager/bloc.dart';
import '../../features/catalog/presentation/manager/product_details/bloc.dart';
import '../../features/catalog/presentation/manager/products/bloc.dart';
import '../../features/catalog/presentation/view/product_details/view.dart';
import '../../features/catalog/presentation/view/view.dart';
import '../../features/catalog/presentation/view/products/view.dart';
import '../../features/splash/presentation/view/view.dart';
import '../app/app_di.dart';
import 'route_names.dart';

export 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final AppRouteObserver routeObserver = AppRouteObserver();

final class AppRouteObserver extends RouteObserver<ModalRoute<void>> {
  final ValueNotifier<String?> currentRouteName = ValueNotifier<String?>(null);

  void _updateCurrentRoute(Route<dynamic>? route) {
    currentRouteName.value = route?.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateCurrentRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateCurrentRoute(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateCurrentRoute(newRoute);
  }
}

abstract final class AppRouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => const SplashView());
      case categoriesRoute:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(create: (_) => instance<CategoriesBloc>()..add(const CategoriesRequested()), child: const CategoriesView()),
        );
      case productsRoute:
        final category = settings.arguments;
        if (category is! Category) return _undefinedRoute(settings);

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(create: (_) => instance<ProductsBloc>()..add(ProductsRequested(category)), child: const ProductsView()),
        );
      case productDetailsRoute:
        final product = settings.arguments;
        if (product is! Product) return _undefinedRoute(settings);

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => instance<ProductDetailsBloc>()..add(ProductDetailsRequested(product.id)),
            child: ProductDetailsView(product: product),
          ),
        );
      case cartRoute:
        return MaterialPageRoute(settings: settings, builder: (_) => const CartView());

      default:
        return _undefinedRoute(settings);
    }
  }

  static Route<dynamic> _undefinedRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page not found')),
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
