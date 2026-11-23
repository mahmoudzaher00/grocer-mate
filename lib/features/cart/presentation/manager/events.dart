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
  const CartQuantityChanged({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
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

final class CartPurchaseCompleted extends CartEvent {
  CartPurchaseCompleted(Iterable<String> productIds) : productIds = List<String>.unmodifiable(productIds);

  final List<String> productIds;

  @override
  List<Object?> get props => [productIds];
}
