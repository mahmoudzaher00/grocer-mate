import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

final class CartItemModel extends CartItem {
  const CartItemModel({required super.product, required super.quantity});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final quantity = json['quantity'];
    if (productJson is! Map<String, dynamic>) {
      throw const FormatException('Cart product must be an object.');
    }
    if (quantity is! int || quantity < 1) {
      throw const FormatException('Cart quantity must be a positive integer.');
    }

    final product = ProductModel.fromJson(productJson);
    return CartItemModel(product: product, quantity: quantity);
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(product: item.product, quantity: item.quantity);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'product': _productToJson(product), 'quantity': quantity};
  }

  static Map<String, dynamic> _productToJson(Product product) {
    return <String, dynamic>{
      'id': product.id,
      'title': product.title,
      'brand': product.brand,
      'price': product.price,
      'originalPrice': product.originalPrice,
      'stock': product.stock,
      'image': product.imageUrl,
      'badges': product.badges,
      'categoryId': product.categoryId,
      'rating': product.rating,
    };
  }
}
