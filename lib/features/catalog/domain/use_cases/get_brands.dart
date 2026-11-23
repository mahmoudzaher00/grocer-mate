import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/catalog_repository.dart';

class GetBrands {
  const GetBrands(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<String>>> call({String? categoryId}) {
    return _repository.getBrands(categoryId: categoryId);
  }
}
