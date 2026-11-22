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
    final id = _readRequiredString(json, 'id');
    final title = _readRequiredString(json, 'title');
    final brand = _readRequiredString(json, 'brand');
    final price = _readNonNegativeDouble(json, 'price');
    final originalPrice = _readNonNegativeDouble(json, 'originalPrice');
    final stock = _readNonNegativeInt(json, 'stock');
    final imageUrl = _readRequiredString(json, 'image');
    final categoryId = _readRequiredString(json, 'categoryId');
    final rating = _readNonNegativeDouble(json, 'rating');
    final badges = _readBadges(json);

    if (rating > 5) {
      throw const FormatException('Product rating must not be greater than 5.');
    }

    return ProductModel(id: id, title: title, brand: brand, price: price, originalPrice: originalPrice, stock: stock, imageUrl: imageUrl, badges: badges, categoryId: categoryId, rating: rating);
  }

  static String _readRequiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Product $key must be a non-empty string.');
    }
    return value.trim();
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException('Product $key must be a non-negative number.');
    }
    return value.toDouble();
  }

  static int _readNonNegativeInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int || value < 0) {
      throw FormatException('Product $key must be a non-negative integer.');
    }
    return value;
  }

  static List<String> _readBadges(Map<String, dynamic> json) {
    final badgesJson = json['badges'];
    if (badgesJson is! List<dynamic>) {
      throw const FormatException('Product badges must be a list.');
    }

    return badgesJson
        .map((badge) {
          if (badge is! String || badge.trim().isEmpty) {
            throw const FormatException('Each product badge must be a non-empty string.');
          }
          return badge.trim();
        })
        .toList(growable: false);
  }
}
