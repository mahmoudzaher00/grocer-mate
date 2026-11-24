import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grocer_mate/core/errors/failures.dart';
import 'package:grocer_mate/features/cart/data/data_sources/cart_local_data_source.dart';
import 'package:grocer_mate/features/cart/data/models/cart_item_model.dart';
import 'package:grocer_mate/features/cart/data/models/cart_pricing_model.dart';
import 'package:grocer_mate/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart_item.dart';
import 'package:grocer_mate/features/catalog/data/models/product_model.dart';

void main() {
  group('CartRepositoryImpl', () {
    test('rejects stale Cart or Saved data without writing', () async {
      final persistedCart = [_item('cart', quantity: 2)];
      final persistedSaved = [_item('saved', quantity: 1)];
      final dataSource = _FakeCartLocalDataSource(cartItems: persistedCart, savedItems: persistedSaved);
      final repository = CartRepositoryImpl(dataSource);
      final previousCart = _cart(items: [_item('cart', quantity: 1)], savedItems: persistedSaved);
      final updatedCart = _cart(items: [_item('cart', quantity: 3)], savedItems: persistedSaved);

      final result = await repository.saveCart(previousCart: previousCart, updatedCart: updatedCart);

      expect(_failure(result), isA<StorageFailure>());
      expect(_failure(result)?.errMessage, 'The Cart changed while this update was being saved. Please try again.');
      expect(dataSource.saveCalls, 0);

      final savedMismatch = _FakeCartLocalDataSource(cartItems: persistedCart, savedItems: persistedSaved);
      final savedMismatchResult = await CartRepositoryImpl(savedMismatch).saveCart(
        previousCart: _cart(items: persistedCart, savedItems: const []),
        updatedCart: updatedCart,
      );

      expect(_failure(savedMismatchResult), isA<StorageFailure>());
      expect(savedMismatch.saveCalls, 0);
    });

    test('runs overlapping operations sequentially', () async {
      final dataSource = _FakeCartLocalDataSource(cartItems: [_item('cart')], pauseFirstLoad: true);
      final repository = CartRepositoryImpl(dataSource);

      final first = repository.loadCart();
      await dataSource.firstLoadStarted.future;
      final second = repository.loadCart();
      await Future<void>.delayed(Duration.zero);

      expect(dataSource.loadCalls, 1);
      expect(dataSource.maximumConcurrentLoads, 1);

      dataSource.releaseFirstLoad.complete();
      await Future.wait([first, second]);

      expect(dataSource.loadCalls, 2);
      expect(dataSource.maximumConcurrentLoads, 1);
    });

    test('rejects insufficient quantities before persisting outbox', () async {
      final dataSource = _FakeCartLocalDataSource(cartItems: [_item('cart', quantity: 1)]);
      final repository = CartRepositoryImpl(dataSource);
      var outboxPersistCalls = 0;

      final result = await repository.detachItemsForQueuedPurchase(
        purchaseKey: 'purchase-1',
        items: [_item('cart', quantity: 2)],
        persistPendingPurchase: () async {
          outboxPersistCalls++;
          dataSource.events.add('persistOutbox');
          return const Right(unit);
        },
      );

      expect(_failure(result), isA<DataFailure>());
      expect(_failure(result)?.errMessage, 'Queued quantities exceed the matching Cart quantities. The Cart was not changed.');
      expect(outboxPersistCalls, 0);
      expect(dataSource.saveCalls, 0);
      expect(dataSource.events, ['loadItems', 'loadPricing']);
    });

    test('idempotent detachment does not persist or write again', () async {
      final dataSource = _FakeCartLocalDataSource(cartItems: [_item('remaining', quantity: 1)], savedItems: [_item('saved', quantity: 2)], lastDetachedPurchaseKey: 'purchase-1');
      final repository = CartRepositoryImpl(dataSource);
      var outboxPersistCalls = 0;

      final result = await repository.detachItemsForQueuedPurchase(
        purchaseKey: 'purchase-1',
        items: [_item('already-detached')],
        persistPendingPurchase: () async {
          outboxPersistCalls++;
          return const Right(unit);
        },
      );

      final cart = _success(result);
      expect(cart?.items, dataSource.cartItems);
      expect(cart?.savedItems, dataSource.savedItems);
      expect(outboxPersistCalls, 0);
      expect(dataSource.saveCalls, 0);
      expect(dataSource.events, ['loadItems', 'loadPricing']);
    });

    test('recovers after outbox persisted but Cart write was interrupted', () async {
      final savedItems = [_item('saved', quantity: 4)];
      final originalItems = [_item('cart', quantity: 3), _item('other', quantity: 2)];
      final dataSource = _FakeCartLocalDataSource(cartItems: originalItems, savedItems: savedItems, failNextSave: true);
      final repository = CartRepositoryImpl(dataSource);
      var outboxPersistCalls = 0;

      final interrupted = await repository.detachItemsForQueuedPurchase(
        purchaseKey: 'purchase-1',
        items: originalItems,
        persistPendingPurchase: () async {
          outboxPersistCalls++;
          dataSource.events.add('persistOutbox');
          return const Right(unit);
        },
      );

      expect(_failure(interrupted), isA<StorageFailure>());
      expect(outboxPersistCalls, 1);
      expect(dataSource.events, ['loadItems', 'loadPricing', 'persistOutbox', 'saveItems']);
      expect(dataSource.cartItems, originalItems);
      expect(dataSource.savedItems, savedItems);
      expect(dataSource.lastDetachedPurchaseKey, isNull);

      dataSource.events.clear();
      final recovered = await repository.detachItemsForQueuedPurchase(purchaseKey: 'purchase-1', items: originalItems);

      final recoveredCart = _success(recovered);
      expect(recoveredCart?.items, isEmpty);
      expect(recoveredCart?.savedItems, savedItems);
      expect(dataSource.cartItems, isEmpty);
      expect(dataSource.savedItems, savedItems);
      expect(dataSource.lastDetachedPurchaseKey, 'purchase-1');
      expect(dataSource.events, ['loadItems', 'loadPricing', 'saveItems']);

      dataSource.events.clear();
      final repeatedRecovery = await repository.detachItemsForQueuedPurchase(purchaseKey: 'purchase-1', items: originalItems);

      expect(_success(repeatedRecovery)?.items, isEmpty);
      expect(dataSource.saveCalls, 2);
      expect(dataSource.events, ['loadItems', 'loadPricing']);
    });

    test('partial detachment preserves remaining Cart and all Saved items', () async {
      final savedItems = [_item('saved', quantity: 5)];
      final dataSource = _FakeCartLocalDataSource(cartItems: [_item('cart', quantity: 3), _item('other', quantity: 2)], savedItems: savedItems);
      final repository = CartRepositoryImpl(dataSource);

      final result = await repository.detachItemsForQueuedPurchase(purchaseKey: 'purchase-1', items: [_item('cart', quantity: 2)]);

      final cart = _success(result);
      expect(_itemValues(cart?.items ?? const []), [('cart', 1), ('other', 2)]);
      expect(cart?.savedItems, savedItems);
      expect(_itemValues(dataSource.cartItems), [('cart', 1), ('other', 2)]);
      expect(dataSource.savedItems, savedItems);
      expect(dataSource.lastDetachedPurchaseKey, 'purchase-1');
    });

    test('preserves aggregate detachment behavior for duplicate product lines', () async {
      final dataSource = _FakeCartLocalDataSource(cartItems: [_item('cart', quantity: 1), _item('cart', quantity: 2)]);
      final repository = CartRepositoryImpl(dataSource);

      final result = await repository.detachItemsForQueuedPurchase(purchaseKey: 'purchase-1', items: [_item('cart', quantity: 2)]);

      expect(_itemValues(_success(result)?.items ?? const []), [('cart', 1)]);
      expect(_itemValues(dataSource.cartItems), [('cart', 1)]);
      expect(dataSource.saveCalls, 1);
    });
  });
}

Failure? _failure<T>(Either<Failure, T> result) => result.fold((failure) => failure, (_) => null);

T? _success<T>(Either<Failure, T> result) => result.fold((_) => null, (value) => value);

List<(String, int)> _itemValues(List<CartItem> items) {
  return items.map((item) => (item.product.id, item.quantity)).toList(growable: false);
}

Cart _cart({required List<CartItem> items, required List<CartItem> savedItems}) {
  return Cart(items: items, savedItems: savedItems, pricing: _pricing);
}

CartItemModel _item(String id, {int quantity = 1, int stock = 10}) {
  return CartItemModel(
    product: ProductModel(id: id, title: id, brand: 'brand', price: 1, originalPrice: 1, stock: stock, imageUrl: 'image', badges: const [], categoryId: 'category', rating: 0),
    quantity: quantity,
  );
}

const _pricing = CartPricingModel(taxRate: 0, deliveryFee: 0, freeDeliveryThreshold: 0, currency: 'USD', enablePriceRevalidation: false);

final class _FakeCartLocalDataSource implements CartLocalDataSource {
  _FakeCartLocalDataSource({required List<CartItemModel> cartItems, List<CartItemModel> savedItems = const [], this.lastDetachedPurchaseKey, this.pauseFirstLoad = false, this.failNextSave = false})
    : cartItems = List.of(cartItems),
      savedItems = List.of(savedItems);

  List<CartItemModel> cartItems;
  List<CartItemModel> savedItems;
  String? lastDetachedPurchaseKey;
  final bool pauseFirstLoad;
  bool failNextSave;
  final events = <String>[];
  final firstLoadStarted = Completer<void>();
  final releaseFirstLoad = Completer<void>();
  int loadCalls = 0;
  int saveCalls = 0;
  int concurrentLoads = 0;
  int maximumConcurrentLoads = 0;

  @override
  Future<StoredCartData> loadItems() async {
    events.add('loadItems');
    loadCalls++;
    concurrentLoads++;
    if (concurrentLoads > maximumConcurrentLoads) {
      maximumConcurrentLoads = concurrentLoads;
    }
    if (pauseFirstLoad && loadCalls == 1) {
      firstLoadStarted.complete();
      await releaseFirstLoad.future;
    }
    concurrentLoads--;
    return (cartItems: List.of(cartItems), savedItems: List.of(savedItems), lastDetachedPurchaseKey: lastDetachedPurchaseKey);
  }

  @override
  Future<CartPricingModel> loadPricing() async {
    events.add('loadPricing');
    return _pricing;
  }

  @override
  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems, String? lastDetachedPurchaseKey}) async {
    events.add('saveItems');
    saveCalls++;
    if (failNextSave) {
      failNextSave = false;
      throw StateError('interrupted');
    }
    this.cartItems = List.of(cartItems);
    this.savedItems = List.of(savedItems);
    this.lastDetachedPurchaseKey = lastDetachedPurchaseKey;
  }
}
