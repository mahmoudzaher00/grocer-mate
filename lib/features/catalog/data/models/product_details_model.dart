import '../../domain/entities/product.dart';
import '../../domain/entities/product_details.dart';
import 'product_model.dart';

final class ProductDetailsModel extends ProductDetails {
  ProductDetailsModel({required super.product, required super.images, required super.description});

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json, {required Product product}) {
    try {
      if (json['productId'] as String != product.id) {
        throw const FormatException('Product details must reference the requested product.');
      }

      final images = (json['images'] as List<dynamic>).cast<String>();
      if (images.isEmpty) throw const FormatException('Product details must contain at least one image.');
      if (images.first != product.imageUrl) throw const FormatException('The first details image must match the catalog image.');

      return ProductDetailsModel(product: product, images: images, description: json['description'] as String);
    } on TypeError catch (error) {
      throw FormatException('Product details have an invalid structure.', error);
    }
  }

  factory ProductDetailsModel.fromCacheJson(Map<String, dynamic> json) {
    try {
      final product = ProductModel.fromJson(json['product'] as Map<String, dynamic>);
      return ProductDetailsModel.fromJson(json, product: product);
    } on TypeError catch (error) {
      throw FormatException('Cached product details have an invalid structure.', error);
    }
  }

  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{'productId': product.id, 'product': ProductModel.fromEntity(product).toJson(), 'images': images, 'description': description};
  }
}
