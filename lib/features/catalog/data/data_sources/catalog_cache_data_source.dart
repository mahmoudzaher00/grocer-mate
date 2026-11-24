import 'dart:convert';

import '../../../../core/storage/app_preferences.dart';
import '../models/category_model.dart';
import '../models/product_details_model.dart';
import '../models/product_model.dart';
import '../models/product_page_model.dart';

const String _catalogCacheKey = 'GROCER_MATE_CATALOG_CACHE';

abstract interface class CatalogCacheDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<void> saveCategories(List<CategoryModel> categories);

  Future<List<String>> getBrands({String? categoryId});

  Future<ProductPageModel> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''});

  Future<void> saveProducts(List<ProductModel> products);

  Future<ProductDetailsModel> getProductDetails(String productId);

  Future<void> saveProductDetails(ProductDetailsModel productDetails);
}

final class CatalogCacheDataSourceImpl implements CatalogCacheDataSource {
  const CatalogCacheDataSourceImpl(this._preferences);

  final AppPreferences _preferences;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final values = (await _readCache())['categories'];
    if (values == null) throw const CatalogCacheMissException();
    if (values is! List<dynamic>) throw const FormatException('Cached categories must be a list.');

    return values
        .map((value) {
          if (value is! Map<String, dynamic>) throw const FormatException('Each cached category must be an object.');
          return CategoryModel.fromJson(value);
        })
        .toList(growable: false);
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    await _updateCache((cache) {
      cache['categories'] = categories.map((category) => category.toJson()).toList(growable: false);
    });
  }

  @override
  Future<List<String>> getBrands({String? categoryId}) async {
    if (categoryId != null && categoryId.trim().isEmpty) {
      throw const FormatException('Category id must not be empty.');
    }

    final products = await _readProducts();
    return products.where((product) => categoryId == null || product.categoryId == categoryId).map((product) => product.brand).toSet().toList(growable: false)..sort();
  }

  @override
  Future<ProductPageModel> getProducts({required int page, required int pageSize, String? categoryId, String? brand, String searchQuery = ''}) async {
    if (categoryId != null && categoryId.trim().isEmpty) throw const FormatException('Category id must not be empty.');
    if (brand != null && brand.trim().isEmpty) throw const FormatException('Brand must not be empty.');
    if (page <= 0 || pageSize <= 0) throw const FormatException('Page and page size must be positive.');

    return ProductPageModel.fromProducts(products: await _readProducts(), categoryId: categoryId, brand: brand, searchQuery: searchQuery, page: page, pageSize: pageSize);
  }

  @override
  Future<void> saveProducts(List<ProductModel> products) async {
    await _updateCache((cache) {
      cache['products'] = products.map((product) => product.toJson()).toList(growable: false);
    });
  }

  @override
  Future<ProductDetailsModel> getProductDetails(String productId) async {
    if (productId.trim().isEmpty) throw const FormatException('Product id must not be empty.');

    final details = (await _readCache())['productDetails'];
    if (details == null) throw const CatalogCacheMissException();
    if (details is! Map<String, dynamic>) throw const FormatException('Cached product details must be an object.');

    final value = details[productId];
    if (value == null) throw const CatalogCacheMissException();
    if (value is! Map<String, dynamic>) throw const FormatException('Cached product details entry must be an object.');
    return ProductDetailsModel.fromCacheJson(value);
  }

  @override
  Future<void> saveProductDetails(ProductDetailsModel productDetails) async {
    await _updateCache((cache) {
      final currentDetails = cache['productDetails'];
      final details = currentDetails == null
          ? <String, dynamic>{}
          : currentDetails is Map<String, dynamic>
          ? Map<String, dynamic>.of(currentDetails)
          : throw const FormatException('Cached product details must be an object.');
      details[productDetails.product.id] = productDetails.toCacheJson();
      cache['productDetails'] = details;
    });
  }

  Future<List<ProductModel>> _readProducts() async {
    final values = (await _readCache())['products'];
    if (values == null) throw const CatalogCacheMissException();
    if (values is! List<dynamic>) throw const FormatException('Cached products must be a list.');

    final productIds = <String>{};
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) throw const FormatException('Each cached product must be an object.');
          final product = ProductModel.fromJson(value);
          if (!productIds.add(product.id)) throw FormatException('Duplicate cached product id: ${product.id}.');
          return product;
        })
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _readCache() async {
    return _decodeCache(await _preferences.getString(key: _catalogCacheKey));
  }

  Map<String, dynamic> _decodeCache(String? cachedValue) {
    if (cachedValue == null) return <String, dynamic>{};

    final decoded = jsonDecode(cachedValue);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Cached catalog must be an object.');
    return Map<String, dynamic>.of(decoded);
  }

  Future<void> _updateCache(void Function(Map<String, dynamic> cache) update) async {
    final didSave = await _preferences.updateString(
      key: _catalogCacheKey,
      update: (cachedValue) {
        final cache = _decodeCache(cachedValue);
        update(cache);
        return jsonEncode(cache);
      },
    );
    if (!didSave) throw StateError('The catalog cache could not be saved.');
  }
}

final class CatalogCacheMissException implements Exception {
  const CatalogCacheMissException();
}
