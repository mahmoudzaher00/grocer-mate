import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_page.dart';
import '../repositories/catalog_repository.dart';

class GetProducts {
  const GetProducts(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, ProductPage>> call({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) {
    return _repository.getProducts(categoryId: categoryId, brand: brand, searchQuery: searchQuery, page: page, pageSize: pageSize);
  }
}
