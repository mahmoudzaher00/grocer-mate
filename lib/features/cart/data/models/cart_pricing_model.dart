import '../../domain/entities/cart_pricing.dart';

final class CartPricingModel extends CartPricing {
  const CartPricingModel({required super.taxRate, required super.deliveryFee, required super.freeDeliveryThreshold, required super.currency, required super.enablePriceRevalidation});

  factory CartPricingModel.fromEntity(CartPricing pricing) {
    return CartPricingModel(
      taxRate: pricing.taxRate,
      deliveryFee: pricing.deliveryFee,
      freeDeliveryThreshold: pricing.freeDeliveryThreshold,
      currency: pricing.currency,
      enablePriceRevalidation: pricing.enablePriceRevalidation,
    );
  }

  factory CartPricingModel.fromJson(Map<String, dynamic> json) {
    try {
      final taxRate = _readNonNegativeDouble(json, 'taxRate');
      final deliveryFee = _readNonNegativeDouble(json, 'deliveryFee');
      final freeDeliveryThreshold = _readNonNegativeDouble(json, 'freeDeliveryThreshold');
      final currency = json['currency'] as String;
      final enablePriceRevalidation = json['enablePriceRevalidation'] as bool;

      if (taxRate > 1) throw const FormatException('Cart taxRate must not be greater than 1.');
      if (currency.isEmpty) throw const FormatException('Cart currency must be a non-empty string.');

      return CartPricingModel(
        taxRate: taxRate,
        deliveryFee: deliveryFee,
        freeDeliveryThreshold: freeDeliveryThreshold,
        currency: currency.toUpperCase(),
        enablePriceRevalidation: enablePriceRevalidation,
      );
    } on TypeError catch (error) {
      throw FormatException('Cart pricing has an invalid structure.', error);
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'taxRate': taxRate, 'deliveryFee': deliveryFee, 'freeDeliveryThreshold': freeDeliveryThreshold, 'currency': currency, 'enablePriceRevalidation': enablePriceRevalidation};
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key] as num;
    if (!value.isFinite || value < 0) throw FormatException('Cart $key must be a non-negative number.');
    return value.toDouble();
  }
}
