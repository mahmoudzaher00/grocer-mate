part of 'bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

final class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsSuccess extends ProductsState {
  ProductsSuccess({required List<Product> products, required this.hasNextPage, this.isLoadingNextPage = false}) : products = List<Product>.unmodifiable(products);

  final List<Product> products;
  final bool hasNextPage;
  final bool isLoadingNextPage;

  @override
  List<Object?> get props => [products, hasNextPage, isLoadingNextPage];
}

final class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProductsPageError extends ProductsState {
  ProductsPageError({required List<Product> products, required this.message}) : products = List<Product>.unmodifiable(products);

  final List<Product> products;
  final String message;

  @override
  List<Object?> get props => [products, message];
}
