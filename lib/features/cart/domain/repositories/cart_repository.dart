import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';

abstract interface class CartRepository {
  Future<Either<Failure, Cart>> loadCart();

  Future<Either<Failure, Unit>> saveCart(Cart cart);
}
