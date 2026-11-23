import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/purchase.dart';
import '../repositories/checkout_repository.dart';

class SubmitPurchase {
  const SubmitPurchase(this._repository);

  final CheckoutRepository _repository;

  Future<Either<Failure, PurchaseResult>> call(PurchaseRequest request) {
    return _repository.submitPurchase(request);
  }
}
