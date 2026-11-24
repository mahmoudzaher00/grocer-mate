import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../cart/domain/use_cases/detach_queued_cart_items.dart';
import '../entities/queued_purchase.dart';
import '../repositories/checkout_outbox_repository.dart';

class RecoverQueuedPurchase {
  const RecoverQueuedPurchase(this._repository, this._detachQueuedCartItems);

  final CheckoutOutboxRepository _repository;
  final DetachQueuedCartItems _detachQueuedCartItems;

  Future<Either<Failure, QueuedPurchase?>> call() async {
    final loadResult = await _repository.loadPurchase();
    return loadResult.fold(Left.new, (purchase) async {
      if (purchase == null || purchase.phase == QueuedPurchasePhase.queued) return Right(purchase);

      final detachResult = await _detachQueuedCartItems(purchaseKey: purchase.idempotencyKey, items: purchase.cart.items);
      return detachResult.fold(Left.new, (_) async {
        final queuedPurchase = purchase.copyWith(phase: QueuedPurchasePhase.queued);
        final saveResult = await _repository.savePurchase(queuedPurchase);
        return saveResult.fold(Left.new, (_) => Right(queuedPurchase));
      });
    });
  }
}
