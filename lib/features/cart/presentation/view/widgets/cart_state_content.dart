part of '../view.dart';

class _CartRecoveryLoading extends StatelessWidget {
  const _CartRecoveryLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(color: context.colorScheme.primary, size: 48.r),
            SizedBox(height: 16.h),
            Text('Securing your queued purchase...', textAlign: TextAlign.center, style: context.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _ShoppingListsContent extends StatelessWidget {
  const _ShoppingListsContent({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final outboxState = context.watch<OutboxBloc>().state;

    return TabBarView(
      children: [
        cart.isEmpty ? _EmptyCartContent(outboxState: outboxState, canPop: canPop) : _CartContent(cart: cart),
        cart.savedItems.isEmpty
            ? const EmptyStateWidget(icon: Icons.bookmark_outline_rounded, title: 'Nothing saved yet', message: 'Move Cart items here to keep them for later.')
            : _SavedContent(cart: cart),
      ],
    );
  }
}

class _EmptyCartContent extends StatelessWidget {
  const _EmptyCartContent({required this.outboxState, required this.canPop});

  final OutboxState outboxState;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 24.h),
      children: [
        if (outboxState.hasPendingPurchase) ...[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: _QueuedPurchaseCard(state: outboxState),
            ),
          ),
          SizedBox(height: 28.h),
        ],
        SizedBox(
          height: 320.h,
          child: EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'Your cart is empty',
            message: outboxState.hasPendingPurchase ? 'Your queued purchase is stored separately. You can keep shopping.' : 'Add products or move Saved items back to Cart.',
            actionLabel: canPop ? 'Continue shopping' : null,
            onAction: canPop ? () => Navigator.of(context).pop() : null,
          ),
        ),
      ],
    );
  }
}
