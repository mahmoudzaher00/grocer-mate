import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../entities/product_details.dart';
import '../entities/product_page.dart';

abstract interface class CatalogRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, List<String>>> getBrands({String? categoryId});

  Future<Either<Failure, ProductDetails>> getProductDetails(String productId);

  Future<Either<Failure, ProductPage>> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''});
}
