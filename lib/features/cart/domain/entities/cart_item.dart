import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineSubtotal => product.price * quantity;
  double get lineDiscount => (product.originalPrice - product.price) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  @override
  List<Object?> get props => [product, quantity];
}
