import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/queued_purchase.dart';
import '../../domain/repositories/checkout_outbox_repository.dart';
import '../data_sources/checkout_outbox_local_data_source.dart';
import '../models/queued_purchase_model.dart';

final class CheckoutOutboxRepositoryImpl implements CheckoutOutboxRepository {
  const CheckoutOutboxRepositoryImpl(this._localDataSource);

  final CheckoutOutboxLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, QueuedPurchase?>> loadPurchase() async {
    try {
      final model = await _localDataSource.loadPurchase();
      return Right(model?.toEntity());
    } on FormatException {
      return const Left(DataFailure('The saved queued purchase is invalid.'));
    } on StateError {
      return const Left(StorageFailure('The queued purchase could not be loaded.'));
    } on PlatformException {
      return const Left(StorageFailure('The queued purchase could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePurchase(QueuedPurchase purchase) async {
    try {
      await _localDataSource.savePurchase(QueuedPurchaseModel.fromEntity(purchase));
      return const Right(unit);
    } on FormatException {
      return const Left(DataFailure('The queued purchase data is invalid.'));
    } on StateError {
      return const Left(StorageFailure('The queued purchase could not be saved.'));
    } on PlatformException {
      return const Left(StorageFailure('The queued purchase could not be saved.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearPurchase() async {
    try {
      await _localDataSource.clearPurchase();
      return const Right(unit);
    } on StateError {
      return const Left(StorageFailure('The completed queued purchase could not be cleared.'));
    } on PlatformException {
      return const Left(StorageFailure('The completed queued purchase could not be cleared.'));
    }
  }
}
