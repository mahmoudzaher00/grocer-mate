import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../../core/app/app_prefs.dart';
import '../../../../core/resources/asset_manager.dart';
import '../models/cart_item_model.dart';
import '../models/cart_pricing_model.dart';

const String _cartPreferencesKey = 'GROCER_MATE_CART';

typedef CartItemsSnapshot = ({List<CartItemModel> cartItems, List<CartItemModel> savedItems});

abstract interface class CartLocalDataSource {
  Future<CartItemsSnapshot> loadItems();

  Future<CartPricingModel> loadPricing();

  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems});
}

final class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(this._preferences, {AssetBundle? assetBundle}) : _assetBundle = assetBundle ?? rootBundle;

  final AppPreferences _preferences;
  final AssetBundle _assetBundle;

  /// Api & Request ************************************************************

  @override
  Future<CartItemsSnapshot> loadItems() async {
    final cachedValue = _preferences.getFromPreferences(key: _cartPreferencesKey);
    if (cachedValue == null) return (cartItems: const <CartItemModel>[], savedItems: const <CartItemModel>[]);
    if (cachedValue is! String) {
      throw const FormatException('Cached cart must be a JSON string.');
    }

    final decoded = jsonDecode(cachedValue);
    if (decoded is List<dynamic>) {
      return (cartItems: _decodeItems(decoded, 'cart'), savedItems: const <CartItemModel>[]);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Cached shopping lists must be an object.');
    }
    final cartItems = decoded['cartItems'];
    final savedItems = decoded['savedItems'];
    if (cartItems is! List<dynamic> || savedItems is! List<dynamic>) {
      throw const FormatException('Cached cart and saved items must be lists.');
    }
    return (cartItems: _decodeItems(cartItems, 'cart'), savedItems: _decodeItems(savedItems, 'saved'));
  }

  List<CartItemModel> _decodeItems(List<dynamic> values, String listName) {
    return values
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException('Each $listName item must be an object.');
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
  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems}) async {
    final encoded = jsonEncode(<String, dynamic>{
      'cartItems': cartItems.map((item) => item.toJson()).toList(growable: false),
      'savedItems': savedItems.map((item) => item.toJson()).toList(growable: false),
    });
    final didSave = await _preferences.saveToPreferences(value: encoded, key: _cartPreferencesKey);
    if (!didSave) throw StateError('The shopping lists could not be saved.');
  }
}
