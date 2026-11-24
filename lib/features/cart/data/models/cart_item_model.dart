import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

final class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    try {
      final product = ProductModel.fromJson(json['product'] as Map<String, dynamic>);
      final quantity = json['quantity'] as int;
      if (quantity < 1) throw const FormatException('Cart quantity must be a positive integer.');

      return CartItemModel(product: product, quantity: quantity);
    } on TypeError catch (error) {
      throw FormatException('Cart item has an invalid structure.', error);
    }
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(product: item.product, quantity: item.quantity);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'product': ProductModel.fromEntity(product).toJson(), 'quantity': quantity};
  }
}
