import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/utils/logging/app_logger.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../data_sources/catalog_cache_data_source.dart';
import '../data_sources/catalog_local_data_source.dart';

final class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._localDataSource, this._cacheDataSource, this._networkManager);

  final CatalogLocalDataSource _localDataSource;
  final CatalogCacheDataSource _cacheDataSource;
  final NetworkManager _networkManager;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    if (!await _networkManager.isConnected) {
      try {
        return Right(await _cacheDataSource.getCategories());
      } on CatalogCacheMissException {
        return const Left(DataFailure('No saved categories are available yet. Connect to the internet and try again.'));
      } on FormatException {
        return const Left(DataFailure('The saved offline catalog data is invalid.'));
      } on PlatformException {
        return const Left(StorageFailure('The saved offline catalog could not be loaded.'));
      }
    }

    try {
      final categories = await _localDataSource.getCategories();
      await _cacheSafely(() => _cacheDataSource.saveCategories(categories));
      return Right(categories);
    } on FormatException {
      return const Left(DataFailure('The local categories data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The local categories data could not be loaded.'));
    } on PlatformException {
      return const Left(DataFailure('The local categories data could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getBrands({String? categoryId}) async {
    if (!await _networkManager.isConnected) {
      try {
        return Right(await _cacheDataSource.getBrands(categoryId: categoryId));
      } on CatalogCacheMissException {
        return const Left(DataFailure('No saved products are available for offline browsing. Connect to the internet and try again.'));
      } on FormatException {
        return const Left(DataFailure('The saved offline catalog data is invalid.'));
      } on PlatformException {
        return const Left(StorageFailure('The saved offline catalog could not be loaded.'));
      }
    }

    try {
      final brands = await _localDataSource.getBrands(categoryId: categoryId);
      final products = await _localDataSource.getAllProducts();
      await _cacheSafely(() => _cacheDataSource.saveProducts(products));
      return Right(brands);
    } on FormatException {
      return const Left(DataFailure('The local brands data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The local brands data could not be loaded.'));
    } on PlatformException {
      return const Left(DataFailure('The local brands data could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, ProductDetails>> getProductDetails(String productId) async {
    if (!await _networkManager.isConnected) {
      try {
        return Right(await _cacheDataSource.getProductDetails(productId));
      } on CatalogCacheMissException {
        return const Left(DataFailure('This product has not been saved for offline viewing. Open it once while online and try again.'));
      } on FormatException {
        return const Left(DataFailure('The saved offline product details are invalid.'));
      } on PlatformException {
        return const Left(StorageFailure('The saved offline product details could not be loaded.'));
      }
    }

    try {
      final productDetails = await _localDataSource.getProductDetails(productId);
      await _cacheSafely(() => _cacheDataSource.saveProductDetails(productDetails));
      return Right(productDetails);
    } on ProductNotFoundException {
      return const Left(DataFailure('Product details could not be found.'));
    } on FormatException {
      return const Left(DataFailure('The local product details data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The local product details data could not be loaded.'));
    } on PlatformException {
      return const Left(DataFailure('The local product details data could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, ProductPage>> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) async {
    if (!await _networkManager.isConnected) {
      try {
        final productPage = await _cacheDataSource.getProducts(categoryId: categoryId, brand: brand, searchQuery: searchQuery, page: page, pageSize: pageSize);
        return Right(productPage);
      } on CatalogCacheMissException {
        return const Left(DataFailure('No saved products are available for offline browsing. Connect to the internet and try again.'));
      } on FormatException {
        return const Left(DataFailure('The saved offline catalog data is invalid.'));
      } on PlatformException {
        return const Left(StorageFailure('The saved offline catalog could not be loaded.'));
      }
    }

    try {
      final productPage = await _localDataSource.getProducts(categoryId: categoryId, brand: brand, searchQuery: searchQuery, page: page, pageSize: pageSize);
      final products = await _localDataSource.getAllProducts();
      await _cacheSafely(() => _cacheDataSource.saveProducts(products));
      return Right(productPage);
    } on MockPageLoadException {
      return const Left(DataFailure('This page could not be loaded. Please try again.'));
    } on FormatException {
      return const Left(DataFailure('The local products data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The local products data could not be loaded.'));
    } on PlatformException {
      return const Left(DataFailure('The local products data could not be loaded.'));
    }
  }

  Future<void> _cacheSafely(Future<void> Function() write) async {
    try {
      await write();
    } on Object catch (error, stackTrace) {
      AppLogger.e('Catalog data was loaded, but its offline cache could not be updated.', error: error, stackTrace: stackTrace);
    }
  }
}
