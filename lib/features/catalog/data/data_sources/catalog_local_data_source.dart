import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/resources/asset_manager.dart';
import '../models/category_model.dart';
import '../models/product_details_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<String>> getBrands({String? categoryId});

  Future<ProductDetailsModel> getProductDetails(String productId);

  Future<ProductPageModel> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''});
}

final class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  CatalogLocalDataSourceImpl({AssetBundle? assetBundle, this.simulatePaginationFailure = false, this.productResponseDelay = const Duration(milliseconds: 350)})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final bool simulatePaginationFailure;
  final Duration productResponseDelay;

  List<ProductModel>? _cachedProducts;
  Map<String, Map<String, dynamic>>? _cachedProductDetails;
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
  Future<List<String>> getBrands({String? categoryId}) async {
    if (categoryId != null && categoryId.trim().isEmpty) {
      throw const FormatException('Category id must not be empty.');
    }

    final products = await _loadProducts();
    final brands = products.where((product) => categoryId == null || product.categoryId == categoryId).map((product) => product.brand).toSet().toList(growable: false)..sort();

    return brands;
  }

  @override
  Future<ProductDetailsModel> getProductDetails(String productId) async {
    if (productId.trim().isEmpty) {
      throw const FormatException('Product id must not be empty.');
    }

    if (productResponseDelay > Duration.zero) {
      await Future<void>.delayed(productResponseDelay);
    }

    final products = await _loadProducts();
    ProductModel? product;
    for (final candidate in products) {
      if (candidate.id == productId) {
        product = candidate;
        break;
      }
    }
    if (product == null) throw const ProductNotFoundException();

    final productDetails = await _loadProductDetails();
    final detailsJson = productDetails[productId];
    if (detailsJson == null) throw const ProductNotFoundException();

    return ProductDetailsModel.fromJson(detailsJson, product: product);
  }

  @override
  Future<ProductPageModel> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) async {
    if (categoryId != null && categoryId.trim().isEmpty) {
      throw const FormatException('Category id must not be empty.');
    }
    if (brand != null && brand.trim().isEmpty) {
      throw const FormatException('Brand must not be empty.');
    }
    if (page <= 0 || pageSize <= 0) {
      throw const FormatException('Page and page size must be positive.');
    }

    if (productResponseDelay > Duration.zero) {
      await Future<void>.delayed(productResponseDelay);
    }

    final failureKey = '$categoryId:$page';
    if (simulatePaginationFailure && categoryId == 'c_fruit' && brand == null && searchQuery.trim().isEmpty && page == 2 && _simulatedFailures.add(failureKey)) {
      throw const MockPageLoadException();
    }

    final products = await _loadProducts();
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

  Future<Map<String, Map<String, dynamic>>> _loadProductDetails() async {
    final cachedProductDetails = _cachedProductDetails;
    if (cachedProductDetails != null) return cachedProductDetails;

    final jsonString = await _assetBundle.loadString(JsonAssets.productDetails);
    final decodedJson = jsonDecode(jsonString);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Product details fixture must be a JSON object.');
    }

    final detailsJson = decodedJson['productDetails'];
    if (detailsJson is! List<dynamic>) {
      throw const FormatException('Product details fixture must contain a list.');
    }

    final detailsByProductId = <String, Map<String, dynamic>>{};
    for (final detailJson in detailsJson) {
      if (detailJson is! Map<String, dynamic>) {
        throw const FormatException('Each product details entry must be a JSON object.');
      }

      final productId = detailJson['productId'];
      if (productId is! String || productId.trim().isEmpty) {
        throw const FormatException('Each product details entry must contain a product id.');
      }
      if (detailsByProductId.containsKey(productId)) {
        throw FormatException('Duplicate product details id: $productId.');
      }
      detailsByProductId[productId] = detailJson;
    }

    _cachedProductDetails = Map<String, Map<String, dynamic>>.unmodifiable(detailsByProductId);
    return _cachedProductDetails!;
  }
}

final class MockPageLoadException implements Exception {
  const MockPageLoadException();
}

final class ProductNotFoundException implements Exception {
  const ProductNotFoundException();
}
