import 'package:equatable/equatable.dart';

import 'product.dart';

class ProductPage extends Equatable {
  ProductPage({required List<Product> products, required this.page, required this.pageSize, required this.total}) : products = List<Product>.unmodifiable(products);

  final List<Product> products;
  final int page;
  final int pageSize;
  final int total;

  bool get hasNextPage => page * pageSize < total;

  @override
  List<Object?> get props => [products, page, pageSize, total];
}
