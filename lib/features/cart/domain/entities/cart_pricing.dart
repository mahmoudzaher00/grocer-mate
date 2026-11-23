import 'package:equatable/equatable.dart';

class CartPricing extends Equatable {
  const CartPricing({required this.taxRate, required this.deliveryFee, required this.freeDeliveryThreshold, required this.currency, required this.enablePriceRevalidation});

  final double taxRate;
  final double deliveryFee;
  final double freeDeliveryThreshold;
  final String currency;
  final bool enablePriceRevalidation;

  String get currencySymbol => currency == 'USD' ? r'$' : currency;

  @override
  List<Object?> get props => [taxRate, deliveryFee, freeDeliveryThreshold, currency, enablePriceRevalidation];
}
