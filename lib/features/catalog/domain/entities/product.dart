import 'package:equatable/equatable.dart';

class Product extends Equatable {
  Product({
    required this.id,
    required this.title,
    required this.brand,
    required this.price,
    required this.originalPrice,
    required this.stock,
    required this.imageUrl,
    required List<String> badges,
    required this.categoryId,
    required this.rating,
  }) : badges = List<String>.unmodifiable(badges);

  final String id;
  final String title;
  final String brand;
  final double price;
  final double originalPrice;
  final int stock;
  final String imageUrl;
  final List<String> badges;
  final String categoryId;
  final double rating;

  bool get hasDiscount => originalPrice > price;
  bool get isOutOfStock => stock == 0;

  int get discountPercentage {
    if (!hasDiscount || originalPrice == 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  Product copyWith({double? price}) {
    return Product(
      id: id,
      title: title,
      brand: brand,
      price: price ?? this.price,
      originalPrice: originalPrice,
      stock: stock,
      imageUrl: imageUrl,
      badges: badges,
      categoryId: categoryId,
      rating: rating,
    );
  }

  @override
  List<Object?> get props => [id, title, brand, price, originalPrice, stock, imageUrl, badges, categoryId, rating];
}
