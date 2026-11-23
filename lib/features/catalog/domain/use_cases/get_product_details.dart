import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/product_details.dart';
import '../repositories/catalog_repository.dart';

class GetProductDetails {
  const GetProductDetails(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, ProductDetails>> call(String productId) {
    return _repository.getProductDetails(productId);
  }
}
