import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/data/models/cart_pricing_model.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../domain/entities/queued_purchase.dart';

final class QueuedPurchaseModel {
  QueuedPurchaseModel({required this.idempotencyKey, required List<CartItemModel> items, required this.pricing, required this.createdAt, required this.phase})
    : items = List<CartItemModel>.unmodifiable(items);

  factory QueuedPurchaseModel.fromEntity(QueuedPurchase purchase) {
    return QueuedPurchaseModel(
      idempotencyKey: purchase.idempotencyKey,
      items: purchase.cart.items.map(CartItemModel.fromEntity).toList(growable: false),
      pricing: CartPricingModel.fromEntity(purchase.cart.pricing),
      createdAt: purchase.createdAt,
      phase: purchase.phase,
    );
  }

  factory QueuedPurchaseModel.fromJson(Map<String, dynamic> json) {
    final idempotencyKey = json['idempotencyKey'];
    final itemValues = json['items'];
    final pricingValue = json['pricing'];
    final createdAtValue = json['createdAt'];
    final phaseValue = json['phase'];

    if (idempotencyKey is! String || idempotencyKey.trim().isEmpty) {
      throw const FormatException('Queued purchase idempotencyKey must be a non-empty string.');
    }
    if (itemValues is! List<dynamic> || itemValues.isEmpty) {
      throw const FormatException('Queued purchase items must be a non-empty list.');
    }
    if (pricingValue is! Map<String, dynamic>) {
      throw const FormatException('Queued purchase pricing must be an object.');
    }
    if (createdAtValue is! String) {
      throw const FormatException('Queued purchase createdAt must be a string.');
    }
    if (phaseValue is! String) {
      throw const FormatException('Queued purchase phase must be a string.');
    }

    final createdAt = DateTime.tryParse(createdAtValue);
    if (createdAt == null) throw const FormatException('Queued purchase createdAt is invalid.');

    final QueuedPurchasePhase phase;
    try {
      phase = QueuedPurchasePhase.values.byName(phaseValue);
    } on ArgumentError {
      throw const FormatException('Queued purchase phase is invalid.');
    }

    final items = itemValues
        .map((value) {
          if (value is! Map<String, dynamic>) throw const FormatException('Each queued purchase item must be an object.');
          return CartItemModel.fromJson(value);
        })
        .toList(growable: false);

    return QueuedPurchaseModel(idempotencyKey: idempotencyKey.trim(), items: items, pricing: CartPricingModel.fromJson(pricingValue), createdAt: createdAt.toUtc(), phase: phase);
  }

  final String idempotencyKey;
  final List<CartItemModel> items;
  final CartPricingModel pricing;
  final DateTime createdAt;
  final QueuedPurchasePhase phase;

  QueuedPurchase toEntity() {
    return QueuedPurchase(
      idempotencyKey: idempotencyKey,
      cart: Cart(items: items, savedItems: const [], pricing: pricing),
      createdAt: createdAt,
      phase: phase,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'idempotencyKey': idempotencyKey,
      'items': items.map((item) => item.toJson()).toList(growable: false),
      'pricing': pricing.toJson(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'phase': phase.name,
    };
  }
}
