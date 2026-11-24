import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

final class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;
  Future<void> _operationTail = Future<void>.value();

  bool _itemsMatch(List<CartItem> persistedItems, List<CartItem> expectedItems) {
    if (persistedItems.length != expectedItems.length) return false;
    for (var index = 0; index < persistedItems.length; index++) {
      final persistedItem = persistedItems[index];
      final expectedItem = expectedItems[index];
      if (persistedItem.product.id != expectedItem.product.id || persistedItem.quantity != expectedItem.quantity) return false;
    }
    return true;
  }

  Future<T> _synchronized<T>(Future<T> Function() operation) async {
    final previousOperation = _operationTail;
    final release = Completer<void>();
    _operationTail = release.future;

    await previousOperation;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }

  @override
  Future<Either<Failure, Cart>> loadCart() {
    return _synchronized(() async {
      try {
        final snapshot = await _localDataSource.loadItems();
        if (snapshot.cartItems.any((item) => item.quantity > item.product.stock)) {
          throw const FormatException('A cart quantity exceeds available stock.');
        }
        final pricing = await _localDataSource.loadPricing();
        return Right(Cart(items: snapshot.cartItems, savedItems: snapshot.savedItems, pricing: pricing));
      } on FormatException {
        return const Left(DataFailure('The saved cart data is invalid.'));
      } on FlutterError {
        return const Left(DataFailure('The cart configuration could not be loaded.'));
      } on PlatformException {
        return const Left(StorageFailure('The saved cart could not be loaded.'));
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> saveCart({required Cart previousCart, required Cart updatedCart}) {
    return _synchronized(() async {
      try {
        if (updatedCart.items.any((item) => item.quantity > item.product.stock)) {
          throw const FormatException('A cart quantity exceeds available stock.');
        }

        final snapshot = await _localDataSource.loadItems();
        if (!_itemsMatch(snapshot.cartItems, previousCart.items) || !_itemsMatch(snapshot.savedItems, previousCart.savedItems)) {
          return const Left(StorageFailure('The Cart changed while this update was being saved. Please try again.'));
        }

        final cartItems = updatedCart.items.map(CartItemModel.fromEntity).toList(growable: false);
        final savedItems = updatedCart.savedItems.map(CartItemModel.fromEntity).toList(growable: false);
        await _localDataSource.saveItems(cartItems: cartItems, savedItems: savedItems, lastDetachedPurchaseKey: snapshot.lastDetachedPurchaseKey);
        return const Right(unit);
      } on FormatException {
        return const Left(DataFailure('The cart data is invalid.'));
      } on PlatformException {
        return const Left(StorageFailure('The cart could not be saved.'));
      } on StateError {
        return const Left(StorageFailure('The cart could not be saved.'));
      }
    });
  }

  @override
  Future<Either<Failure, Cart>> detachItemsForQueuedPurchase({required String purchaseKey, required List<CartItem> items, Future<Either<Failure, Unit>> Function()? persistPendingPurchase}) {
    return _synchronized(() async {
      try {
        if (purchaseKey.trim().isEmpty || items.isEmpty) {
          throw const FormatException('Queued purchase detachment data is invalid.');
        }

        final snapshot = await _localDataSource.loadItems();
        final pricing = await _localDataSource.loadPricing();
        final currentCart = Cart(items: snapshot.cartItems, savedItems: snapshot.savedItems, pricing: pricing);
        if (snapshot.lastDetachedPurchaseKey == purchaseKey) return Right(currentCart);

        final queuedQuantities = <String, int>{};
        for (final item in items) {
          final productId = item.product.id.trim();
          if (productId.isEmpty || item.quantity < 1) {
            throw const FormatException('Queued purchase items must have valid products and quantities.');
          }
          queuedQuantities.update(productId, (quantity) => quantity + item.quantity, ifAbsent: () => item.quantity);
        }

        final cartQuantities = <String, int>{};
        for (final item in currentCart.items) {
          cartQuantities.update(item.product.id, (quantity) => quantity + item.quantity, ifAbsent: () => item.quantity);
        }
        for (final entry in queuedQuantities.entries) {
          if ((cartQuantities[entry.key] ?? 0) < entry.value) {
            return const Left(DataFailure('Queued quantities exceed the matching Cart quantities. The Cart was not changed.'));
          }
        }

        if (persistPendingPurchase != null) {
          if (!_itemsMatch(currentCart.items, items)) {
            return const Left(DataFailure('The Cart changed. Review it before queuing your purchase.'));
          }
          // Keep validation and the durable detachment intent inside the same cart operation.
          final saved = await persistPendingPurchase();
          final failure = saved.fold<Failure?>((failure) => failure, (_) => null);
          if (failure != null) return Left(failure);
        }

        final quantitiesToDetach = Map<String, int>.of(queuedQuantities);
        final remainingItems = <CartItem>[];
        for (final item in currentCart.items) {
          final queuedQuantity = quantitiesToDetach[item.product.id] ?? 0;
          final detachedQuantity = queuedQuantity.clamp(0, item.quantity).toInt();
          final remainingQuantity = item.quantity - detachedQuantity;
          quantitiesToDetach[item.product.id] = queuedQuantity - detachedQuantity;
          if (remainingQuantity > 0) remainingItems.add(item.copyWith(quantity: remainingQuantity));
        }

        final cartItems = remainingItems.map(CartItemModel.fromEntity).toList(growable: false);
        await _localDataSource.saveItems(cartItems: cartItems, savedItems: snapshot.savedItems, lastDetachedPurchaseKey: purchaseKey);
        return Right(currentCart.copyWith(items: remainingItems));
      } on FormatException {
        return const Left(DataFailure('The queued purchase could not be detached from Cart.'));
      } on FlutterError {
        return const Left(DataFailure('The cart configuration could not be loaded.'));
      } on PlatformException {
        return const Left(StorageFailure('The queued purchase could not update Cart storage.'));
      } on StateError {
        return const Left(StorageFailure('The queued purchase could not update Cart storage.'));
      }
    });
  }
}
