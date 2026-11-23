part of 'bloc.dart';

sealed class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

final class ProductDetailsLoading extends ProductDetailsState {
  const ProductDetailsLoading();
}

final class ProductDetailsSuccess extends ProductDetailsState {
  const ProductDetailsSuccess(this.productDetails);

  final ProductDetails productDetails;

  @override
  List<Object?> get props => [productDetails];
}

final class ProductDetailsError extends ProductDetailsState {
  const ProductDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
