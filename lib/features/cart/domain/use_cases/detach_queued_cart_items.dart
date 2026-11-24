import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class DetachQueuedCartItems {
  const DetachQueuedCartItems(this._repository);

  final CartRepository _repository;

  Future<Either<Failure, Cart>> call({required String purchaseKey, required List<CartItem> items, Future<Either<Failure, Unit>> Function()? persistPendingPurchase}) {
    return _repository.detachItemsForQueuedPurchase(purchaseKey: purchaseKey, items: items, persistPendingPurchase: persistPendingPurchase);
  }
}
