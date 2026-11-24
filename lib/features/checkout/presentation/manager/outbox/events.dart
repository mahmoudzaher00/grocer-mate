part of 'bloc.dart';

sealed class OutboxEvent extends Equatable {
  const OutboxEvent();

  @override
  List<Object?> get props => [];
}

final class OutboxPurchaseQueued extends OutboxEvent {
  const OutboxPurchaseQueued(this.cart);

  final Cart cart;

  @override
  List<Object?> get props => [cart];
}

final class OutboxRecoveryRetried extends OutboxEvent {
  const OutboxRecoveryRetried();
}

final class OutboxConnectivityChanged extends OutboxEvent {
  const OutboxConnectivityChanged(this.isOnline);

  final bool isOnline;

  @override
  List<Object?> get props => [isOnline];
}

final class OutboxAppActivityChanged extends OutboxEvent {
  const OutboxAppActivityChanged(this.isActive);

  final bool isActive;

  @override
  List<Object?> get props => [isActive];
}

final class OutboxCheckoutOpened extends OutboxEvent {
  const OutboxCheckoutOpened();
}

final class OutboxCheckoutClosed extends OutboxEvent {
  const OutboxCheckoutClosed();
}

final class OutboxManualReviewRequested extends OutboxEvent {
  const OutboxManualReviewRequested();
}

final class OutboxCheckoutSucceeded extends OutboxEvent {
  const OutboxCheckoutSucceeded({required this.orderId, required this.finalTotal, required this.currencySymbol});

  final String orderId;
  final double finalTotal;
  final String currencySymbol;

  @override
  List<Object?> get props => [orderId, finalTotal, currencySymbol];
}

final class OutboxClearRetried extends OutboxEvent {
  const OutboxClearRetried();
}

final class OutboxCompletionAcknowledged extends OutboxEvent {
  const OutboxCompletionAcknowledged();
}
