import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart.dart';

class PurchaseRequest extends Equatable {
  const PurchaseRequest(this.cart);

  final Cart cart;

  PurchaseRequest copyWith({Cart? cart}) {
    return PurchaseRequest(cart ?? this.cart);
  }

  @override
  List<Object?> get props => [cart];
}

sealed class PurchaseResult extends Equatable {
  const PurchaseResult();
}

final class PurchaseSuccess extends PurchaseResult {
  const PurchaseSuccess({required this.orderId, required this.finalTotal});

  final String orderId;
  final double finalTotal;

  @override
  List<Object?> get props => [orderId, finalTotal];
}

enum PurchaseReviewType { priceChanged, outOfStock, reviewRequired }

final class PurchaseReview extends PurchaseResult {
  PurchaseReview({required this.type, required List<PriceChange> priceChanges, required List<StockIssue> stockIssues})
    : priceChanges = List<PriceChange>.unmodifiable(priceChanges),
      stockIssues = List<StockIssue>.unmodifiable(stockIssues);

  final PurchaseReviewType type;
  final List<PriceChange> priceChanges;
  final List<StockIssue> stockIssues;

  bool get isResolved => priceChanges.isEmpty && stockIssues.isEmpty;

  PriceChange? priceChangeFor(String productId) {
    for (final change in priceChanges) {
      if (change.productId == productId) return change;
    }
    return null;
  }

  StockIssue? stockIssueFor(String productId) {
    for (final issue in stockIssues) {
      if (issue.productId == productId) return issue;
    }
    return null;
  }

  PurchaseReview copyWith({List<PriceChange>? priceChanges, List<StockIssue>? stockIssues}) {
    return PurchaseReview(type: type, priceChanges: priceChanges ?? this.priceChanges, stockIssues: stockIssues ?? this.stockIssues);
  }

  @override
  List<Object?> get props => [type, priceChanges, stockIssues];
}

final class PriceChange extends Equatable {
  const PriceChange({required this.productId, required this.oldPrice, required this.newPrice});

  final String productId;
  final double oldPrice;
  final double newPrice;

  @override
  List<Object?> get props => [productId, oldPrice, newPrice];
}

final class StockIssue extends Equatable {
  const StockIssue({required this.productId, required this.available});

  final String productId;
  final int available;

  @override
  List<Object?> get props => [productId, available];
}
