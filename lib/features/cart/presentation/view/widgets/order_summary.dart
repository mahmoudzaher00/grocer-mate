part of '../view.dart';

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final freeDeliveryRemaining = cart.pricing.freeDeliveryThreshold - cart.subtotal;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: ShadowManager.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Order summary', style: context.textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
            SizedBox(height: 18.h),
            _SummaryRow(label: 'Subtotal', value: _formatMoney(cart, cart.subtotal)),
            if (cart.discount > 0) ...[SizedBox(height: 10.h), _SummaryRow(label: 'Discount savings', value: 'Saved ${_formatMoney(cart, cart.discount)}', valueColor: colorScheme.secondary)],
            SizedBox(height: 10.h),
            _SummaryRow(label: 'Tax (${(cart.pricing.taxRate * 100).toStringAsFixed(0)}%)', value: _formatMoney(cart, cart.tax)),
            SizedBox(height: 10.h),
            _SummaryRow(label: 'Delivery', value: cart.deliveryFee == 0 ? 'Free' : _formatMoney(cart, cart.deliveryFee), valueColor: cart.deliveryFee == 0 ? colorScheme.secondary : null),
            if (freeDeliveryRemaining > 0) ...[
              SizedBox(height: 14.h),
              Text('Add ${_formatMoney(cart, freeDeliveryRemaining)} more for free delivery.', style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.65))),
            ],
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Divider(height: 1, color: colorScheme.outlineVariant),
            ),
            _SummaryRow(label: 'Total', value: _formatMoney(cart, cart.total), emphasize: true),
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
