import 'dart:convert';

import '../../../../core/storage/app_preferences.dart';
import '../models/queued_purchase_model.dart';

const String _checkoutOutboxPreferencesKey = 'GROCER_MATE_CHECKOUT_OUTBOX';

abstract interface class CheckoutOutboxLocalDataSource {
  Future<QueuedPurchaseModel?> loadPurchase();

  Future<void> savePurchase(QueuedPurchaseModel purchase);

  Future<void> clearPurchase();
}

final class CheckoutOutboxLocalDataSourceImpl implements CheckoutOutboxLocalDataSource {
  const CheckoutOutboxLocalDataSourceImpl(this._preferences);

  final AppPreferences _preferences;

  @override
  Future<QueuedPurchaseModel?> loadPurchase() async {
    final cachedValue = await _preferences.getString(key: _checkoutOutboxPreferencesKey);
    if (cachedValue == null) return null;

    final decoded = jsonDecode(cachedValue);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Cached queued purchase must be an object.');
    return QueuedPurchaseModel.fromJson(decoded);
  }

  @override
  Future<void> savePurchase(QueuedPurchaseModel purchase) async {
    final didSave = await _preferences.setString(value: jsonEncode(purchase.toJson()), key: _checkoutOutboxPreferencesKey);
    if (!didSave) throw StateError('The queued purchase could not be saved.');
  }

  @override
  Future<void> clearPurchase() async {
    final didClear = await _preferences.remove(key: _checkoutOutboxPreferencesKey);
    if (!didClear) throw StateError('The queued purchase could not be cleared.');
  }
}
