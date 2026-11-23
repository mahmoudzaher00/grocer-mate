import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

final class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, Cart>> loadCart() async {
    try {
      final items = await _localDataSource.loadCartItems();
      final pricing = await _localDataSource.loadPricing();
      return Right(Cart(items: items, pricing: pricing));
    } on FormatException {
      return const Left(DataFailure('The saved cart data is invalid.'));
    } on FlutterError {
      return const Left(DataFailure('The cart configuration could not be loaded.'));
    } on PlatformException {
      return const Left(StorageFailure('The saved cart could not be loaded.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCart(List<CartItem> items) async {
    try {
      final models = items.map(CartItemModel.fromEntity).toList(growable: false);
      await _localDataSource.saveCartItems(models);
      return const Right(unit);
    } on FormatException {
      return const Left(DataFailure('The cart data is invalid.'));
    } on PlatformException {
      return const Left(StorageFailure('The cart could not be saved.'));
    } on StateError {
      return const Left(StorageFailure('The cart could not be saved.'));
    }
  }
}
