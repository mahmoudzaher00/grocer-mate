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
    final values = await _readObjectList('categories');
    return values.map(CategoryModel.fromJson).toList(growable: false);
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
      throw ArgumentError.value(categoryId, 'categoryId', 'must not be empty');
    }

    final products = await _readProducts();
    return products.where((product) => categoryId == null || product.categoryId == categoryId).map((product) => product.brand).toSet().toList(growable: false)..sort();
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
    if (productId.trim().isEmpty) throw ArgumentError.value(productId, 'productId', 'must not be empty');

    final details = (await _readCache())['productDetails'];
    if (details == null) throw const CatalogCacheMissException();
    try {
      final value = (details as Map<String, dynamic>)[productId];
      if (value == null) throw const CatalogCacheMissException();
      return ProductDetailsModel.fromCacheJson(value as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw FormatException('Cached product details have an invalid structure.', error);
    }
  }

  @override
  Future<void> saveProductDetails(ProductDetailsModel productDetails) async {
    await _updateCache((cache) {
      final details = switch (cache['productDetails']) {
        final Map<String, dynamic> currentDetails => Map<String, dynamic>.of(currentDetails),
        _ => <String, dynamic>{},
      };
      details[productDetails.product.id] = productDetails.toCacheJson();
      cache['productDetails'] = details;
    });
  }

  Future<List<ProductModel>> _readProducts() async {
    final values = await _readObjectList('products');

    final productIds = <String>{};
    return values
        .map((value) {
          final product = ProductModel.fromJson(value);
          if (!productIds.add(product.id)) throw FormatException('Duplicate cached product id: ${product.id}.');
          return product;
        })
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _readObjectList(String key) async {
    final values = (await _readCache())[key];
    if (values == null) throw const CatalogCacheMissException();
    try {
      return (values as List<dynamic>).cast<Map<String, dynamic>>().toList(growable: false);
    } on TypeError catch (error) {
      throw FormatException('Cached $key has an invalid structure.', error);
    }
  }

  Future<Map<String, dynamic>> _readCache() async {
    return _decodeCache(await _preferences.getString(key: _catalogCacheKey));
  }

  Map<String, dynamic> _decodeCache(String? cachedValue) {
    if (cachedValue == null) return <String, dynamic>{};

    try {
      return Map<String, dynamic>.of(jsonDecode(cachedValue) as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw FormatException('Cached catalog has an invalid structure.', error);
    }
  }

  Future<void> _updateCache(void Function(Map<String, dynamic> cache) update) async {
    final didSave = await _preferences.updateString(
      key: _catalogCacheKey,
      update: (cachedValue) {
        late Map<String, dynamic> cache;
        try {
          cache = _decodeCache(cachedValue);
        } on FormatException {
          cache = <String, dynamic>{};
        }
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
