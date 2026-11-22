import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/resources/asset_manager.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<ProductPageModel> getProducts({required String categoryId, required int page, required int pageSize});
}

final class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  CatalogLocalDataSourceImpl({AssetBundle? assetBundle, this.simulatePaginationFailure = false, this.productResponseDelay = const Duration(milliseconds: 350)})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final bool simulatePaginationFailure;
  final Duration productResponseDelay;

  List<ProductModel>? _cachedProducts;
  final Set<String> _simulatedFailures = <String>{};

  /// Api & Request ************************************************************

  @override
  Future<List<CategoryModel>> getCategories() async {
    final jsonString = await _assetBundle.loadString(JsonAssets.categories);
    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Categories fixture must be a JSON object.');
    }

    final categoriesJson = decodedJson['categories'];
    if (categoriesJson is! List<dynamic>) {
      throw const FormatException('Categories fixture must contain a list.');
    }

    return categoriesJson
        .map((categoryJson) {
          if (categoryJson is! Map<String, dynamic>) {
            throw const FormatException('Each category must be a JSON object.');
          }
          return CategoryModel.fromJson(categoryJson);
        })
        .toList(growable: false);
  }

  @override
  Future<ProductPageModel> getProducts({required String categoryId, required int page, required int pageSize}) async {
    if (categoryId.trim().isEmpty) {
      throw const FormatException('A category id is required.');
    }
    if (page <= 0 || pageSize <= 0) {
      throw const FormatException('Page and page size must be positive.');
    }

    if (productResponseDelay > Duration.zero) {
      await Future<void>.delayed(productResponseDelay);
    }

    final failureKey = '$categoryId:$page';
    if (simulatePaginationFailure && categoryId == 'c_fruit' && page == 2 && _simulatedFailures.add(failureKey)) {
      throw const MockPageLoadException();
    }

    final products = await _loadProducts();
    final categoryProducts = products.where((product) => product.categoryId == categoryId).toList(growable: false);
    final startIndex = (page - 1) * pageSize;

    if (startIndex >= categoryProducts.length) {
      return ProductPageModel(products: const <ProductModel>[], page: page, pageSize: pageSize, total: categoryProducts.length);
    }

    final endIndex = (startIndex + pageSize).clamp(0, categoryProducts.length);
    return ProductPageModel(products: categoryProducts.sublist(startIndex, endIndex), page: page, pageSize: pageSize, total: categoryProducts.length);
  }

  Future<List<ProductModel>> _loadProducts() async {
    final cachedProducts = _cachedProducts;
    if (cachedProducts != null) return cachedProducts;

    final jsonString = await _assetBundle.loadString(JsonAssets.products);
    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Products fixture must be a JSON object.');
    }

    final productsJson = decodedJson['products'];
    if (productsJson is! List<dynamic>) {
      throw const FormatException('Products fixture must contain a list.');
    }

    final productIds = <String>{};
    final products = productsJson
        .map((productJson) {
          if (productJson is! Map<String, dynamic>) {
            throw const FormatException('Each product must be a JSON object.');
          }

          final product = ProductModel.fromJson(productJson);
          if (!productIds.add(product.id)) {
            throw FormatException('Duplicate product id: ${product.id}.');
          }
          return product;
        })
        .toList(growable: false);

    _cachedProducts = products;
    return products;
  }
}

final class MockPageLoadException implements Exception {
  const MockPageLoadException();
}
