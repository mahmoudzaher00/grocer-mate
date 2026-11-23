part of '../view.dart';

class _ReviewContent extends StatelessWidget {
  const _ReviewContent({required this.state});

  final CheckoutReviewRequired state;

  @override
  Widget build(BuildContext context) {
    final request = state.request;
    final cart = request.cart;
    final colorScheme = context.theme.colorScheme;
    final affectedItems = cart.items.where((item) => state.review.priceChangeFor(item.product.id) != null || state.review.stockIssueFor(item.product.id) != null).toList(growable: false);

    return ListView(
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 20.h, 20.w, 24.h),
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(color: colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(18.r)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(state.review.isResolved ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded, color: colorScheme.onTertiaryContainer),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  state.review.isResolved ? 'All changes are resolved. Review the updated total, then submit again.' : 'Prices or availability changed. Resolve every item before submitting again.',
                  style: context.textTheme.bodyMedium?.copyWith(color: colorScheme.onTertiaryContainer),
                ),
              ),
            ],
          ),
        ),
        if (cart.isEmpty) ...[
          SizedBox(height: 24.h),
          Text('No items remain in this checkout.', textAlign: TextAlign.center, style: context.textTheme.titleMedium),
          SizedBox(height: 8.h),
          Text('Close checkout to keep your current Cart and Saved items unchanged.', textAlign: TextAlign.center, style: context.textTheme.bodyMedium),
        ] else ...[
          for (final item in affectedItems) ...[
            SizedBox(height: 16.h),
            _ReviewItemCard(
              item: item,
              currencySymbol: cart.pricing.currencySymbol,
              priceChange: state.review.priceChangeFor(item.product.id),
              stockIssue: state.review.stockIssueFor(item.product.id),
              onAcceptPrice: () => context.read<CheckoutBloc>().add(CheckoutPriceAccepted(item.product.id)),
              onAdjustQuantity: (quantity) => context.read<CheckoutBloc>().add(CheckoutQuantityAdjusted(productId: item.product.id, quantity: quantity)),
              onRemove: () => context.read<CheckoutBloc>().add(CheckoutItemRemoved(item.product.id)),
            ),
          ],
          SizedBox(height: 20.h),
          _CheckoutTotals(cart: cart),
          SizedBox(height: 20.h),
          FilledButton.icon(
            onPressed: state.canResubmit ? () => context.read<CheckoutBloc>().add(const CheckoutResubmitted()) : null,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Submit order again'),
          ),
          if (!state.review.isResolved) ...[
            SizedBox(height: 10.h),
            Text(
              'Resolve every change to continue.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ],
    );
  }
}

class _CheckoutTotals extends StatelessWidget {
  const _CheckoutTotals({required this.cart});

  final Cart cart;

  String _money(double amount) => '${cart.pricing.currencySymbol}${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(18.r)),
      child: Column(
        children: [
          _CheckoutTotalRow(label: 'Subtotal', value: _money(cart.subtotal)),
          SizedBox(height: 8.h),
          _CheckoutTotalRow(label: 'Tax', value: _money(cart.tax)),
          SizedBox(height: 8.h),
          _CheckoutTotalRow(label: 'Delivery', value: cart.deliveryFee == 0 ? 'Free' : _money(cart.deliveryFee)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(height: 1, color: colorScheme.outlineVariant),
          ),
          _CheckoutTotalRow(label: 'Updated total', value: _money(cart.total), emphasize: true),
        ],
      ),
    );
  }
}

class _CheckoutTotalRow extends StatelessWidget {
  const _CheckoutTotalRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize ? context.textTheme.titleMedium?.copyWith(color: context.theme.colorScheme.primary, fontWeight: FontWeight.bold) : context.textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
