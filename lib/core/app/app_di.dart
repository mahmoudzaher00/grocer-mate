import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../features/cart/data/data_sources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/use_cases/load_cart.dart';
import '../../features/cart/domain/use_cases/save_cart.dart';
import '../../features/cart/domain/use_cases/detach_queued_cart_items.dart';
import '../../features/cart/presentation/manager/bloc.dart';
import '../../features/catalog/data/data_sources/catalog_cache_data_source.dart';
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
import '../../features/checkout/data/data_sources/checkout_local_data_source.dart';
import '../../features/checkout/data/data_sources/checkout_outbox_local_data_source.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/data/repositories/checkout_outbox_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/domain/repositories/checkout_outbox_repository.dart';
import '../../features/checkout/domain/use_cases/clear_queued_purchase.dart';
import '../../features/checkout/domain/use_cases/queue_offline_purchase.dart';
import '../../features/checkout/domain/use_cases/recover_queued_purchase.dart';
import '../../features/checkout/domain/use_cases/submit_purchase.dart';
import '../../features/checkout/presentation/manager/bloc.dart';
import '../../features/checkout/presentation/manager/outbox/bloc.dart';
import '../blocs/connectivity/bloc.dart';
import '../blocs/theme/bloc.dart';
import '../network/network_manager.dart';
import '../storage/app_preferences.dart';

final instance = GetIt.instance;

Future<void> initializeDependencies() async {
  /// Core / Generics **********************************************************
  instance.registerSingleton<AppPreferences>(await AppPreferences.create());
  instance.registerLazySingleton<NetworkManager>(() => NetworkManager(), dispose: (manager) => manager.dispose());

  /// Data sources *************************************************************
  instance.registerLazySingleton<CatalogLocalDataSource>(() => CatalogLocalDataSourceImpl(simulatePaginationFailure: kDebugMode));
  instance.registerLazySingleton<CatalogCacheDataSource>(() => CatalogCacheDataSourceImpl(instance<AppPreferences>()));
  instance.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSourceImpl(instance<AppPreferences>()));
  instance.registerLazySingleton<CheckoutLocalDataSource>(() => CheckoutLocalDataSourceImpl(instance<AppPreferences>()));
  instance.registerLazySingleton<CheckoutOutboxLocalDataSource>(() => CheckoutOutboxLocalDataSourceImpl(instance<AppPreferences>()));

  /// Repositories *************************************************************
  instance.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(instance<CatalogLocalDataSource>(), instance<CatalogCacheDataSource>(), instance<NetworkManager>()));
  instance.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(instance<CartLocalDataSource>()));
  instance.registerLazySingleton<CheckoutRepository>(() => CheckoutRepositoryImpl(instance<CheckoutLocalDataSource>()));
  instance.registerLazySingleton<CheckoutOutboxRepository>(() => CheckoutOutboxRepositoryImpl(instance<CheckoutOutboxLocalDataSource>()));

  /// UseCases *****************************************************************
  instance.registerLazySingleton<LoadCart>(() => LoadCart(instance<CartRepository>()));
  instance.registerLazySingleton<SaveCart>(() => SaveCart(instance<CartRepository>()));
  instance.registerLazySingleton<DetachQueuedCartItems>(() => DetachQueuedCartItems(instance<CartRepository>()));
  instance.registerLazySingleton<GetBrands>(() => GetBrands(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetCategories>(() => GetCategories(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetProductDetails>(() => GetProductDetails(instance<CatalogRepository>()));
  instance.registerLazySingleton<GetProducts>(() => GetProducts(instance<CatalogRepository>()));
  instance.registerLazySingleton<SubmitPurchase>(() => SubmitPurchase(instance<CheckoutRepository>()));
  instance.registerLazySingleton<ClearQueuedPurchase>(() => ClearQueuedPurchase(instance<CheckoutOutboxRepository>()));
  instance.registerLazySingleton<QueueOfflinePurchase>(() => QueueOfflinePurchase(instance<CheckoutOutboxRepository>(), instance<DetachQueuedCartItems>()));
  instance.registerLazySingleton<RecoverQueuedPurchase>(() => RecoverQueuedPurchase(instance<CheckoutOutboxRepository>(), instance<DetachQueuedCartItems>()));

  final outboxBootstrapResult = await instance<RecoverQueuedPurchase>()();
  final canLoadCart = outboxBootstrapResult.fold((_) => false, (_) => true);

  /// Blocs instance ***********************************************************
  instance.registerLazySingleton<ConnectivityBloc>(() => ConnectivityBloc(instance<NetworkManager>())..add(const ConnectivityStarted()), dispose: (bloc) => bloc.close());
  instance.registerLazySingleton<ThemeBloc>(() => ThemeBloc(instance<AppPreferences>()), dispose: (bloc) => bloc.close());
  instance.registerLazySingleton<CartBloc>(() {
    final bloc = CartBloc(instance<LoadCart>(), instance<SaveCart>());
    if (canLoadCart) bloc.add(const CartRequested());
    return bloc;
  }, dispose: (bloc) => bloc.close());
  instance.registerLazySingleton<OutboxBloc>(
    () => OutboxBloc(instance<QueueOfflinePurchase>(), instance<RecoverQueuedPurchase>(), instance<ClearQueuedPurchase>(), outboxBootstrapResult),
    dispose: (bloc) => bloc.close(),
  );
  instance.registerFactory<CategoriesBloc>(() => CategoriesBloc(instance<GetCategories>()));
  instance.registerFactory<ProductDetailsBloc>(() => ProductDetailsBloc(instance<GetProductDetails>()));
  instance.registerFactory<ProductsBloc>(() => ProductsBloc(instance<GetProducts>(), instance<GetCategories>(), instance<GetBrands>()));
  instance.registerFactory<CheckoutBloc>(() => CheckoutBloc(instance<SubmitPurchase>()));
}
