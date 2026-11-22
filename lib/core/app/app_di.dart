import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/catalog/data/data_sources/catalog_local_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/use_cases/get_categories.dart';
import '../../features/catalog/domain/use_cases/get_products.dart';
import '../../features/catalog/presentation/manager/bloc.dart';
import '../../features/catalog/presentation/manager/products/bloc.dart';
import '../blocs/theme/bloc.dart';
import 'app_prefs.dart';

final instance = GetIt.instance;

Future<void> initializeDependencies() async {
  /// Core / Generics **********************************************************
  instance.registerSingleton<AppPreferences>(await AppPreferences.create());

  /// Data sources *************************************************************
  instance.registerLazySingleton<CatalogLocalDataSource>(() => CatalogLocalDataSourceImpl(simulatePaginationFailure: kDebugMode));

  /// Repositories *************************************************************
  instance.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(instance<CatalogLocalDataSource>()));

  /// UseCases *****************************************************************
  instance.registerLazySingleton<GetCategories>(() => GetCategories(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetProducts>(() => GetProducts(instance<CatalogRepository>()));

  /// Blocs instance ***********************************************************
  instance.registerLazySingleton<ThemeBloc>(() => ThemeBloc(instance<AppPreferences>()));
  instance.registerFactory<CategoriesBloc>(() => CategoriesBloc(instance<GetCategories>()));
  instance.registerFactory<ProductsBloc>(() => ProductsBloc(instance<GetProducts>()));
}
