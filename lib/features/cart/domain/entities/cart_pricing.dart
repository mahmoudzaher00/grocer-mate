import 'package:equatable/equatable.dart';

class CartPricing extends Equatable {
  const CartPricing({required this.taxRate, required this.deliveryFee, required this.freeDeliveryThreshold, required this.currency});

  final double taxRate;
  final double deliveryFee;
  final double freeDeliveryThreshold;
  final String currency;

  String get currencySymbol => currency == 'USD' ? r'$' : currency;

  @override
  List<Object?> get props => [taxRate, deliveryFee, freeDeliveryThreshold, currency];
}
