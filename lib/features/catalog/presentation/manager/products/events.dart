part of 'bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsRequested extends ProductsEvent {
  const ProductsRequested(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class ProductsNextPageRequested extends ProductsEvent {
  const ProductsNextPageRequested();
}

final class ProductsPageRetried extends ProductsEvent {
  const ProductsPageRetried();
}
