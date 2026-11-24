part of 'bloc.dart';

sealed class OutboxState extends Equatable {
  const OutboxState({this.purchase});

  final QueuedPurchase? purchase;

  bool get hasPendingPurchase => purchase != null;

  bool get blocksCartMutations => this is OutboxQueueing || this is OutboxRecovering || this is OutboxRecoveryFailure;

  @override
  List<Object?> get props => [purchase];
}

final class OutboxEmpty extends OutboxState {
  const OutboxEmpty();
}

final class OutboxQueueing extends OutboxState {
  const OutboxQueueing();
}

final class OutboxQueueFailure extends OutboxState {
  const OutboxQueueFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class OutboxRecovering extends OutboxState {
  const OutboxRecovering(QueuedPurchase? purchase) : super(purchase: purchase);
}

final class OutboxRecoveryFailure extends OutboxState {
  const OutboxRecoveryFailure({this.message = 'The queued purchase could not be recovered safely.', super.purchase});

  final String message;

  @override
  List<Object?> get props => [...super.props, message];
}

final class OutboxQueued extends OutboxState {
  const OutboxQueued(QueuedPurchase purchase) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;
}

final class OutboxReadyForCheckout extends OutboxState {
  const OutboxReadyForCheckout(QueuedPurchase purchase) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;
}

final class OutboxCheckoutActive extends OutboxState {
  const OutboxCheckoutActive(QueuedPurchase purchase) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;
}

final class OutboxDeferred extends OutboxState {
  const OutboxDeferred(QueuedPurchase purchase) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;
}

final class OutboxClearing extends OutboxState {
  const OutboxClearing(QueuedPurchase purchase) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;
}

final class OutboxClearFailure extends OutboxState {
  const OutboxClearFailure({required QueuedPurchase purchase, required this.orderId, required this.finalTotal, required this.currencySymbol, required this.message}) : super(purchase: purchase);

  @override
  QueuedPurchase get purchase => super.purchase!;

  final String orderId;
  final double finalTotal;
  final String currencySymbol;
  final String message;

  @override
  List<Object?> get props => [...super.props, orderId, finalTotal, currencySymbol, message];
}

final class OutboxCompleted extends OutboxState {
  const OutboxCompleted({required this.orderId, required this.finalTotal, required this.currencySymbol});

  final String orderId;
  final double finalTotal;
  final String currencySymbol;

  @override
  List<Object?> get props => [...super.props, orderId, finalTotal, currencySymbol];
}
