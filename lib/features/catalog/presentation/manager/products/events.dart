part of 'bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsRequested extends ProductsEvent {
  const ProductsRequested(this.category);

  final Category category;

  @override
  List<Object?> get props => [category];
}

final class ProductsSearchChanged extends ProductsEvent {
  const ProductsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class _ProductsSearchDebounced extends ProductsEvent {
  const _ProductsSearchDebounced(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ProductsCategoryChanged extends ProductsEvent {
  const ProductsCategoryChanged(this.categoryId);

  final String? categoryId;

  @override
  List<Object?> get props => [categoryId];
}

final class ProductsBrandChanged extends ProductsEvent {
  const ProductsBrandChanged(this.brand);

  final String? brand;

  @override
  List<Object?> get props => [brand];
}

final class ProductsFiltersCleared extends ProductsEvent {
  const ProductsFiltersCleared();
}

final class ProductsRetried extends ProductsEvent {
  const ProductsRetried();
}

final class ProductsNextPageRequested extends ProductsEvent {
  const ProductsNextPageRequested();
}

final class ProductsPageRetried extends ProductsEvent {
  const ProductsPageRetried();
}
