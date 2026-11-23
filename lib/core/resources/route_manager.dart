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

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class AppRouteGenerator {
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
        if (category is! Category) return unDefinedRoute(settings);

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider(create: (_) => instance<ProductsBloc>()..add(ProductsRequested(category.id)), child: const ProductsView()),
        );
      case productDetailsRoute:
        final product = settings.arguments;
        if (product is! Product) return unDefinedRoute(settings);

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
