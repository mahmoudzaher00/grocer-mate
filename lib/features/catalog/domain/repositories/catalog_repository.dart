import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../entities/product_page.dart';

abstract interface class CatalogRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, ProductPage>> getProducts({required String categoryId, required int page, required int pageSize});
}
