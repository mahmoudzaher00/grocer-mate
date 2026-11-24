import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/use_cases/load_cart.dart';
import '../../domain/use_cases/save_cart.dart';

part 'events.dart';
part 'states.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  /// Listener *****************************************************************

  CartBloc(this._loadCart, this._saveCart) : super(const CartInitial()) {
    on<CartEvent>(_onEvent, transformer: _sequential());
  }

  /// Data *********************************************************************

  final LoadCart _loadCart;
  final SaveCart _saveCart;

  /// Logic ********************************************************************

  EventTransformer<E> _sequential<E>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  Future<void> _onEvent(CartEvent event, Emitter<CartState> emit) {
    return switch (event) {
      CartRequested() || CartRetried() => _onCartRequested(emit),
      CartProductAdded() => _onProductAdded(event, emit),
      CartQuantityChanged() => _onQuantityChanged(event, emit),
      CartItemRemoved() => _onItemRemoved(event, emit),
      CartItemsMovedToSaved() => _onItemsMovedToSaved(event, emit),
      SavedItemsMovedToCart() => _onSavedItemsMovedToCart(event, emit),
      CartPurchaseCompleted() => _onPurchaseCompleted(event, emit),
    };
  }

  Cart? get _currentCart => state.cart;

  void _emitCart(Cart cart, Emitter<CartState> emit) {
    emit(cart.isEmpty ? CartEmpty(cart) : CartReady(cart));
  }

  List<CartItem> _replaceItem(List<CartItem> items, String productId, CartItem replacement) {
    return items.map((item) => item.product.id == productId ? replacement : item).toList(growable: false);
  }

  Future<void> _persist(Cart previousCart, Cart updatedCart, Emitter<CartState> emit, {String? notice}) async {
    final result = await _saveCart(previousCart: previousCart, updatedCart: updatedCart);
    result.fold(
      (failure) => emit(CartActionFailure(cart: previousCart, message: failure.errMessage)),
      (_) => notice == null ? _emitCart(updatedCart, emit) : emit(CartActionNotice(cart: updatedCart, message: notice)),
    );
  }

  /// Api & Request ************************************************************

  Future<void> _onCartRequested(Emitter<CartState> emit) async {
    emit(const CartLoading());
    final result = await _loadCart();
    result.fold((failure) => emit(CartError(failure.errMessage)), (cart) => _emitCart(cart, emit));
  }

  Future<void> _onProductAdded(CartProductAdded event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    if (cart == null || event.quantity < 1 || event.product.isOutOfStock) return;

    final existingQuantity = cart.quantityFor(event.product.id);
    final updatedQuantity = (existingQuantity + event.quantity).clamp(0, event.product.stock).toInt();
    if (updatedQuantity == existingQuantity) return;

    final items = <CartItem>[];
    var didReplace = false;
    for (final item in cart.items) {
      if (item.product.id == event.product.id) {
        items.add(CartItem(product: event.product, quantity: updatedQuantity));
        didReplace = true;
      } else {
        items.add(item);
      }
    }
    if (!didReplace) {
      items.add(CartItem(product: event.product, quantity: updatedQuantity));
    }
    await _persist(cart, cart.copyWith(items: items), emit);
  }

  Future<void> _onQuantityChanged(CartQuantityChanged event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    if (cart == null) return;

    CartItem? currentItem;
    for (final item in cart.items) {
      if (item.product.id == event.productId) {
        currentItem = item;
        break;
      }
    }
    if (currentItem == null || event.quantity < 1 || event.quantity > currentItem.product.stock || event.quantity == currentItem.quantity) return;

    final items = _replaceItem(cart.items, event.productId, currentItem.copyWith(quantity: event.quantity));
    await _persist(cart, cart.copyWith(items: items), emit);
  }

  Future<void> _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    if (cart == null || cart.quantityFor(event.productId) == 0) return;

    final items = cart.items.where((item) => item.product.id != event.productId).toList(growable: false);
    await _persist(cart, cart.copyWith(items: items), emit);
  }

  Future<void> _onItemsMovedToSaved(CartItemsMovedToSaved event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    final selectedIds = event.productIds.toSet();
    if (cart == null || selectedIds.isEmpty) return;

    final remainingCartItems = <CartItem>[];
    final savedItemsById = <String, CartItem>{for (final item in cart.savedItems) item.product.id: item};
    var didMoveItem = false;

    for (final item in cart.items) {
      if (!selectedIds.contains(item.product.id)) {
        remainingCartItems.add(item);
        continue;
      }

      final savedItem = savedItemsById[item.product.id];
      savedItemsById[item.product.id] = CartItem(product: item.product, quantity: item.quantity + (savedItem?.quantity ?? 0));
      didMoveItem = true;
    }

    if (!didMoveItem) return;
    final updatedCart = cart.copyWith(items: remainingCartItems, savedItems: savedItemsById.values.toList(growable: false));
    await _persist(cart, updatedCart, emit);
  }

  Future<void> _onSavedItemsMovedToCart(SavedItemsMovedToCart event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    final selectedIds = event.productIds.toSet();
    if (cart == null || selectedIds.isEmpty) return;

    final cartItems = List<CartItem>.of(cart.items);
    final cartIndexes = <String, int>{for (var index = 0; index < cartItems.length; index++) cartItems[index].product.id: index};
    final remainingSavedItems = <CartItem>[];
    var didMoveQuantity = false;
    var didReachStockLimit = false;

    for (final savedItem in cart.savedItems) {
      if (!selectedIds.contains(savedItem.product.id)) {
        remainingSavedItems.add(savedItem);
        continue;
      }

      final cartIndex = cartIndexes[savedItem.product.id];
      final currentCartItem = cartIndex == null ? null : cartItems[cartIndex];
      final stock = currentCartItem?.product.stock ?? savedItem.product.stock;
      final currentQuantity = currentCartItem?.quantity ?? 0;
      final availableCapacity = (stock - currentQuantity).clamp(0, stock).toInt();
      final movedQuantity = savedItem.quantity.clamp(0, availableCapacity).toInt();
      final remainingQuantity = savedItem.quantity - movedQuantity;

      if (movedQuantity > 0) {
        final movedItem = CartItem(product: currentCartItem?.product ?? savedItem.product, quantity: currentQuantity + movedQuantity);
        if (cartIndex == null) {
          cartIndexes[savedItem.product.id] = cartItems.length;
          cartItems.add(movedItem);
        } else {
          cartItems[cartIndex] = movedItem;
        }
        didMoveQuantity = true;
      }

      if (remainingQuantity > 0) {
        remainingSavedItems.add(savedItem.copyWith(quantity: remainingQuantity));
        didReachStockLimit = true;
      }
    }

    if (!didMoveQuantity) {
      if (didReachStockLimit) {
        emit(CartActionNotice(cart: cart, message: 'Selected items are already at their available stock limit in Cart.'));
      }
      return;
    }

    final updatedCart = cart.copyWith(items: cartItems, savedItems: remainingSavedItems);
    await _persist(cart, updatedCart, emit, notice: didReachStockLimit ? 'Some quantities remain Saved because Cart reached the available stock limit.' : null);
  }

  Future<void> _onPurchaseCompleted(CartPurchaseCompleted event, Emitter<CartState> emit) async {
    final cart = _currentCart;
    final purchasedIds = event.productIds.toSet();
    if (cart == null || purchasedIds.isEmpty) return;

    final remainingItems = cart.items.where((item) => !purchasedIds.contains(item.product.id)).toList(growable: false);
    if (remainingItems.length == cart.items.length) return;

    await _persist(cart, cart.copyWith(items: remainingItems), emit);
  }
}
