import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/category.dart';
import '../repositories/catalog_repository.dart';

class GetCategories {
  const GetCategories(this._repository);

  final CatalogRepository _repository;

  Future<Either<Failure, List<Category>>> call() {
    return _repository.getCategories();
  }
}
