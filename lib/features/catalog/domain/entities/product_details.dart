import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductDetails extends Equatable {
  ProductDetails({required this.product, required List<String> images, required this.description}) : images = List<String>.unmodifiable(images);

  final Product product;
  final List<String> images;
  final String description;

  @override
  List<Object?> get props => [product, images, description];
}
