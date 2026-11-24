import '../../domain/entities/purchase.dart';
import '../../../cart/domain/entities/cart_item.dart';

final class PurchaseRequestModel {
  PurchaseRequestModel({required List<PurchaseItemModel> items, required this.currency, required this.finalTotal, required this.enablePriceRevalidation, this.idempotencyKey})
    : items = List<PurchaseItemModel>.unmodifiable(items);

  factory PurchaseRequestModel.fromEntity(PurchaseRequest request) {
    return PurchaseRequestModel(
      items: request.cart.items.map(PurchaseItemModel.fromCartItem).toList(growable: false),
      currency: request.cart.pricing.currency,
      finalTotal: request.cart.total,
      enablePriceRevalidation: request.cart.pricing.enablePriceRevalidation,
      idempotencyKey: request.idempotencyKey,
    );
  }

  final List<PurchaseItemModel> items;
  final String currency;
  final double finalTotal;
  final bool enablePriceRevalidation;
  final String? idempotencyKey;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'items': items.map((item) => item.toJson()).toList(growable: false), 'currency': currency, if (idempotencyKey != null) 'idempotencyKey': idempotencyKey};
  }
}

final class PurchaseItemModel {
  const PurchaseItemModel({required this.productId, required this.quantity, required this.expectedPrice});

  factory PurchaseItemModel.fromCartItem(CartItem item) {
    return PurchaseItemModel(productId: item.product.id, quantity: item.quantity, expectedPrice: item.product.price);
  }

  final String productId;
  final int quantity;
  final double expectedPrice;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'productId': productId, 'qty': quantity, 'expectedPrice': expectedPrice};
  }
}

final class PurchaseResponseModel {
  const PurchaseResponseModel._(this.result);

  factory PurchaseResponseModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    if (status is! String) throw const FormatException('Purchase status must be a string.');

    return switch (status) {
      'success' => PurchaseResponseModel._(PurchaseSuccess(orderId: _readString(json, 'orderId'), finalTotal: _readNonNegativeDouble(json, 'finalTotal'))),
      'price_changed' => PurchaseResponseModel._(PurchaseReview(type: PurchaseReviewType.priceChanged, priceChanges: _readPriceChanges(json, 'changes'), stockIssues: const <StockIssue>[])),
      'out_of_stock' => PurchaseResponseModel._(PurchaseReview(type: PurchaseReviewType.outOfStock, priceChanges: const <PriceChange>[], stockIssues: _readStockIssues(json, 'items'))),
      'review_required' => PurchaseResponseModel._(
        PurchaseReview(type: PurchaseReviewType.reviewRequired, priceChanges: _readPriceChanges(json, 'priceChanges'), stockIssues: _readStockIssues(json, 'oos')),
      ),
      _ => throw FormatException('Unsupported purchase status: $status.'),
    };
  }

  final PurchaseResult result;

  PurchaseResult toEntity() => result;

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Purchase $key must be a non-empty string.');
    }
    return value.trim();
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num || !value.isFinite || value < 0) {
      throw FormatException('Purchase $key must be a non-negative number.');
    }
    return value.toDouble();
  }

  static List<PriceChange> _readPriceChanges(Map<String, dynamic> json, String key) {
    final values = json[key];
    if (values is! List<dynamic> || values.isEmpty) {
      throw FormatException('Purchase $key must be a non-empty list.');
    }
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) throw FormatException('Each purchase $key entry must be an object.');
          return PriceChange(productId: _readString(value, 'productId'), oldPrice: _readNonNegativeDouble(value, 'oldPrice'), newPrice: _readNonNegativeDouble(value, 'newPrice'));
        })
        .toList(growable: false);
  }

  static List<StockIssue> _readStockIssues(Map<String, dynamic> json, String key) {
    final values = json[key];
    if (values is! List<dynamic> || values.isEmpty) {
      throw FormatException('Purchase $key must be a non-empty list.');
    }
    return values
        .map((value) {
          if (value is! Map<String, dynamic>) throw FormatException('Each purchase $key entry must be an object.');
          final available = value['available'];
          if (available is! int || available < 0) throw const FormatException('Purchase available stock must be a non-negative integer.');
          return StockIssue(productId: _readString(value, 'productId'), available: available);
        })
        .toList(growable: false);
  }
}

final class CheckoutFixtureModel {
  CheckoutFixtureModel({required this.orderId, required Map<String, CheckoutProductSnapshotModel> products}) : products = Map<String, CheckoutProductSnapshotModel>.unmodifiable(products);

  factory CheckoutFixtureModel.fromJson(Map<String, dynamic> json) {
    final orderId = json['orderId'];
    final productValues = json['products'];
    if (orderId is! String || orderId.trim().isEmpty) {
      throw const FormatException('Checkout orderId must be a non-empty string.');
    }
    if (productValues is! List<dynamic>) {
      throw const FormatException('Checkout products must be a list.');
    }

    final products = <String, CheckoutProductSnapshotModel>{};
    for (final value in productValues) {
      if (value is! Map<String, dynamic>) throw const FormatException('Each checkout product must be an object.');
      final product = CheckoutProductSnapshotModel.fromJson(value);
      if (products.containsKey(product.productId)) {
        throw FormatException('Duplicate checkout product id: ${product.productId}.');
      }
      products[product.productId] = product;
    }
    return CheckoutFixtureModel(orderId: orderId.trim(), products: products);
  }

  final String orderId;
  final Map<String, CheckoutProductSnapshotModel> products;
}

final class CheckoutProductSnapshotModel {
  const CheckoutProductSnapshotModel({required this.productId, required this.price, required this.stock});

  factory CheckoutProductSnapshotModel.fromJson(Map<String, dynamic> json) {
    final productId = json['productId'];
    final price = json['price'];
    final stock = json['stock'];
    if (productId is! String || productId.trim().isEmpty) {
      throw const FormatException('Checkout productId must be a non-empty string.');
    }
    if (price is! num || !price.isFinite || price < 0) {
      throw const FormatException('Checkout price must be a non-negative number.');
    }
    if (stock is! int || stock < 0) {
      throw const FormatException('Checkout stock must be a non-negative integer.');
    }
    return CheckoutProductSnapshotModel(productId: productId.trim(), price: price.toDouble(), stock: stock);
  }

  final String productId;
  final double price;
  final int stock;
}
