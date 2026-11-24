import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/assets/asset_paths.dart';
import '../../../../core/network/network_manager.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../catalog/data/models/product_model.dart';
import '../models/purchase_model.dart';

const String _checkoutReceiptPreferencesKey = 'GROCER_MATE_CHECKOUT_RECEIPT';

final class CheckoutOfflineException implements Exception {
  const CheckoutOfflineException();
}

abstract interface class CheckoutLocalDataSource {
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request);
}

final class CheckoutLocalDataSourceImpl implements CheckoutLocalDataSource {
  CheckoutLocalDataSourceImpl(this._preferences, this._networkManager, {AssetBundle? assetBundle, this.responseDelay = const Duration(milliseconds: 450)}) : _assetBundle = assetBundle ?? rootBundle;

  final NetworkManager _networkManager;
  final AppPreferences _preferences;
  final AssetBundle _assetBundle;
  final Duration responseDelay;

  CheckoutFixtureModel? _cachedFixture;

  /// Api & Request ************************************************************

  @override
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request) async {
    _validateRequest(request);
    await _requireConnection();
    final cachedResponse = await _loadIdempotentResponse(request.idempotencyKey);
    if (cachedResponse != null) return PurchaseResponseModel.fromJson(cachedResponse);
    if (responseDelay > Duration.zero) await Future<void>.delayed(responseDelay);

    final fixture = await _loadFixture();
    final catalogProducts = await _loadCatalogProducts();
    final priceChanges = <Map<String, dynamic>>[];
    final stockIssues = <Map<String, dynamic>>[];

    for (final item in request.items) {
      final currentProduct = fixture.products[item.productId] ?? catalogProducts[item.productId];
      if (currentProduct == null) {
        stockIssues.add(<String, dynamic>{'productId': item.productId, 'available': 0});
        continue;
      }

      if (request.enablePriceRevalidation && (item.expectedPrice - currentProduct.price).abs() > 0.001) {
        priceChanges.add(<String, dynamic>{'productId': item.productId, 'oldPrice': item.expectedPrice, 'newPrice': currentProduct.price});
      }
      if (item.quantity > currentProduct.stock) {
        stockIssues.add(<String, dynamic>{'productId': item.productId, 'available': currentProduct.stock});
      }
    }

    final Map<String, dynamic> response;
    if (priceChanges.isNotEmpty && stockIssues.isNotEmpty) {
      response = <String, dynamic>{'status': 'review_required', 'priceChanges': priceChanges, 'oos': stockIssues};
    } else if (priceChanges.isNotEmpty) {
      response = <String, dynamic>{'status': 'price_changed', 'changes': priceChanges};
    } else if (stockIssues.isNotEmpty) {
      response = <String, dynamic>{'status': 'out_of_stock', 'items': stockIssues};
    } else {
      await _requireConnection();
      response = <String, dynamic>{'status': 'success', 'orderId': fixture.orderId, 'finalTotal': double.parse(request.finalTotal.toStringAsFixed(2))};
    }
    final responseModel = PurchaseResponseModel.fromJson(response);
    if (response['status'] == 'success') {
      final idempotencyKey = request.idempotencyKey;
      if (idempotencyKey != null) await _saveIdempotentResponse(idempotencyKey, response);
    }
    return responseModel;
  }

  Future<void> _requireConnection() async {
    if (!await _networkManager.isConnected) throw const CheckoutOfflineException();
  }

  void _validateRequest(PurchaseRequestModel request) {
    if (request.items.isEmpty) throw const FormatException('Purchase items must not be empty.');
    if (request.currency.trim().isEmpty) throw const FormatException('Purchase currency must not be empty.');
    if (request.idempotencyKey case final key? when key.trim().isEmpty) {
      throw const FormatException('Purchase idempotencyKey must not be empty.');
    }
    for (final item in request.items) {
      if (item.productId.trim().isEmpty || item.quantity < 1 || !item.expectedPrice.isFinite || item.expectedPrice < 0) {
        throw const FormatException('Purchase item data is invalid.');
      }
    }
  }

  Future<Map<String, dynamic>?> _loadIdempotentResponse(String? idempotencyKey) async {
    if (idempotencyKey == null) return null;
    final cachedValue = await _preferences.getString(key: _checkoutReceiptPreferencesKey);
    if (cachedValue == null) return null;

    try {
      final decoded = jsonDecode(cachedValue) as Map<String, dynamic>;
      final cachedKey = decoded['idempotencyKey'] as String;
      final response = decoded['response'] as Map<String, dynamic>;
      return cachedKey == idempotencyKey ? response : null;
    } on TypeError catch (error) {
      throw FormatException('Cached checkout receipt has an invalid structure.', error);
    }
  }

  Future<void> _saveIdempotentResponse(String idempotencyKey, Map<String, dynamic> response) async {
    final encoded = jsonEncode(<String, dynamic>{'idempotencyKey': idempotencyKey, 'response': response});
    final didSave = await _preferences.setString(value: encoded, key: _checkoutReceiptPreferencesKey);
    if (!didSave) throw StateError('The checkout receipt could not be saved.');
  }

  Future<CheckoutFixtureModel> _loadFixture() async {
    final cachedFixture = _cachedFixture;
    if (cachedFixture != null) return cachedFixture;

    try {
      final decoded = jsonDecode(await _assetBundle.loadString(JsonAssets.purchase)) as Map<String, dynamic>;
      final fixture = CheckoutFixtureModel.fromJson(decoded);
      _cachedFixture = fixture;
      return fixture;
    } on TypeError catch (error) {
      throw FormatException('Checkout fixture has an invalid structure.', error);
    }
  }

  Future<Map<String, CheckoutProductSnapshotModel>> _loadCatalogProducts() async {
    try {
      final decoded = jsonDecode(await _assetBundle.loadString(JsonAssets.products)) as Map<String, dynamic>;
      final productValues = (decoded['products'] as List<dynamic>).cast<Map<String, dynamic>>();
      final products = <String, CheckoutProductSnapshotModel>{};
      for (final value in productValues) {
        final product = ProductModel.fromJson(value);
        products[product.id] = CheckoutProductSnapshotModel(productId: product.id, price: product.price, stock: product.stock);
      }
      return products;
    } on TypeError catch (error) {
      throw FormatException('Products fixture has an invalid structure.', error);
    }
  }
}
