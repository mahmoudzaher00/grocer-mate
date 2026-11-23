import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'cart_pricing.dart';

class Cart extends Equatable {
  Cart({required List<CartItem> items, required List<CartItem> savedItems, required this.pricing}) : items = List<CartItem>.unmodifiable(items), savedItems = List<CartItem>.unmodifiable(savedItems);

  final List<CartItem> items;
  final List<CartItem> savedItems;
  final CartPricing pricing;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (total, item) => total + item.quantity);
  int get savedItemCount => savedItems.fold(0, (total, item) => total + item.quantity);
  double get subtotal => items.fold(0, (total, item) => total + item.lineSubtotal);
  double get discount => items.fold(0, (total, item) => total + item.lineDiscount);
  double get tax => subtotal * pricing.taxRate;
  double get deliveryFee => isEmpty || subtotal >= pricing.freeDeliveryThreshold ? 0 : pricing.deliveryFee;
  double get total => subtotal + tax + deliveryFee;

  int quantityFor(String productId) {
    for (final item in items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  Cart copyWith({List<CartItem>? items, List<CartItem>? savedItems}) {
    return Cart(items: items ?? this.items, savedItems: savedItems ?? this.savedItems, pricing: pricing);
  }

  @override
  List<Object?> get props => [items, savedItems, pricing];
}
