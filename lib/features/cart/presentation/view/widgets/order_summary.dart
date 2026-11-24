part of '../view.dart';

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart, required this.onCheckout});

  final Cart cart;
  final Future<void> Function({required bool offline}) onCheckout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final freeDeliveryRemaining = cart.pricing.freeDeliveryThreshold - cart.subtotal;
    final currencySymbol = cart.pricing.currencySymbol;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order summary', style: context.textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 18.h),
            _SummaryRow(
              label: 'Subtotal',
              value: cart.subtotal.formatCurrency(currencySymbol: currencySymbol),
            ),
            if (cart.discount > 0) ...[
              SizedBox(height: 10.h),
              _SummaryRow(
                label: 'Discount savings',
                value: 'Saved ${cart.discount.formatCurrency(currencySymbol: currencySymbol)}',
                valueColor: colorScheme.secondary,
              ),
            ],
            SizedBox(height: 10.h),
            _SummaryRow(
              label: 'Tax (${(cart.pricing.taxRate * 100).toStringAsFixed(0)}%)',
              value: cart.tax.formatCurrency(currencySymbol: currencySymbol),
            ),
            SizedBox(height: 10.h),
            _SummaryRow(
              label: 'Delivery',
              value: cart.deliveryFee == 0 ? 'Free' : cart.deliveryFee.formatCurrency(currencySymbol: currencySymbol),
              valueColor: cart.deliveryFee == 0 ? colorScheme.secondary : null,
            ),
            if (freeDeliveryRemaining > 0) ...[
              SizedBox(height: 14.h),
              Text(
                'Add ${freeDeliveryRemaining.formatCurrency(currencySymbol: currencySymbol)} more for free delivery.',
                style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.65)),
              ),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Divider(height: 1, color: colorScheme.outlineVariant),
            ),
            _SummaryRow(
              label: 'Total',
              value: cart.total.formatCurrency(currencySymbol: currencySymbol),
              emphasize: true,
            ),
            SizedBox(height: 20.h),
            BlocBuilder<OutboxBloc, OutboxState>(
              builder: (context, outboxState) => BlocBuilder<ConnectivityBloc, ConnectivityState>(
                buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
                builder: (context, connectivityState) {
                  final isOnline = connectivityState is ConnectivityOnline;
                  final isOffline = connectivityState is ConnectivityOffline;
                  final hasPendingPurchase = outboxState.hasPendingPurchase;
                  final buttonLabel = hasPendingPurchase
                      ? 'Complete queued purchase first'
                      : isOnline
                      ? 'Place order'
                      : isOffline
                      ? 'Buy offline'
                      : 'Checking connection';
                  final onPressed = !hasPendingPurchase && (isOnline || isOffline) ? () => onCheckout(offline: isOffline) : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(onPressed: onPressed, icon: Icon(isOnline ? Icons.shopping_cart_checkout_rounded : Icons.schedule_send_rounded), label: Text(buttonLabel)),
                      if (isOffline && !hasPendingPurchase) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Your purchase will be stored securely and revalidated when you reconnect.',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.valueColor, this.emphasize = false});

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize ? context.textTheme.titleLarge?.copyWith(fontSize: 20.sp) : context.textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        SizedBox(width: 16.w),
        Text(value, style: style?.copyWith(color: valueColor ?? (emphasize ? context.theme.colorScheme.primary : null))),
      ],
    );
  }
}
