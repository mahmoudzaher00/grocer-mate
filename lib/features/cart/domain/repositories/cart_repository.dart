import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';

abstract interface class CartRepository {
  Future<Either<Failure, Cart>> loadCart();

  Future<Either<Failure, Unit>> saveCart({required Cart previousCart, required Cart updatedCart});

  Future<Either<Failure, Cart>> detachItemsForQueuedPurchase({required String purchaseKey, required List<CartItem> items, Future<Either<Failure, Unit>> Function()? persistPendingPurchase});
}
