part of 'bloc.dart';

sealed class CartState extends Equatable {
  const CartState({this.cart});

  final Cart? cart;

  @override
  List<Object?> get props => [cart];
}

final class CartInitial extends CartState {
  const CartInitial();
}

final class CartLoading extends CartState {
  const CartLoading();
}

final class CartReady extends CartState {
  const CartReady(Cart cart) : super(cart: cart);
}

final class CartEmpty extends CartState {
  const CartEmpty(Cart cart) : super(cart: cart);
}

final class CartError extends CartState {
  const CartError(this.message);

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class CartActionFailure extends CartState {
  const CartActionFailure({required Cart cart, required this.message}) : super(cart: cart);

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}
