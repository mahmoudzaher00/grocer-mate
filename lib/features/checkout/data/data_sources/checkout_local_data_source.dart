import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/resources/asset_manager.dart';
import '../models/purchase_model.dart';

abstract interface class CheckoutLocalDataSource {
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request);
}

final class CheckoutLocalDataSourceImpl implements CheckoutLocalDataSource {
  CheckoutLocalDataSourceImpl({AssetBundle? assetBundle, this.responseDelay = const Duration(milliseconds: 450)}) : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;
  final Duration responseDelay;

  CheckoutFixtureModel? _cachedFixture;

  /// Api & Request ************************************************************

  @override
  Future<PurchaseResponseModel> submitPurchase(PurchaseRequestModel request) async {
    _validateRequest(request);
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
    return PurchaseResponseModel.fromJson(response);
  }

  void _validateRequest(PurchaseRequestModel request) {
    if (request.items.isEmpty) throw const FormatException('Purchase items must not be empty.');
    if (request.currency.trim().isEmpty) throw const FormatException('Purchase currency must not be empty.');
    for (final item in request.items) {
      if (item.productId.trim().isEmpty || item.quantity < 1 || !item.expectedPrice.isFinite || item.expectedPrice < 0) {
        throw const FormatException('Purchase item data is invalid.');
      }
    }
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
