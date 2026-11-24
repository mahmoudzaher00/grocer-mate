import 'package:equatable/equatable.dart';

import '../../../cart/domain/entities/cart.dart';

enum QueuedPurchasePhase { detachingCart, queued }

class QueuedPurchase extends Equatable {
  const QueuedPurchase({required this.idempotencyKey, required this.cart, required this.createdAt, required this.phase});

  final String idempotencyKey;
  final Cart cart;
  final DateTime createdAt;
  final QueuedPurchasePhase phase;

  int get itemCount => cart.itemCount;

  QueuedPurchase copyWith({QueuedPurchasePhase? phase}) {
    return QueuedPurchase(idempotencyKey: idempotencyKey, cart: cart, createdAt: createdAt, phase: phase ?? this.phase);
  }

  @override
  List<Object?> get props => [idempotencyKey, cart, createdAt, phase];
}
