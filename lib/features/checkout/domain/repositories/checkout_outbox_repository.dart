import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/queued_purchase.dart';

abstract interface class CheckoutOutboxRepository {
  Future<Either<Failure, QueuedPurchase?>> loadPurchase();

  Future<Either<Failure, Unit>> savePurchase(QueuedPurchase purchase);

  Future<Either<Failure, Unit>> clearPurchase();
}
