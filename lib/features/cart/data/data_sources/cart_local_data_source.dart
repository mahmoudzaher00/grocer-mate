import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/assets/asset_paths.dart';
import '../../../../core/storage/app_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/cart_pricing_model.dart';

const String _cartPreferencesKey = 'GROCER_MATE_CART';

typedef StoredCartData = ({List<CartItemModel> cartItems, List<CartItemModel> savedItems, String? lastDetachedPurchaseKey});

abstract interface class CartLocalDataSource {
  Future<StoredCartData> loadItems();

  Future<CartPricingModel> loadPricing();

  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems, String? lastDetachedPurchaseKey});
}

final class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._preferences, {AssetBundle? assetBundle}) : _assetBundle = assetBundle ?? rootBundle;

  final AppPreferences _preferences;
  final AssetBundle _assetBundle;

  @override
  Future<StoredCartData> loadItems() async {
    final cachedValue = await _preferences.getString(key: _cartPreferencesKey);
    if (cachedValue == null) return (cartItems: const <CartItemModel>[], savedItems: const <CartItemModel>[], lastDetachedPurchaseKey: null);

    try {
      final decoded = jsonDecode(cachedValue);
      if (decoded is List<dynamic>) {
        return (cartItems: _decodeItems(decoded), savedItems: const <CartItemModel>[], lastDetachedPurchaseKey: null);
      }

      final storedData = decoded as Map<String, dynamic>;
      final lastDetachedPurchaseKey = storedData['lastDetachedPurchaseKey'] as String?;
      if (lastDetachedPurchaseKey != null && lastDetachedPurchaseKey.trim().isEmpty) {
        throw const FormatException('The detached purchase key must be a non-empty string.');
      }

      return (cartItems: _decodeItems(storedData['cartItems'] as List<dynamic>), savedItems: _decodeItems(storedData['savedItems'] as List<dynamic>), lastDetachedPurchaseKey: lastDetachedPurchaseKey);
    } on TypeError catch (error) {
      throw FormatException('Cached shopping lists have an invalid structure.', error);
    }
  }

  @override
  Future<CartPricingModel> loadPricing() async {
    final jsonString = await _assetBundle.loadString(JsonAssets.flags);
    try {
      return CartPricingModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw FormatException('Cart flags have an invalid structure.', error);
    }
  }

  @override
  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems, String? lastDetachedPurchaseKey}) async {
    final encoded = jsonEncode(<String, dynamic>{
      'cartItems': cartItems.map((item) => item.toJson()).toList(growable: false),
      'savedItems': savedItems.map((item) => item.toJson()).toList(growable: false),
      'lastDetachedPurchaseKey': ?lastDetachedPurchaseKey,
    });
    final didSave = await _preferences.setString(value: encoded, key: _cartPreferencesKey);
    if (!didSave) throw StateError('The shopping lists could not be saved.');
  }

  List<CartItemModel> _decodeItems(List<dynamic> values) {
    return values.cast<Map<String, dynamic>>().map(CartItemModel.fromJson).toList(growable: false);
  }
}
