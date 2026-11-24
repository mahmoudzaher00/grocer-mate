part of '../view.dart';

class _CartContent extends StatefulWidget {
  const _CartContent({required this.cart});

  final Cart cart;

  @override
  State<_CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<_CartContent> {
  final _selection = _ItemSelection();

  @override
  void didUpdateWidget(covariant _CartContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.cart.items, oldWidget.cart.items)) {
      _selection.retainItems(widget.cart.items);
    }
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  void _moveSelected() {
    context.read<CartBloc>().add(CartItemsMovedToSaved(_selection.selectedIds));
    _selection.clear();
  }

  Future<void> _startCheckout({required bool offline}) async {
    final cart = await context.read<CartBloc>().cartForCheckout();
    if (!mounted || cart == null || cart.isEmpty || ModalRoute.of(context)?.isCurrent != true) return;
    final outbox = context.read<OutboxBloc>();
    if (outbox.state.hasPendingPurchase || outbox.state.blocksCartMutations) return;
    final connection = context.read<ConnectivityBloc>().state;
    if (offline) {
      if (connection is! ConnectivityOffline) return;
      outbox.add(OutboxPurchaseQueued(cart));
      return;
    }
    if (connection is! ConnectivityOnline) return;

    final outcome = await showCheckoutSheet(context: context, cart: cart);
    if (!mounted || outcome == null) return;

    context.read<CartBloc>().add(CartPurchaseCompleted(outcome.purchasedCart));
    await showOrderConfirmationDialog(
      context: context,
      orderId: outcome.orderId,
      totalLabel: outcome.finalTotal.formatCurrency(currencySymbol: cart.pricing.currencySymbol),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.cart.items;
    return ListView.builder(
      key: const PageStorageKey<String>('cart-scroll-view'),
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      itemCount: items.length + 2,
      itemBuilder: (context, index) {
        final Widget row;
        if (index == 0) {
          final header = _SelectionHeader(
            countLabel: '${widget.cart.itemCount} ${widget.cart.itemCount == 1 ? 'item' : 'items'}',
            selection: _selection,
            onPressed: _moveSelected,
            icon: Icons.bookmark_add_outlined,
            actionLabel: 'Save selected',
          );
          row = Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BlocBuilder<OutboxBloc, OutboxState>(
                  builder: (context, state) => state.hasPendingPurchase
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: _QueuedPurchaseCard(state: state),
                        )
                      : const SizedBox.shrink(),
                ),
                header,
              ],
            ),
          );
        } else if (index == items.length + 1) {
          row = _OrderSummary(cart: widget.cart, onCheckout: _startCheckout);
        } else {
          final item = items[index - 1];
          final id = item.product.id;
          row = Padding(
            padding: EdgeInsets.only(bottom: index == items.length ? 20.h : 12.h),
            child: _CartItemCard(item: item, cart: widget.cart, selectionControl: _selection.checkboxFor(id), onSaveForLater: () => context.read<CartBloc>().add(CartItemsMovedToSaved([id]))),
          );
        }
        return Center(child: SizedBox(width: 760, child: row));
      },
    );
  }
}
