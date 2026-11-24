import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../cart/domain/entities/cart.dart';
import '../../../domain/entities/purchase.dart';
import '../../../domain/entities/queued_purchase.dart';
import '../../../domain/use_cases/clear_queued_purchase.dart';
import '../../../domain/use_cases/queue_offline_purchase.dart';
import '../../../domain/use_cases/recover_queued_purchase.dart';

part 'events.dart';
part 'states.dart';

class OutboxBloc extends Bloc<OutboxEvent, OutboxState> {
  OutboxBloc(this._queueOfflinePurchase, this._recoverQueuedPurchase, this._clearQueuedPurchase, Either<Failure, QueuedPurchase?> bootstrapResult) : super(_stateFromBootstrap(bootstrapResult)) {
    on<OutboxEvent>(_onEvent, transformer: _sequential());
  }

  final QueueOfflinePurchase _queueOfflinePurchase;
  final RecoverQueuedPurchase _recoverQueuedPurchase;
  final ClearQueuedPurchase _clearQueuedPurchase;

  bool _isOnline = false;
  bool _isAppActive = false;
  bool _attemptedThisOnlineSession = false;

  static OutboxState _stateFromBootstrap(Either<Failure, QueuedPurchase?> result) {
    return result.fold((failure) => OutboxRecoveryFailure(message: failure.errMessage), (purchase) => purchase == null ? const OutboxEmpty() : OutboxQueued(purchase));
  }

  EventTransformer<E> _sequential<E>() {
    return (events, mapper) => events.asyncExpand(mapper);
  }

  Future<void> _onEvent(OutboxEvent event, Emitter<OutboxState> emit) async {
    switch (event) {
      case OutboxPurchaseQueued():
        await _onPurchaseQueued(event, emit);
        return;
      case OutboxRecoveryRetried():
        await _onRecoveryRetried(emit);
        return;
      case OutboxConnectivityChanged():
        _onConnectivityChanged(event, emit);
        return;
      case OutboxAppActivityChanged():
        _onAppActivityChanged(event, emit);
        return;
      case OutboxCheckoutOpened():
        _onCheckoutOpened(emit);
        return;
      case OutboxCheckoutClosed():
        _onCheckoutClosed(event, emit);
        return;
      case OutboxManualReviewRequested():
        _onManualReviewRequested(emit);
        return;
      case OutboxCheckoutSucceeded():
        await _onCheckoutSucceeded(event, emit);
        return;
      case OutboxClearRetried():
        await _onClearRetried(emit);
        return;
      case OutboxQueuedPurchaseDiscarded():
        await _onQueuedPurchaseDiscarded(event, emit);
        return;
      case OutboxCompletionAcknowledged():
        if (state is OutboxCompleted) emit(const OutboxEmpty());
        return;
    }
  }

  Future<void> _onPurchaseQueued(OutboxPurchaseQueued event, Emitter<OutboxState> emit) async {
    if (state is! OutboxEmpty && state is! OutboxQueueFailure) return;

    emit(const OutboxQueueing());
    final result = await _queueOfflinePurchase(event.cart);
    await result.fold((failure) => _recoverAfterQueueFailure(failure, emit), (purchase) async {
      _attemptedThisOnlineSession = false;
      _emitQueuedOrReady(purchase, emit);
    });
  }

  Future<void> _recoverAfterQueueFailure(Failure failure, Emitter<OutboxState> emit) async {
    final recoveryResult = await _recoverQueuedPurchase();
    recoveryResult.fold((_) => emit(OutboxRecoveryFailure(message: failure.errMessage)), (purchase) {
      if (purchase == null) {
        emit(OutboxQueueFailure(failure.errMessage));
        return;
      }
      _attemptedThisOnlineSession = false;
      _emitQueuedOrReady(purchase, emit);
    });
  }

  Future<void> _onRecoveryRetried(Emitter<OutboxState> emit) async {
    if (state is! OutboxRecoveryFailure) return;

    final previousPurchase = state.purchase;
    emit(OutboxRecovering(previousPurchase));
    final result = await _recoverQueuedPurchase();
    result.fold((failure) => emit(OutboxRecoveryFailure(purchase: previousPurchase, message: failure.errMessage)), (purchase) {
      if (purchase == null) {
        emit(const OutboxEmpty());
        return;
      }
      _attemptedThisOnlineSession = false;
      _emitQueuedOrReady(purchase, emit);
    });
  }

  void _onConnectivityChanged(OutboxConnectivityChanged event, Emitter<OutboxState> emit) {
    _isOnline = event.isOnline;
    if (!_isOnline) {
      _attemptedThisOnlineSession = false;
      if (state case OutboxReadyForCheckout(:final purchase) || OutboxDeferred(:final purchase)) {
        emit(OutboxQueued(purchase));
      }
      return;
    }
    _emitReadyIfEligible(emit);
  }

  void _onAppActivityChanged(OutboxAppActivityChanged event, Emitter<OutboxState> emit) {
    _isAppActive = event.isActive;
    if (_isAppActive) _emitReadyIfEligible(emit);
  }

  void _emitReadyIfEligible(Emitter<OutboxState> emit) {
    final purchase = state.purchase;
    if (!_isOnline || !_isAppActive || _attemptedThisOnlineSession || purchase == null) return;
    if (state is OutboxQueued) emit(OutboxReadyForCheckout(purchase));
  }

  void _emitQueuedOrReady(QueuedPurchase purchase, Emitter<OutboxState> emit) {
    if (_isOnline && _isAppActive && !_attemptedThisOnlineSession) {
      emit(OutboxReadyForCheckout(purchase));
    } else {
      emit(OutboxQueued(purchase));
    }
  }

  void _onCheckoutOpened(Emitter<OutboxState> emit) {
    if (state case OutboxReadyForCheckout(:final purchase)) {
      _attemptedThisOnlineSession = true;
      emit(OutboxCheckoutActive(purchase));
    }
  }

  void _onCheckoutClosed(OutboxCheckoutClosed event, Emitter<OutboxState> emit) {
    if (state case OutboxCheckoutActive(:final purchase) when event.purchaseKey == null || event.purchaseKey == purchase.idempotencyKey) emit(OutboxDeferred(purchase));
  }

  void _onManualReviewRequested(Emitter<OutboxState> emit) {
    final purchase = state.purchase;
    if (purchase == null || !_isOnline || !_isAppActive) return;
    if (state is OutboxQueued || state is OutboxDeferred) emit(OutboxReadyForCheckout(purchase));
  }

  Future<void> _onCheckoutSucceeded(OutboxCheckoutSucceeded event, Emitter<OutboxState> emit) async {
    final purchase = state.purchase;
    if (purchase == null || state is! OutboxCheckoutActive) return;

    emit(OutboxClearing(purchase));
    final result = await _clearQueuedPurchase();
    result.fold(
      (failure) => emit(OutboxClearFailure(purchase: purchase, orderId: event.orderId, finalTotal: event.finalTotal, currencySymbol: event.currencySymbol, message: failure.errMessage)),
      (_) => emit(OutboxCompleted(orderId: event.orderId, finalTotal: event.finalTotal, currencySymbol: event.currencySymbol)),
    );
  }

  Future<void> _onClearRetried(Emitter<OutboxState> emit) async {
    final currentState = state;
    if (currentState is! OutboxClearFailure) return;

    emit(OutboxClearing(currentState.purchase));
    final result = await _clearQueuedPurchase();
    result.fold(
      (failure) => emit(
        OutboxClearFailure(
          purchase: currentState.purchase,
          orderId: currentState.orderId,
          finalTotal: currentState.finalTotal,
          currencySymbol: currentState.currencySymbol,
          message: failure.errMessage,
        ),
      ),
      (_) => emit(OutboxCompleted(orderId: currentState.orderId, finalTotal: currentState.finalTotal, currencySymbol: currentState.currencySymbol)),
    );
  }

  Future<void> _onQueuedPurchaseDiscarded(OutboxQueuedPurchaseDiscarded event, Emitter<OutboxState> emit) async {
    final currentState = state;
    final review = event.reviewedRequest;
    if (currentState is! OutboxCheckoutActive || review.idempotencyKey != currentState.purchase.idempotencyKey || !review.cart.isEmpty) return;

    emit(OutboxClearing(currentState.purchase));
    final result = await _clearQueuedPurchase();
    result.fold((_) => emit(OutboxCheckoutActive(currentState.purchase, discardFailed: true)), (_) => emit(const OutboxEmpty()));
  }
}
