import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/purchase.dart';

abstract interface class CheckoutRepository {
  Future<Either<Failure, PurchaseResult>> submitPurchase(PurchaseRequest request);
}
