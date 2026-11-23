import '../../domain/entities/cart_pricing.dart';

final class CartPricingModel extends CartPricing {
  const CartPricingModel({required super.taxRate, required super.deliveryFee, required super.freeDeliveryThreshold, required super.currency});

  factory CartPricingModel.fromJson(Map<String, dynamic> json) {
    final taxRate = _readNonNegativeDouble(json, 'taxRate');
    final deliveryFee = _readNonNegativeDouble(json, 'deliveryFee');
    final freeDeliveryThreshold = _readNonNegativeDouble(json, 'freeDeliveryThreshold');
    final currency = json['currency'];

    if (taxRate > 1) {
      throw const FormatException('Cart taxRate must not be greater than 1.');
    }
    if (currency is! String || currency.trim().isEmpty) {
      throw const FormatException('Cart currency must be a non-empty string.');
    }

    return CartPricingModel(taxRate: taxRate, deliveryFee: deliveryFee, freeDeliveryThreshold: freeDeliveryThreshold, currency: currency.trim().toUpperCase());
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException('Cart $key must be a non-negative number.');
    }
    return value.toDouble();
  }
}
