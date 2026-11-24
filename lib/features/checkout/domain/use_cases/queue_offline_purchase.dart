import 'dart:math';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/use_cases/detach_queued_cart_items.dart';
import '../entities/queued_purchase.dart';
import '../repositories/checkout_outbox_repository.dart';

class QueueOfflinePurchase {
  QueueOfflinePurchase(this._repository, this._detachQueuedCartItems);

  final CheckoutOutboxRepository _repository;
  final DetachQueuedCartItems _detachQueuedCartItems;
  final Random _random = Random.secure();

  Future<Either<Failure, QueuedPurchase>> call(Cart cart) async {
    if (cart.isEmpty) return const Left(DataFailure('Your Cart is empty.'));

    final loadResult = await _repository.loadPurchase();
    return loadResult.fold(Left.new, (existingPurchase) async {
      if (existingPurchase != null) return const Left(DataFailure('A purchase is already queued.'));

      final purchase = QueuedPurchase(
        idempotencyKey: _createIdempotencyKey(),
        cart: Cart(items: cart.items, savedItems: const [], pricing: cart.pricing),
        createdAt: DateTime.now().toUtc(),
        phase: QueuedPurchasePhase.detachingCart,
      );
      final detachResult = await _detachQueuedCartItems(purchaseKey: purchase.idempotencyKey, items: purchase.cart.items, persistPendingPurchase: () => _repository.savePurchase(purchase));
      return detachResult.fold(Left.new, (_) async {
        final queuedPurchase = purchase.copyWith(phase: QueuedPurchasePhase.queued);
        final readyResult = await _repository.savePurchase(queuedPurchase);
        return readyResult.fold(Left.new, (_) => Right(queuedPurchase));
      });
    });
  }

  String _createIdempotencyKey() {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final randomPart = _random.nextInt(0x7fffffff).toRadixString(16);
    return 'purchase-$timestamp-$randomPart';
  }
}
