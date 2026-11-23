import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class LoadCart {
  const LoadCart(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call() {
    return _repository.loadCart();
  }
}
