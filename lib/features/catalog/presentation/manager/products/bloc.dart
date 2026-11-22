import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/product_page.dart';
import '../../../domain/use_cases/get_products.dart';

part 'events.dart';
part 'states.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  /// Listener *****************************************************************

  ProductsBloc(this._getProducts) : super(const ProductsInitial()) {
    on<ProductsRequested>(_onProductsRequested);
    on<ProductsNextPageRequested>(_onProductsNextPageRequested);
    on<ProductsPageRetried>(_onProductsPageRetried);
  }

  /// Data *********************************************************************

  static const int _pageSize = 10;

  final GetProducts _getProducts;

  String? _categoryId;
  int _nextPage = 1;
  bool _isRequestInFlight = false;

  /// Logic ********************************************************************

  List<Product> _mergeProducts(List<Product> currentProducts, List<Product> newProducts) {
    final productsById = <String, Product>{for (final product in currentProducts) product.id: product};
    for (final product in newProducts) {
      productsById[product.id] = product;
    }
    return productsById.values.toList(growable: false);
  }

  void _emitFirstPage(ProductPage productPage, Emitter<ProductsState> emit) {
    if (productPage.products.isEmpty) {
      emit(const ProductsEmpty());
      return;
    }

    _nextPage = productPage.page + 1;
    emit(ProductsSuccess(products: productPage.products, hasNextPage: productPage.hasNextPage));
  }

  void _emitNextPage({required ProductPage productPage, required List<Product> currentProducts, required Emitter<ProductsState> emit}) {
    final products = _mergeProducts(currentProducts, productPage.products);
    _nextPage = productPage.page + 1;
    emit(ProductsSuccess(products: products, hasNextPage: productPage.hasNextPage));
  }

  /// Api & Request ************************************************************

  Future<void> _onProductsRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    if (_isRequestInFlight) return;

    _categoryId = event.categoryId;
    _nextPage = 1;
    _isRequestInFlight = true;
    emit(const ProductsLoading());

    final result = await _getProducts(categoryId: event.categoryId, page: _nextPage, pageSize: _pageSize);
    _isRequestInFlight = false;

    result.fold((failure) => emit(ProductsError(failure.errMessage)), (productPage) => _emitFirstPage(productPage, emit));
  }

  Future<void> _onProductsNextPageRequested(ProductsNextPageRequested event, Emitter<ProductsState> emit) async {
    final currentState = state;
    if (_isRequestInFlight || currentState is! ProductsSuccess || !currentState.hasNextPage) return;

    await _loadNextPage(currentProducts: currentState.products, emit: emit);
  }

  Future<void> _onProductsPageRetried(ProductsPageRetried event, Emitter<ProductsState> emit) async {
    final currentState = state;
    if (_isRequestInFlight || currentState is! ProductsPageError) return;

    await _loadNextPage(currentProducts: currentState.products, emit: emit);
  }

  Future<void> _loadNextPage({required List<Product> currentProducts, required Emitter<ProductsState> emit}) async {
    final categoryId = _categoryId;
    if (categoryId == null) return;

    _isRequestInFlight = true;
    emit(ProductsSuccess(products: currentProducts, hasNextPage: true, isLoadingNextPage: true));

    final result = await _getProducts(categoryId: categoryId, page: _nextPage, pageSize: _pageSize);
    _isRequestInFlight = false;

    result.fold(
      (failure) => emit(ProductsPageError(products: currentProducts, message: failure.errMessage)),
      (productPage) => _emitNextPage(productPage: productPage, currentProducts: currentProducts, emit: emit),
    );
  }
}
