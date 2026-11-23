import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/entities/cart.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/use_cases/submit_purchase.dart';

part 'events.dart';
part 'states.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  /// Listener *****************************************************************

  CheckoutBloc(this._submitPurchase) : super(const CheckoutInitial()) {
    on<CheckoutEvent>(_onEvent, transformer: _sequential());
  }

  /// Data *********************************************************************

  final SubmitPurchase _submitPurchase;
  List<String> _checkoutProductIds = const <String>[];

  /// Logic ********************************************************************

  EventTransformer<E> _sequential<E>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  Future<void> _onEvent(CheckoutEvent event, Emitter<CheckoutState> emit) async {
    switch (event) {
      case CheckoutStarted():
        await _onStarted(event, emit);
        return;
      case CheckoutPriceAccepted():
        _onPriceAccepted(event, emit);
        return;
      case CheckoutItemRemoved():
        _onItemRemoved(event, emit);
        return;
      case CheckoutQuantityAdjusted():
        _onQuantityAdjusted(event, emit);
        return;
      case CheckoutResubmitted():
        await _onResubmitted(emit);
        return;
      case CheckoutRetried():
        await _onRetried(emit);
        return;
    }
  }

  CartItem? _findItem(Cart cart, String productId) {
    for (final item in cart.items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  void _emitReview(PurchaseRequest request, PurchaseReview review, Emitter<CheckoutState> emit) {
    emit(CheckoutReviewRequired(request: request, review: review));
  }

  /// Api & Request ************************************************************

  Future<void> _onStarted(CheckoutStarted event, Emitter<CheckoutState> emit) async {
    final request = PurchaseRequest(event.cart);
    _checkoutProductIds = event.cart.items.map((item) => item.product.id).toList(growable: false);
    if (request.cart.isEmpty) {
      emit(CheckoutFailure(request: request, message: 'Your Cart is empty.'));
      return;
    }
    await _submit(request, emit);
  }

  void _onPriceAccepted(CheckoutPriceAccepted event, Emitter<CheckoutState> emit) {
    final currentState = state;
    if (currentState is! CheckoutReviewRequired) return;

    final change = currentState.review.priceChangeFor(event.productId);
    final item = _findItem(currentState.request.cart, event.productId);
    if (change == null || item == null) return;

    final updatedItems = currentState.request.cart.items
        .map((cartItem) => cartItem.product.id == event.productId ? cartItem.copyWith(product: cartItem.product.copyWith(price: change.newPrice)) : cartItem)
        .toList(growable: false);
    final request = currentState.request.copyWith(cart: currentState.request.cart.copyWith(items: updatedItems));
    final review = currentState.review.copyWith(priceChanges: currentState.review.priceChanges.where((item) => item.productId != event.productId).toList(growable: false));
    _emitReview(request, review, emit);
  }

  void _onItemRemoved(CheckoutItemRemoved event, Emitter<CheckoutState> emit) {
    final currentState = state;
    if (currentState is! CheckoutReviewRequired || _findItem(currentState.request.cart, event.productId) == null) return;

    final items = currentState.request.cart.items.where((item) => item.product.id != event.productId).toList(growable: false);
    final request = currentState.request.copyWith(cart: currentState.request.cart.copyWith(items: items));
    final review = currentState.review.copyWith(
      priceChanges: currentState.review.priceChanges.where((item) => item.productId != event.productId).toList(growable: false),
      stockIssues: currentState.review.stockIssues.where((item) => item.productId != event.productId).toList(growable: false),
    );
    _emitReview(request, review, emit);
  }

  void _onQuantityAdjusted(CheckoutQuantityAdjusted event, Emitter<CheckoutState> emit) {
    final currentState = state;
    if (currentState is! CheckoutReviewRequired) return;

    final issue = currentState.review.stockIssueFor(event.productId);
    final item = _findItem(currentState.request.cart, event.productId);
    if (issue == null || item == null || issue.available < 1 || event.quantity < 1 || event.quantity > issue.available || event.quantity >= item.quantity) return;

    final items = currentState.request.cart.items.map((cartItem) => cartItem.product.id == event.productId ? cartItem.copyWith(quantity: event.quantity) : cartItem).toList(growable: false);
    final request = currentState.request.copyWith(cart: currentState.request.cart.copyWith(items: items));
    final review = currentState.review.copyWith(stockIssues: currentState.review.stockIssues.where((item) => item.productId != event.productId).toList(growable: false));
    _emitReview(request, review, emit);
  }

  Future<void> _onResubmitted(Emitter<CheckoutState> emit) async {
    final currentState = state;
    if (currentState is! CheckoutReviewRequired || !currentState.review.isResolved || currentState.request.cart.isEmpty) return;
    await _submit(currentState.request, emit);
  }

  Future<void> _onRetried(Emitter<CheckoutState> emit) async {
    final currentState = state;
    if (currentState is! CheckoutFailure || currentState.request.cart.isEmpty) return;
    await _submit(currentState.request, emit);
  }

  Future<void> _submit(PurchaseRequest request, Emitter<CheckoutState> emit) async {
    emit(CheckoutSubmitting(request));
    final result = await _submitPurchase(request);
    result.fold(
      (failure) => emit(CheckoutFailure(request: request, message: failure.errMessage)),
      (purchaseResult) => switch (purchaseResult) {
        PurchaseSuccess() => emit(CheckoutSucceeded(purchase: purchaseResult, processedProductIds: _checkoutProductIds)),
        PurchaseReview() => emit(CheckoutReviewRequired(request: request, review: purchaseResult)),
      },
    );
  }
}
