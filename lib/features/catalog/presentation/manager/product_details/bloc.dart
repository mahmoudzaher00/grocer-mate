import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product_details.dart';
import '../../../domain/use_cases/get_product_details.dart';

part 'events.dart';
part 'states.dart';

class ProductDetailsBloc extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  /// Listener *****************************************************************

  ProductDetailsBloc(this._getProductDetails) : super(const ProductDetailsInitial()) {
    on<ProductDetailsRequested>(_onProductDetailsRequested);
  }

  /// Data *********************************************************************

  final GetProductDetails _getProductDetails;

  /// Api & Request ************************************************************

  Future<void> _onProductDetailsRequested(ProductDetailsRequested event, Emitter<ProductDetailsState> emit) async {
    emit(const ProductDetailsLoading());

    final result = await _getProductDetails(event.productId);
    result.fold((failure) => emit(ProductDetailsError(failure.errMessage)), (productDetails) => emit(ProductDetailsSuccess(productDetails)));
  }
}
