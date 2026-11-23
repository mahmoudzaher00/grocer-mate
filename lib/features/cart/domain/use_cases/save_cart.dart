import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class SaveCart {
  const SaveCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Unit>> call(Cart cart) {
    return _repository.saveCart(cart);
  }
}
