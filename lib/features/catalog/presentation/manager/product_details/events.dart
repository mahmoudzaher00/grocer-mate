part of 'bloc.dart';

sealed class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsRequested extends ProductDetailsEvent {
  const ProductDetailsRequested(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
