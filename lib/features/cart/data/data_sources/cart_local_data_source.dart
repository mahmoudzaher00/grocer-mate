import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/app/app_prefs.dart';
import '../../../../core/resources/asset_manager.dart';
import '../models/cart_item_model.dart';
import '../models/cart_pricing_model.dart';

const String _cartPreferencesKey = 'GROCER_MATE_CART';

abstract interface class CartLocalDataSource {
  Future<List<CartItemModel>> loadCartItems();

  Future<CartPricingModel> loadPricing();

  Future<void> saveCartItems(List<CartItemModel> items);
}

final class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._preferences, {AssetBundle? assetBundle}) : _assetBundle = assetBundle ?? rootBundle;

  final AppPreferences _preferences;
  final AssetBundle _assetBundle;

  /// Api & Request ************************************************************

  @override
  Future<List<CartItemModel>> loadCartItems() async {
    final cachedValue = _preferences.getFromPreferences(key: _cartPreferencesKey);
    if (cachedValue == null) return const <CartItemModel>[];
    if (cachedValue is! String) {
      throw const FormatException('Cached cart must be a JSON string.');
    }

    final decoded = jsonDecode(cachedValue);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Cached cart must be a list.');
    }
    return decoded
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Each cart item must be an object.');
          }
          return CartItemModel.fromJson(item);
        })
        .toList(growable: false);
  }

  @override
  Future<CartPricingModel> loadPricing() async {
    final jsonString = await _assetBundle.loadString(JsonAssets.flags);
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cart flags must be an object.');
    }
    return CartPricingModel.fromJson(decoded);
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList(growable: false));
    final didSave = await _preferences.saveToPreferences(value: encoded, key: _cartPreferencesKey);
    if (!didSave) throw StateError('The cart could not be saved.');
  }
}
