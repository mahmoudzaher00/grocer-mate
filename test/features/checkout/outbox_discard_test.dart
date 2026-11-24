import 'dart:async';

import 'package:dartz/dartz.dart' show Either, Left, Unit;
import 'package:flutter_test/flutter_test.dart';
import 'package:grocer_mate/core/errors/failures.dart';
import 'package:grocer_mate/core/storage/app_preferences.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart_item.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart_pricing.dart';
import 'package:grocer_mate/features/catalog/domain/entities/product.dart';
import 'package:grocer_mate/features/checkout/data/data_sources/checkout_outbox_local_data_source.dart';
import 'package:grocer_mate/features/checkout/data/repositories/checkout_outbox_repository_impl.dart';
import 'package:grocer_mate/features/checkout/domain/entities/purchase.dart';
import 'package:grocer_mate/features/checkout/domain/entities/queued_purchase.dart';
import 'package:grocer_mate/features/checkout/domain/use_cases/clear_queued_purchase.dart';
import 'package:grocer_mate/features/checkout/domain/use_cases/queue_offline_purchase.dart';
import 'package:grocer_mate/features/checkout/domain/use_cases/recover_queued_purchase.dart';
import 'package:grocer_mate/features/checkout/presentation/manager/outbox/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnusedQueue extends Fake implements QueueOfflinePurchase {}

class _UnusedRecovery extends Fake implements RecoverQueuedPurchase {}

class _FailFirstClear extends ClearQueuedPurchase {
  _FailFirstClear(super.repository);
  int calls = 0;
  final firstAttempt = Completer<Either<Failure, Unit>>();
  @override
  Future<Either<Failure, Unit>> call() => ++calls == 1 ? firstAttempt.future : super.call();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('only a matching empty review can discard; dismissal preserves and failure retries', () async {
    const liveCart = '{"items":["banana"],"savedItems":["milk"]}';
    SharedPreferences.setMockInitialValues({'GROCER_MATE_CART': liveCart});
    final preferences = await AppPreferences.create();
    final repository = CheckoutOutboxRepositoryImpl(CheckoutOutboxLocalDataSourceImpl(preferences));
    final apple = Product(id: 'apple', title: 'Apple', brand: 'Farm', price: 2, originalPrice: 2, stock: 1, imageUrl: 'https://example.com/apple', badges: [], categoryId: 'fruits', rating: 5);
    final cart = Cart(
      items: [CartItem(product: apple, quantity: 1)],
      savedItems: [],
      pricing: const CartPricing(taxRate: .05, deliveryFee: 1, freeDeliveryThreshold: 25, currency: 'USD', enablePriceRevalidation: true),
    );
    final purchase = QueuedPurchase(cart: cart, idempotencyKey: 'queued-apple', createdAt: DateTime.utc(2026), phase: QueuedPurchasePhase.queued);
    expect((await repository.savePurchase(purchase)).isRight(), isTrue);
    final clearPurchase = _FailFirstClear(repository);
    final bootstrap = await repository.loadPurchase();
    final restored = bootstrap.fold((failure) => fail(failure.errMessage), (purchase) => purchase)!;
    expect(restored.idempotencyKey, purchase.idempotencyKey);
    expect(restored.cart.items.single.product.id, apple.id);
    final bloc = OutboxBloc(_UnusedQueue(), _UnusedRecovery(), clearPurchase, bootstrap);
    addTearDown(bloc.close);
    Future<void> sendUntil<T extends OutboxState>(OutboxEvent event) async {
      final next = bloc.stream.firstWhere((state) => state is T);
      bloc.add(event);
      await next;
    }

    bloc.add(const OutboxConnectivityChanged(true));
    await sendUntil<OutboxReadyForCheckout>(const OutboxAppActivityChanged(true));
    await sendUntil<OutboxCheckoutActive>(const OutboxCheckoutOpened());
    final reviewed = PurchaseRequest(cart.copyWith(items: []), idempotencyKey: purchase.idempotencyKey);
    bloc.add(OutboxQueuedPurchaseDiscarded(PurchaseRequest(reviewed.cart, idempotencyKey: 'another')));
    bloc.add(OutboxQueuedPurchaseDiscarded(PurchaseRequest(cart, idempotencyKey: purchase.idempotencyKey)));
    await sendUntil<OutboxDeferred>(const OutboxCheckoutClosed());
    expect(clearPurchase.calls, 0);
    expect((await repository.loadPurchase()).fold((failure) => fail(failure.errMessage), (purchase) => purchase), restored);
    await sendUntil<OutboxReadyForCheckout>(const OutboxManualReviewRequested());
    await sendUntil<OutboxCheckoutActive>(const OutboxCheckoutOpened());
    await sendUntil<OutboxClearing>(OutboxQueuedPurchaseDiscarded(reviewed));
    expect(bloc.state.hasPendingPurchase, true);
    final failed = bloc.stream.firstWhere((state) => state is OutboxCheckoutActive && state.discardFailed);
    clearPurchase.firstAttempt.complete(const Left(StorageFailure('storage unavailable')));
    expect((await failed).purchase, restored);
    expect((await repository.loadPurchase()).fold((failure) => fail(failure.errMessage), (purchase) => purchase), restored);
    await sendUntil<OutboxEmpty>(OutboxQueuedPurchaseDiscarded(reviewed));
    expect(clearPurchase.calls, 2);
    expect(bloc.state.hasPendingPurchase, false);
    expect((await repository.loadPurchase()).fold((f) => fail(f.errMessage), (p) => p), isNull);
    expect(await preferences.getString(key: 'GROCER_MATE_CART'), liveCart);
  });
}
