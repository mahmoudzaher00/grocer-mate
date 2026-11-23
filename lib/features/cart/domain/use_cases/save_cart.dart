import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class SaveCart {
  const SaveCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Unit>> call(List<CartItem> items) {
    return _repository.saveCart(items);
  }
}
