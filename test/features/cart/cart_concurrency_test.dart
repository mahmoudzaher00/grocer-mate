import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grocer_mate/core/storage/app_preferences.dart';
import 'package:grocer_mate/features/cart/data/data_sources/cart_local_data_source.dart';
import 'package:grocer_mate/features/cart/data/models/cart_item_model.dart';
import 'package:grocer_mate/features/cart/data/models/cart_pricing_model.dart';
import 'package:grocer_mate/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:grocer_mate/features/cart/domain/entities/cart_item.dart';
import 'package:grocer_mate/features/cart/domain/use_cases/detach_queued_cart_items.dart';
import 'package:grocer_mate/features/cart/domain/use_cases/load_cart.dart';
import 'package:grocer_mate/features/cart/domain/use_cases/save_cart.dart';
import 'package:grocer_mate/features/cart/presentation/manager/bloc.dart';
import 'package:grocer_mate/features/catalog/domain/entities/product.dart';
import 'package:grocer_mate/features/checkout/data/data_sources/checkout_outbox_local_data_source.dart';
import 'package:grocer_mate/features/checkout/data/repositories/checkout_outbox_repository_impl.dart';
import 'package:grocer_mate/features/checkout/domain/use_cases/queue_offline_purchase.dart';
import 'package:grocer_mate/features/checkout/domain/use_cases/recover_queued_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final banana = Product(id: 'banana', title: 'Banana', brand: 'Farm', price: 1.79, originalPrice: 1.79, stock: 82, imageUrl: 'image', badges: [], categoryId: 'fruit', rating: 5);

class _PausedCartStorage implements CartLocalDataSource {
  final firstWriteStarted = Completer<void>();
  final releaseFirstWrite = Completer<void>();
  StoredCartData snapshot = (cartItems: [CartItemModel.fromEntity(CartItem(product: banana, quantity: 2))], savedItems: [], lastDetachedPurchaseKey: null);
  @override
  Future<StoredCartData> loadItems() async => snapshot;
  @override
  Future<CartPricingModel> loadPricing() async => const CartPricingModel(taxRate: .05, deliveryFee: 1, freeDeliveryThreshold: 25, currency: 'USD', enablePriceRevalidation: true);
  @override
  Future<void> saveItems({required List<CartItemModel> cartItems, required List<CartItemModel> savedItems, String? lastDetachedPurchaseKey}) async {
    if (!firstWriteStarted.isCompleted) {
      firstWriteStarted.complete();
      await releaseFirstWrite.future;
    }
    snapshot = (cartItems: cartItems, savedItems: savedItems, lastDetachedPurchaseKey: lastDetachedPurchaseKey);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _PausedCartStorage storage;
  late CartRepositoryImpl cartRepository;
  late CartBloc bloc;
  setUp(() async {
    storage = _PausedCartStorage();
    cartRepository = CartRepositoryImpl(storage);
    bloc = CartBloc(LoadCart(cartRepository), SaveCart(cartRepository));
    bloc.add(const CartRequested());
    await bloc.stream.firstWhere((s) => s is CartReady);
  });
  tearDown(() async {
    if (!storage.releaseFirstWrite.isCompleted) {
      storage.releaseFirstWrite.complete();
    }
    await bloc.close();
  });
  Future<CheckoutOutboxRepositoryImpl> createOutbox() async {
    SharedPreferences.setMockInitialValues({});
    return CheckoutOutboxRepositoryImpl(CheckoutOutboxLocalDataSourceImpl(await AppPreferences.create()));
  }

  void changeQuantity(int step) {
    bloc.add(CartQuantityChanged(productId: 'banana', delta: step));
  }

  test('checkout waits for earlier pending edit', () async {
    changeQuantity(1);
    await storage.firstWriteStarted.future;
    final captured = bloc.cartForCheckout();
    storage.releaseFirstWrite.complete();
    expect((await captured)!.itemCount, 3);
  });
  test('two consecutive taps apply twice', () async {
    changeQuantity(1);
    await storage.firstWriteStarted.future;
    changeQuantity(1);
    storage.releaseFirstWrite.complete();
    await bloc.cartForCheckout();
    expect(storage.snapshot.cartItems.single.quantity, 4);
  });
  test('completion preserves unpurchased units', () async {
    final submitted = bloc.state.cart!;
    changeQuantity(1);
    await storage.firstWriteStarted.future;
    bloc.add(CartPurchaseCompleted(submitted));
    storage.releaseFirstWrite.complete();
    await bloc.cartForCheckout();
    expect(storage.snapshot.cartItems.map((i) => i.quantity), [1]);
  });
  test('pending decrease cannot leave an impossible queue', () async {
    final outbox = await createOutbox();
    final detach = DetachQueuedCartItems(cartRepository);
    changeQuantity(-1);
    await storage.firstWriteStarted.future;
    final stale = bloc.state.cart!;
    final queue = QueueOfflinePurchase(outbox, detach)(stale);
    storage.releaseFirstWrite.complete();
    expect((await queue).isLeft(), isTrue);
    final recovered = await RecoverQueuedPurchase(outbox, detach)();
    expect(recovered.fold((failure) => fail(failure.errMessage), (purchase) => purchase), isNull);
  });
  test('offline checkout waits for the edit and persists the matching quantity', () async {
    final outbox = await createOutbox();
    final detach = DetachQueuedCartItems(cartRepository);
    changeQuantity(-1);
    await storage.firstWriteStarted.future;
    final pending = bloc.cartForCheckout();
    storage.releaseFirstWrite.complete();
    final result = await QueueOfflinePurchase(outbox, detach)((await pending)!);
    expect(result.fold((failure) => fail(failure.errMessage), (purchase) => purchase.cart.itemCount), 1);
    expect(storage.snapshot.cartItems, isEmpty);
    final recovered = await RecoverQueuedPurchase(outbox, detach)();
    expect(recovered.fold((failure) => fail(failure.errMessage), (purchase) => purchase?.cart.itemCount), 1);
  });
  test('two consecutive decreases stop at the minimum', () async {
    changeQuantity(-1);
    await storage.firstWriteStarted.future;
    changeQuantity(-1);
    storage.releaseFirstWrite.complete();
    await bloc.cartForCheckout();
    expect(storage.snapshot.cartItems.single.quantity, 1);
  });
}
