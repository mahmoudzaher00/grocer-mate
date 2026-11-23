part of 'bloc.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted(this.cart);

  final Cart cart;

  @override
  List<Object?> get props => [cart];
}

final class CheckoutPriceAccepted extends CheckoutEvent {
  const CheckoutPriceAccepted(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class CheckoutItemRemoved extends CheckoutEvent {
  const CheckoutItemRemoved(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

final class CheckoutQuantityAdjusted extends CheckoutEvent {
  const CheckoutQuantityAdjusted({required this.productId, required this.quantity});

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

final class CheckoutResubmitted extends CheckoutEvent {
  const CheckoutResubmitted();
}

final class CheckoutRetried extends CheckoutEvent {
  const CheckoutRetried();
}
