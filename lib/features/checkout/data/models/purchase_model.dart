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
    try {
      final status = json['status'] as String;
      return switch (status) {
        'success' => PurchaseResponseModel._(PurchaseSuccess(orderId: _readString(json, 'orderId'), finalTotal: _readNonNegativeDouble(json, 'finalTotal'))),
        'price_changed' => PurchaseResponseModel._(PurchaseReview(type: PurchaseReviewType.priceChanged, priceChanges: _readPriceChanges(json, 'changes'), stockIssues: const <StockIssue>[])),
        'out_of_stock' => PurchaseResponseModel._(PurchaseReview(type: PurchaseReviewType.outOfStock, priceChanges: const <PriceChange>[], stockIssues: _readStockIssues(json, 'items'))),
        'review_required' => PurchaseResponseModel._(
          PurchaseReview(type: PurchaseReviewType.reviewRequired, priceChanges: _readPriceChanges(json, 'priceChanges'), stockIssues: _readStockIssues(json, 'oos')),
        ),
        _ => throw FormatException('Unsupported purchase status: $status.'),
      };
    } on TypeError catch (error) {
      throw FormatException('Purchase response has an invalid structure.', error);
    }
  }

  final PurchaseResult result;

  PurchaseResult toEntity() => result;

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key] as String;
    if (value.isEmpty) throw FormatException('Purchase $key must not be empty.');
    return value;
  }

  static double _readNonNegativeDouble(Map<String, dynamic> json, String key) {
    final value = json[key] as num;
    if (!value.isFinite || value < 0) throw FormatException('Purchase $key must be a non-negative number.');
    return value.toDouble();
  }

  static List<PriceChange> _readPriceChanges(Map<String, dynamic> json, String key) {
    final values = json[key] as List<dynamic>;
    if (values.isEmpty) throw FormatException('Purchase $key must not be empty.');
    return values
        .map((value) {
          final entry = value as Map<String, dynamic>;
          return PriceChange(productId: _readString(entry, 'productId'), oldPrice: _readNonNegativeDouble(entry, 'oldPrice'), newPrice: _readNonNegativeDouble(entry, 'newPrice'));
        })
        .toList(growable: false);
  }

  static List<StockIssue> _readStockIssues(Map<String, dynamic> json, String key) {
    final values = json[key] as List<dynamic>;
    if (values.isEmpty) throw FormatException('Purchase $key must not be empty.');
    return values
        .map((value) {
          final entry = value as Map<String, dynamic>;
          final available = entry['available'] as int;
          if (available < 0) throw const FormatException('Purchase available stock must be a non-negative integer.');
          return StockIssue(productId: _readString(entry, 'productId'), available: available);
        })
        .toList(growable: false);
  }
}

final class CheckoutFixtureModel {
  CheckoutFixtureModel({required this.orderId, required Map<String, CheckoutProductSnapshotModel> products}) : products = Map<String, CheckoutProductSnapshotModel>.unmodifiable(products);

  factory CheckoutFixtureModel.fromJson(Map<String, dynamic> json) {
    try {
      final orderId = json['orderId'] as String;
      if (orderId.isEmpty) throw const FormatException('Checkout orderId must not be empty.');

      final products = <String, CheckoutProductSnapshotModel>{};
      for (final value in json['products'] as List<dynamic>) {
        final product = CheckoutProductSnapshotModel.fromJson(value as Map<String, dynamic>);
        if (products.containsKey(product.productId)) throw FormatException('Duplicate checkout product id: ${product.productId}.');
        products[product.productId] = product;
      }
      return CheckoutFixtureModel(orderId: orderId, products: products);
    } on TypeError catch (error) {
      throw FormatException('Checkout fixture has an invalid structure.', error);
    }
  }

  final String orderId;
  final Map<String, CheckoutProductSnapshotModel> products;
}

final class CheckoutProductSnapshotModel {
  const CheckoutProductSnapshotModel({required this.productId, required this.price, required this.stock});

  factory CheckoutProductSnapshotModel.fromJson(Map<String, dynamic> json) {
    try {
      final productId = json['productId'] as String;
      final price = json['price'] as num;
      final stock = json['stock'] as int;
      if (productId.isEmpty) throw const FormatException('Checkout productId must not be empty.');
      if (!price.isFinite || price < 0) throw const FormatException('Checkout price must be a non-negative number.');
      if (stock < 0) throw const FormatException('Checkout stock must be a non-negative integer.');
      return CheckoutProductSnapshotModel(productId: productId, price: price.toDouble(), stock: stock);
    } on TypeError catch (error) {
      throw FormatException('Checkout product has an invalid structure.', error);
    }
  }

  final String productId;
  final double price;
  final int stock;
}
