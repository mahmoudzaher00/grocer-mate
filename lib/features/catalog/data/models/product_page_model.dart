import '../../domain/entities/product_page.dart';
import 'product_model.dart';

final class ProductPageModel extends ProductPage {
  ProductPageModel({required List<ProductModel> products, required super.page, required super.pageSize, required super.total}) : super(products: products);

  factory ProductPageModel.fromProducts({required List<ProductModel> products, required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) {
    final normalizedSearch = searchQuery.trim().toLowerCase();
    final filteredProducts = products
        .where((product) {
          final matchesCategory = categoryId == null || product.categoryId == categoryId;
          final matchesBrand = brand == null || product.brand == brand;
          final matchesSearch = normalizedSearch.isEmpty || product.title.toLowerCase().contains(normalizedSearch);
          return matchesCategory && matchesBrand && matchesSearch;
        })
        .toList(growable: false);
    final startIndex = (page - 1) * pageSize;

    if (startIndex >= filteredProducts.length) {
      return ProductPageModel(products: const <ProductModel>[], page: page, pageSize: pageSize, total: filteredProducts.length);
    }

    final endIndex = (startIndex + pageSize).clamp(0, filteredProducts.length);
    return ProductPageModel(products: filteredProducts.sublist(startIndex, endIndex), page: page, pageSize: pageSize, total: filteredProducts.length);
  }
}
