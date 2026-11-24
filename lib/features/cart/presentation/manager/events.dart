part of 'bloc.dart';

sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

final class CartRequested extends CartEvent {
  const CartRequested();
}

final class CartRetried extends CartEvent {
  const CartRetried();
}

final class CartProductAdded extends CartEvent {
  const CartProductAdded({required this.product, this.quantity = 1});

  final Product product;
  final int quantity;

  @override
  List<Object?> get props => [product, quantity];
}

final class CartQuantityChanged extends CartEvent {
  const CartQuantityChanged({required this.productId, required this.delta});

  final String productId;
  final int delta;

  @override
  List<Object?> get props => [productId, delta];
}

final class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class CartItemsMovedToSaved extends CartEvent {
  CartItemsMovedToSaved(Iterable<String> productIds) : productIds = List<String>.unmodifiable(productIds);

  final List<String> productIds;

  @override
  List<Object?> get props => [productIds];
}

final class SavedItemsMovedToCart extends CartEvent {
  SavedItemsMovedToCart(Iterable<String> productIds) : productIds = List<String>.unmodifiable(productIds);

  final List<String> productIds;

  @override
  List<Object?> get props => [productIds];
}

final class _CheckoutCartRequested extends CartEvent {
  const _CheckoutCartRequested(this.result);

  final Completer<Cart?> result;

  @override
  List<Object?> get props => [result];
}

final class CartPurchaseCompleted extends CartEvent {
  const CartPurchaseCompleted(this.purchasedCart);

  final Cart purchasedCart;

  @override
  List<Object?> get props => [purchasedCart];
}
