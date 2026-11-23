import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_page.dart';
import '../../../domain/use_cases/get_brands.dart';
import '../../../domain/use_cases/get_categories.dart';
import '../../../domain/use_cases/get_products.dart';

part 'events.dart';
part 'states.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  /// Listener *****************************************************************

  ProductsBloc(this._getProducts, this._getCategories, this._getBrands) : super(const ProductsInitial()) {
    on<ProductsRequested>(_onProductsRequested);
    on<ProductsSearchChanged>(_onProductsSearchChanged);
    on<_ProductsSearchDebounced>(_onProductsSearchDebounced);
    on<ProductsCategoryChanged>(_onProductsCategoryChanged);
    on<ProductsBrandChanged>(_onProductsBrandChanged);
    on<ProductsFiltersCleared>(_onProductsFiltersCleared);
    on<ProductsRetried>(_onProductsRetried);
    on<ProductsNextPageRequested>(_onProductsNextPageRequested);
    on<ProductsPageRetried>(_onProductsPageRetried);
  }

  /// Data *********************************************************************

  static const int _pageSize = 10;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 400);

  final GetProducts _getProducts;
  final GetCategories _getCategories;
  final GetBrands _getBrands;

  List<Category> _categories = const <Category>[];
  List<String> _brands = const <String>[];
  String? _selectedCategoryId;
  String? _selectedBrand;
  String _searchQuery = '';
  int _nextPage = 1;
  int _queryRevision = 0;
  int? _pageRequestRevision;
  Timer? _searchDebounce;

  /// Logic ********************************************************************

  ProductsFilters get _filters {
    return ProductsFilters(categories: _categories, brands: _brands, searchQuery: _searchQuery, categoryId: _selectedCategoryId, brand: _selectedBrand);
  }

  bool _isCurrentRevision(int revision) => revision == _queryRevision;

  void _cancelSearchDebounce() {
    _searchDebounce?.cancel();
    _searchDebounce = null;
  }

  List<Product> _mergeProducts(List<Product> currentProducts, List<Product> newProducts) {
    final productsById = <String, Product>{for (final product in currentProducts) product.id: product};
    for (final product in newProducts) {
      productsById[product.id] = product;
    }
    return productsById.values.toList(growable: false);
  }

  void _emitFirstPage(ProductPage productPage, Emitter<ProductsState> emit) {
    if (productPage.products.isEmpty) {
      emit(ProductsEmpty(_filters));
      return;
    }

    _nextPage = productPage.page + 1;
    emit(ProductsSuccess(filters: _filters, products: productPage.products, hasNextPage: productPage.hasNextPage));
  }

  void _emitNextPage({required ProductPage productPage, required List<Product> currentProducts, required Emitter<ProductsState> emit}) {
    final products = _mergeProducts(currentProducts, productPage.products);
    _nextPage = productPage.page + 1;
    emit(ProductsSuccess(filters: _filters, products: products, hasNextPage: productPage.hasNextPage));
  }

  Future<({List<Category> categories, String? errorMessage})> _loadCategories() async {
    var categories = const <Category>[];
    String? errorMessage;
    final result = await _getCategories();
    result.fold((failure) => errorMessage = failure.errMessage, (loadedCategories) => categories = List<Category>.unmodifiable(loadedCategories));
    return (categories: categories, errorMessage: errorMessage);
  }

  Future<({List<String> brands, String? errorMessage})> _loadBrands() async {
    var brands = const <String>[];
    String? errorMessage;
    final result = await _getBrands(categoryId: _selectedCategoryId);
    result.fold((failure) => errorMessage = failure.errMessage, (loadedBrands) => brands = List<String>.unmodifiable(loadedBrands));
    return (brands: brands, errorMessage: errorMessage);
  }

  /// Api & Request ************************************************************

  Future<void> _onProductsRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    _cancelSearchDebounce();
    _selectedCategoryId = event.categoryId;
    _selectedBrand = null;
    _searchQuery = '';
    _categories = const <Category>[];
    _brands = const <String>[];

    await _refreshProducts(emit: emit, reloadCategories: true, reloadBrands: true);
  }

  void _onProductsSearchChanged(ProductsSearchChanged event, Emitter<ProductsState> emit) {
    final query = event.query.trim();
    if (_searchQuery == query && state.filters.searchQuery == query) return;

    _searchQuery = query;
    _cancelSearchDebounce();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      if (!isClosed) add(_ProductsSearchDebounced(query));
    });
  }

  Future<void> _onProductsSearchDebounced(_ProductsSearchDebounced event, Emitter<ProductsState> emit) async {
    if (event.query != _searchQuery) return;
    await _refreshProducts(emit: emit);
  }

  Future<void> _onProductsCategoryChanged(ProductsCategoryChanged event, Emitter<ProductsState> emit) async {
    if (_selectedCategoryId == event.categoryId) return;

    _cancelSearchDebounce();
    _selectedCategoryId = event.categoryId;
    _selectedBrand = null;
    await _refreshProducts(emit: emit, reloadBrands: true);
  }

  Future<void> _onProductsBrandChanged(ProductsBrandChanged event, Emitter<ProductsState> emit) async {
    if (_selectedBrand == event.brand) return;

    _cancelSearchDebounce();
    _selectedBrand = event.brand;
    await _refreshProducts(emit: emit);
  }

  Future<void> _onProductsFiltersCleared(ProductsFiltersCleared event, Emitter<ProductsState> emit) async {
    if (!_filters.hasActiveFilters) return;

    _cancelSearchDebounce();
    _selectedCategoryId = null;
    _selectedBrand = null;
    _searchQuery = '';
    await _refreshProducts(emit: emit, reloadBrands: true);
  }

  Future<void> _onProductsRetried(ProductsRetried event, Emitter<ProductsState> emit) async {
    _cancelSearchDebounce();
    await _refreshProducts(emit: emit, reloadCategories: _categories.isEmpty, reloadBrands: true);
  }

  Future<void> _refreshProducts({required Emitter<ProductsState> emit, bool reloadCategories = false, bool reloadBrands = false}) async {
    final revision = ++_queryRevision;
    _nextPage = 1;
    emit(ProductsLoading(_filters));

    if (reloadCategories) {
      final result = await _loadCategories();
      if (!_isCurrentRevision(revision)) return;
      if (result.errorMessage != null) {
        emit(ProductsError(filters: _filters, message: result.errorMessage!));
        return;
      }
      _categories = result.categories;
    }

    if (reloadBrands) {
      final result = await _loadBrands();
      if (!_isCurrentRevision(revision)) return;
      if (result.errorMessage != null) {
        emit(ProductsError(filters: _filters, message: result.errorMessage!));
        return;
      }
      _brands = result.brands;
    }

    await _loadFirstPage(revision: revision, emit: emit);
  }

  Future<void> _loadFirstPage({required int revision, required Emitter<ProductsState> emit}) async {
    _pageRequestRevision = revision;
    final result = await _getProducts(categoryId: _selectedCategoryId, brand: _selectedBrand, searchQuery: _searchQuery, page: 1, pageSize: _pageSize);

    if (_pageRequestRevision == revision) _pageRequestRevision = null;
    if (!_isCurrentRevision(revision)) return;

    result.fold((failure) => emit(ProductsError(filters: _filters, message: failure.errMessage)), (productPage) => _emitFirstPage(productPage, emit));
  }

  Future<void> _onProductsNextPageRequested(ProductsNextPageRequested event, Emitter<ProductsState> emit) async {
    final currentState = state;
    if (_pageRequestRevision == _queryRevision || currentState is! ProductsSuccess || !currentState.hasNextPage) return;

    await _loadNextPage(currentProducts: currentState.products, emit: emit);
  }

  Future<void> _onProductsPageRetried(ProductsPageRetried event, Emitter<ProductsState> emit) async {
    final currentState = state;
    if (_pageRequestRevision == _queryRevision || currentState is! ProductsPageError) return;

    await _loadNextPage(currentProducts: currentState.products, emit: emit);
  }

  Future<void> _loadNextPage({required List<Product> currentProducts, required Emitter<ProductsState> emit}) async {
    final revision = _queryRevision;
    _pageRequestRevision = revision;
    emit(ProductsSuccess(filters: _filters, products: currentProducts, hasNextPage: true, isLoadingNextPage: true));

    final result = await _getProducts(categoryId: _selectedCategoryId, brand: _selectedBrand, searchQuery: _searchQuery, page: _nextPage, pageSize: _pageSize);

    if (_pageRequestRevision == revision) _pageRequestRevision = null;
    if (!_isCurrentRevision(revision)) return;

    result.fold(
      (failure) => emit(ProductsPageError(filters: _filters, products: currentProducts, message: failure.errMessage)),
      (productPage) => _emitNextPage(productPage: productPage, currentProducts: currentProducts, emit: emit),
    );
  }

  @override
  Future<void> close() {
    _cancelSearchDebounce();
    return super.close();
  }
}
