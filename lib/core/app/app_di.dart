import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/cart/data/data_sources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/use_cases/load_cart.dart';
import '../../features/cart/domain/use_cases/save_cart.dart';
import '../../features/cart/presentation/manager/bloc.dart';
import '../../features/catalog/data/data_sources/catalog_local_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/use_cases/get_brands.dart';
import '../../features/catalog/domain/use_cases/get_categories.dart';
import '../../features/catalog/domain/use_cases/get_product_details.dart';
import '../../features/catalog/domain/use_cases/get_products.dart';
import '../../features/catalog/presentation/manager/bloc.dart';
import '../../features/catalog/presentation/manager/product_details/bloc.dart';
import '../../features/catalog/presentation/manager/products/bloc.dart';
import '../blocs/theme/bloc.dart';
import 'app_prefs.dart';

final instance = GetIt.instance;

Future<void> initializeDependencies() async {
  /// Core / Generics **********************************************************
  instance.registerSingleton<AppPreferences>(await AppPreferences.create());

  /// Data sources *************************************************************
  instance.registerLazySingleton<CatalogLocalDataSource>(() => CatalogLocalDataSourceImpl(simulatePaginationFailure: kDebugMode));
  instance.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(instance<AppPreferences>()));

  /// Repositories *************************************************************
  instance.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(instance<CatalogLocalDataSource>()));
  instance.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(instance<CartLocalDataSource>()));

  /// UseCases *****************************************************************
  instance.registerLazySingleton<LoadCart>(() => LoadCart(instance<CartRepository>()));
  instance.registerLazySingleton<SaveCart>(() => SaveCart(instance<CartRepository>()));
  instance.registerLazySingleton<GetBrands>(() => GetBrands(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetCategories>(() => GetCategories(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetProductDetails>(() => GetProductDetails(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetProducts>(() => GetProducts(instance<CatalogRepository>()));

  /// Blocs instance ***********************************************************
  instance.registerLazySingleton<ThemeBloc>(() => ThemeBloc(instance<AppPreferences>()));
  instance.registerLazySingleton<CartBloc>(() => CartBloc(instance<LoadCart>(), instance<SaveCart>())..add(const CartRequested()));
  instance.registerFactory<CategoriesBloc>(() => CategoriesBloc(instance<GetCategories>()));
  instance.registerFactory<ProductDetailsBloc>(() => ProductDetailsBloc(instance<GetProductDetails>()));
  instance.registerFactory<ProductsBloc>(() => ProductsBloc(instance<GetProducts>(), instance<GetCategories>(), instance<GetBrands>()));
}
