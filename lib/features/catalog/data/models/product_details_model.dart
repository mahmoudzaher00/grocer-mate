import '../../domain/entities/product.dart';
import '../../domain/entities/product_details.dart';
import 'product_model.dart';

final class ProductDetailsModel extends ProductDetails {
  ProductDetailsModel({required super.product, required super.images, required super.description});

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json, {required Product product}) {
    final productId = json['productId'];
    final description = json['description'];
    final imagesJson = json['images'];

    if (productId is! String || productId.trim() != product.id) {
      throw const FormatException('Product details must reference the requested product.');
    }
    if (description is! String || description.trim().isEmpty) {
      throw const FormatException('Product description must be a non-empty string.');
    }
    if (imagesJson is! List<dynamic> || imagesJson.isEmpty) {
      throw const FormatException('Product details must contain at least one image.');
    }

    final images = imagesJson
        .map((image) {
          if (image is! String || image.trim().isEmpty) {
            throw const FormatException('Each product image must be a non-empty string.');
          }
          return image.trim();
        })
        .toList(growable: false);

    if (images.first != product.imageUrl) {
      throw const FormatException('The first details image must match the catalog image.');
    }

    return ProductDetailsModel(product: product, images: images, description: description.trim());
  }

  factory ProductDetailsModel.fromCacheJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    if (productJson is! Map<String, dynamic>) {
      throw const FormatException('Cached product details must contain a product.');
    }

    final product = ProductModel.fromJson(productJson);
    return ProductDetailsModel.fromJson(json, product: product);
  }

  Map<String, dynamic> toCacheJson() {
    return <String, dynamic>{'productId': product.id, 'product': ProductModel.fromEntity(product).toJson(), 'images': images, 'description': description};
  }
}
