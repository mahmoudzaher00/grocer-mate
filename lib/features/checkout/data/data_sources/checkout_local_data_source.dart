import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/assets/asset_paths.dart';
import '../../../../core/storage/app_preferences.dart';
import '../models/purchase_model.dart';

const String _checkoutReceiptPreferencesKey = 'GROCER_MATE_CHECKOUT_RECEIPT';

abstract interface class CheckoutLocalDataSource {
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request);
}

final class CheckoutLocalDataSourceImpl implements CheckoutLocalDataSource {
  CheckoutLocalDataSourceImpl(this._preferences, {AssetBundle? assetBundle, this.responseDelay = const Duration(milliseconds: 450)}) : _assetBundle = assetBundle ?? rootBundle;

  final AppPreferences _preferences;
  final AssetBundle _assetBundle;
  final Duration responseDelay;

  CheckoutFixtureModel? _cachedFixture;

  /// Api & Request ************************************************************

  @override
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request) async {
    _validateRequest(request);
    final cachedResponse = await _loadIdempotentResponse(request.idempotencyKey);
    if (cachedResponse != null) return PurchaseResponseModel.fromJson(cachedResponse);
    if (responseDelay > Duration.zero) await Future<void>.delayed(responseDelay);

    final fixture = await _loadFixture();
    final priceChanges = <Map<String, dynamic>>[];
    final stockIssues = <Map<String, dynamic>>[];

    for (final item in request.items) {
      final currentProduct = fixture.products[item.productId];
      if (currentProduct == null) continue;

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
      response = <String, dynamic>{'status': 'success', 'orderId': fixture.orderId, 'finalTotal': double.parse(request.finalTotal.toStringAsFixed(2))};
    }
    final responseModel = PurchaseResponseModel.fromJson(response);
    if (response['status'] == 'success') {
      final idempotencyKey = request.idempotencyKey;
      if (idempotencyKey != null) await _saveIdempotentResponse(idempotencyKey, response);
    }
    return responseModel;
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

    final decoded = jsonDecode(cachedValue);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Cached checkout receipt must be an object.');
    final cachedKey = decoded['idempotencyKey'];
    final response = decoded['response'];
    if (cachedKey is! String || response is! Map<String, dynamic>) {
      throw const FormatException('Cached checkout receipt is invalid.');
    }
    return cachedKey == idempotencyKey ? response : null;
  }

  Future<void> _saveIdempotentResponse(String idempotencyKey, Map<String, dynamic> response) async {
    final encoded = jsonEncode(<String, dynamic>{'idempotencyKey': idempotencyKey, 'response': response});
    final didSave = await _preferences.setString(value: encoded, key: _checkoutReceiptPreferencesKey);
    if (!didSave) throw StateError('The checkout receipt could not be saved.');
  }

  Future<CheckoutFixtureModel> _loadFixture() async {
    final cachedFixture = _cachedFixture;
    if (cachedFixture != null) return cachedFixture;

    final jsonString = await _assetBundle.loadString(JsonAssets.purchase);
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Checkout fixture must be an object.');

    final fixture = CheckoutFixtureModel.fromJson(decoded);
    _cachedFixture = fixture;
    return fixture;
  }
}
