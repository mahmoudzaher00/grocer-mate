import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../data_sources/checkout_local_data_source.dart';
import '../models/purchase_model.dart';

final class CheckoutRepositoryImpl implements CheckoutRepository {
  const CheckoutRepositoryImpl(this._localDataSource);

  final CheckoutLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, PurchaseResult>> submitPurchase(PurchaseRequest request) async {
    try {
      final requestModel = PurchaseRequestModel.fromEntity(request);
      final response = await _localDataSource.submitPurchase(requestModel);
      return Right(response.toEntity());
    } on FormatException {
      return const Left(DataFailure('The checkout data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The checkout data could not be loaded.'));
    } on PlatformException {
      return const Left(DataFailure('The checkout data could not be loaded.'));
    } on StateError {
      return const Left(StorageFailure('The checkout result could not be saved safely.'));
    }
  }
}
