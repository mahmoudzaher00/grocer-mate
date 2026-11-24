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
    try {
      final idempotencyKey = json['idempotencyKey'] as String;
      final itemValues = json['items'] as List<dynamic>;
      if (idempotencyKey.isEmpty) throw const FormatException('Queued purchase idempotencyKey must not be empty.');
      if (itemValues.isEmpty) throw const FormatException('Queued purchase items must not be empty.');

      return QueuedPurchaseModel(
        idempotencyKey: idempotencyKey,
        items: itemValues.cast<Map<String, dynamic>>().map(CartItemModel.fromJson).toList(growable: false),
        pricing: CartPricingModel.fromJson(json['pricing'] as Map<String, dynamic>),
        createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
        phase: QueuedPurchasePhase.values.byName(json['phase'] as String),
      );
    } on ArgumentError {
      throw const FormatException('Queued purchase phase is invalid.');
    } on TypeError catch (error) {
      throw FormatException('Queued purchase has an invalid structure.', error);
    }
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
