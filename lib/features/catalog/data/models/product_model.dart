import '../../domain/entities/product.dart';

final class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.brand,
    required super.price,
    required super.originalPrice,
    required super.stock,
    required super.imageUrl,
    required super.badges,
    required super.categoryId,
    required super.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      final rating = _readNonNegativeDouble(json, 'rating');
      if (rating > 5) throw const FormatException('Product rating must not be greater than 5.');

      return ProductModel(
        id: json['id'] as String,
        title: json['title'] as String,
        brand: json['brand'] as String,
        price: _readNonNegativeDouble(json, 'price'),
        originalPrice: _readNonNegativeDouble(json, 'originalPrice'),
        stock: _readNonNegativeInt(json, 'stock'),
        imageUrl: json['image'] as String,
        badges: (json['badges'] as List<dynamic>).cast<String>(),
        categoryId: json['categoryId'] as String,
        rating: rating,
      );
    } on TypeError catch (error) {
      throw FormatException('Product has an invalid structure.', error);
    }
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      title: product.title,
      brand: product.brand,
      price: product.price,
      originalPrice: product.originalPrice,
      stock: product.stock,
      imageUrl: product.imageUrl,
      badges: product.badges,
      categoryId: product.categoryId,
      rating: product.rating,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'brand': brand,
      'price': price,
      'originalPrice': originalPrice,
      'stock': stock,
      'image': imageUrl,
      'badges': badges,
      'categoryId': categoryId,
      'rating': rating,
    };
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key] as num;
    if (!value.isFinite || value < 0) throw FormatException('Product $key must be a non-negative number.');
    return value.toDouble();
  }

  static int _readNonNegativeInt(Map<String, dynamic> json, String key) {
    final value = json[key] as int;
    if (value < 0) throw FormatException('Product $key must be a non-negative integer.');
    return value;
  }
}
