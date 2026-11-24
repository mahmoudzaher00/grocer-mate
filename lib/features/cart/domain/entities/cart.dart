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

  static int _cents(double amount) => (amount * 100).round();

  late final int _subtotalCents = items.fold<int>(0, (sum, item) => sum + _cents(item.product.price) * item.quantity);
  late final int _discountCents = items.fold<int>(0, (sum, item) => sum + (_cents(item.product.originalPrice) - _cents(item.product.price)) * item.quantity);
  late final int _taxCents = (_subtotalCents * pricing.taxRate).round();
  late final int _deliveryCents = isEmpty || _subtotalCents >= _cents(pricing.freeDeliveryThreshold) ? 0 : _cents(pricing.deliveryFee);

  double get subtotal => _subtotalCents / 100;
  double get discount => _discountCents / 100;
  double get tax => _taxCents / 100;
  double get deliveryFee => _deliveryCents / 100;
  double get total => (_subtotalCents + _taxCents + _deliveryCents) / 100;

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
