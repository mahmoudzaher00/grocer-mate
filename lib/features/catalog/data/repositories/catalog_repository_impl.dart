import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product_page.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../data_sources/catalog_local_data_source.dart';

final class CatalogRepositoryImpl implements CatalogRepository {
  const CatalogRepositoryImpl(this._localDataSource);

  final CatalogLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await _localDataSource.getCategories();
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
  Future<Either<Failure, ProductPage>> getProducts({required String categoryId, required int page, required int pageSize}) async {
    try {
      final productPage = await _localDataSource.getProducts(categoryId: categoryId, page: page, pageSize: pageSize);
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
}
