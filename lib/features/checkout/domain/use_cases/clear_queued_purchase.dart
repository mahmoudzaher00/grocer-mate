import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/checkout_outbox_repository.dart';

class ClearQueuedPurchase {
  const ClearQueuedPurchase(this._repository);

  final CheckoutOutboxRepository _repository;

  Future<Either<Failure, Unit>> call() => _repository.clearPurchase();
}
