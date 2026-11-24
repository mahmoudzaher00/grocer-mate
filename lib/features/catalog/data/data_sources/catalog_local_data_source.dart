import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/assets/asset_paths.dart';
import '../models/category_model.dart';
import '../models/product_details_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

abstract interface class CatalogLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<List<ProductModel>> getAllProducts();

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
    try {
      final decodedJson = jsonDecode(await _assetBundle.loadString(JsonAssets.categories)) as Map<String, dynamic>;
      return (decodedJson['categories'] as List<dynamic>).cast<Map<String, dynamic>>().map(CategoryModel.fromJson).toList(growable: false);
    } on TypeError catch (error) {
      throw FormatException('Categories fixture has an invalid structure.', error);
    }
  }

  @override
  Future<List<String>> getBrands({String? categoryId}) async {
    if (categoryId != null && categoryId.trim().isEmpty) {
      throw ArgumentError.value(categoryId, 'categoryId', 'must not be empty');
    }

    final products = await _loadProducts();
    final brands = products.where((product) => categoryId == null || product.categoryId == categoryId).map((product) => product.brand).toSet().toList(growable: false)..sort();

    return brands;
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    return List<ProductModel>.unmodifiable(await _loadProducts());
  }

  @override
  Future<ProductDetailsModel> getProductDetails(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError.value(productId, 'productId', 'must not be empty');
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
      throw ArgumentError.value(categoryId, 'categoryId', 'must not be empty');
    }
    if (brand != null && brand.trim().isEmpty) {
      throw ArgumentError.value(brand, 'brand', 'must not be empty');
    }
    if (page <= 0) throw ArgumentError.value(page, 'page', 'must be positive');
    if (pageSize <= 0) throw ArgumentError.value(pageSize, 'pageSize', 'must be positive');

    if (productResponseDelay > Duration.zero) {
      await Future<void>.delayed(productResponseDelay);
    }

    final failureKey = '$categoryId:$page';
    if (simulatePaginationFailure && categoryId == 'c_fruit' && brand == null && searchQuery.trim().isEmpty && page == 2 && _simulatedFailures.add(failureKey)) {
      throw const MockPageLoadException();
    }

    final products = await _loadProducts();
    return ProductPageModel.fromProducts(products: products, categoryId: categoryId, brand: brand, searchQuery: searchQuery, page: page, pageSize: pageSize);
  }

  Future<List<ProductModel>> _loadProducts() async {
    final cachedProducts = _cachedProducts;
    if (cachedProducts != null) return cachedProducts;

    try {
      final decodedJson = jsonDecode(await _assetBundle.loadString(JsonAssets.products)) as Map<String, dynamic>;
      final productIds = <String>{};
      final products = (decodedJson['products'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((productJson) {
            final product = ProductModel.fromJson(productJson);
            if (!productIds.add(product.id)) throw FormatException('Duplicate product id: ${product.id}.');
            return product;
          })
          .toList(growable: false);

      _cachedProducts = products;
      return products;
    } on TypeError catch (error) {
      throw FormatException('Products fixture has an invalid structure.', error);
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadProductDetails() async {
    final cachedProductDetails = _cachedProductDetails;
    if (cachedProductDetails != null) return cachedProductDetails;

    try {
      final decodedJson = jsonDecode(await _assetBundle.loadString(JsonAssets.productDetails)) as Map<String, dynamic>;
      final detailsJson = (decodedJson['productDetails'] as List<dynamic>).cast<Map<String, dynamic>>();
      final detailsByProductId = <String, Map<String, dynamic>>{};
      for (final detailJson in detailsJson) {
        final productId = detailJson['productId'] as String;
        if (productId.trim().isEmpty) throw const FormatException('Each product details entry must contain a product id.');
        if (detailsByProductId.containsKey(productId)) throw FormatException('Duplicate product details id: $productId.');
        detailsByProductId[productId] = detailJson;
      }

      final productDetails = Map<String, Map<String, dynamic>>.unmodifiable(detailsByProductId);
      _cachedProductDetails = productDetails;
      return productDetails;
    } on TypeError catch (error) {
      throw FormatException('Product details fixture has an invalid structure.', error);
    }
  }
}

final class MockPageLoadException implements Exception {
  const MockPageLoadException();
}

final class ProductNotFoundException implements Exception {
  const ProductNotFoundException();
}
