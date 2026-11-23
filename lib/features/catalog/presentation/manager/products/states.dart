part of 'bloc.dart';

final class ProductFilterOption extends Equatable {
  const ProductFilterOption({required this.label, this.value});

  final String label;
  final String? value;

  @override
  List<Object?> get props => [label, value];
}

final class ProductsFilters extends Equatable {
  const ProductsFilters({this.categories = const <Category>[], this.brands = const <String>[], this.searchQuery = '', this.categoryId, this.brand});

  final List<Category> categories;
  final List<String> brands;
  final String searchQuery;
  final String? categoryId;
  final String? brand;

  bool get hasActiveFilters => searchQuery.isNotEmpty || categoryId != null || brand != null;

  String get categoryLabel {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'All categories';
  }

  String get brandLabel => brand ?? 'All brands';

  List<ProductFilterOption> get categoryOptions {
    return <ProductFilterOption>[const ProductFilterOption(label: 'All categories'), ...categories.map((category) => ProductFilterOption(label: category.name, value: category.id))];
  }

  List<ProductFilterOption> get brandOptions {
    return <ProductFilterOption>[const ProductFilterOption(label: 'All brands'), ...brands.map((brand) => ProductFilterOption(label: brand, value: brand))];
  }

  @override
  List<Object?> get props => [categories, brands, searchQuery, categoryId, brand];
}

sealed class ProductsState extends Equatable {
  const ProductsState(this.filters);

  final ProductsFilters filters;

  @override
  List<Object?> get props => [filters];
}

final class ProductsInitial extends ProductsState {
  const ProductsInitial() : super(const ProductsFilters());
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading(super.filters);
}

final class ProductsSuccess extends ProductsState {
  ProductsSuccess({required ProductsFilters filters, required List<Product> products, required this.hasNextPage, this.isLoadingNextPage = false})
    : products = List<Product>.unmodifiable(products),
      super(filters);

  final List<Product> products;
  final bool hasNextPage;
  final bool isLoadingNextPage;

  @override
  List<Object?> get props => [filters, products, hasNextPage, isLoadingNextPage];
}

final class ProductsEmpty extends ProductsState {
  const ProductsEmpty(super.filters);
}

final class ProductsError extends ProductsState {
  const ProductsError({required ProductsFilters filters, required this.message}) : super(filters);

  final String message;

  @override
  List<Object?> get props => [filters, message];
}

final class ProductsPageError extends ProductsState {
  ProductsPageError({required ProductsFilters filters, required List<Product> products, required this.message}) : products = List<Product>.unmodifiable(products), super(filters);

  final List<Product> products;
  final String message;

  @override
  List<Object?> get props => [filters, products, message];
}
