part of '../view.dart';

class _ReviewItemCard extends StatelessWidget {
  const _ReviewItemCard({
    required this.item,
    required this.currencySymbol,
    required this.priceChange,
    required this.stockIssue,
    required this.onAcceptPrice,
    required this.onAdjustQuantity,
    required this.onRemove,
  });

  final CartItem item;
  final String currencySymbol;
  final PriceChange? priceChange;
  final StockIssue? stockIssue;
  final VoidCallback onAcceptPrice;
  final ValueChanged<int> onAdjustQuantity;
  final VoidCallback onRemove;

  String _money(double amount) => '$currencySymbol${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: ShadowManager.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.product.title, style: context.textTheme.titleMedium),
            SizedBox(height: 4.h),
            Text('Requested quantity: ${item.quantity}', style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            if (priceChange case final change?) ...[
              SizedBox(height: 16.h),
              const _IssueHeader(icon: Icons.price_change_outlined, label: 'Price changed'),
              SizedBox(height: 8.h),
              Text('${_money(change.oldPrice)}  →  ${_money(change.newPrice)}', style: context.textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
              SizedBox(height: 10.h),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(onPressed: onAcceptPrice, child: Text('Accept ${_money(change.newPrice)}')),
              ),
            ],
            if (stockIssue case final issue?) ...[
              SizedBox(height: 16.h),
              _IssueHeader(icon: Icons.inventory_2_outlined, label: issue.available == 0 ? 'Out of stock' : 'Stock reduced'),
              SizedBox(height: 8.h),
              Text(
                issue.available == 0 ? 'This item is currently unavailable.' : 'Only ${issue.available} ${issue.available == 1 ? 'unit is' : 'units are'} available.',
                style: context.textTheme.bodyMedium,
              ),
              if (issue.available > 0) ...[
                SizedBox(height: 10.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.tonal(onPressed: () => onAdjustQuantity(issue.available), child: Text('Reduce to ${issue.available}')),
                ),
              ],
            ],
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(onPressed: onRemove, icon: const Icon(Icons.remove_shopping_cart_outlined), label: const Text('Remove item')),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueHeader extends StatelessWidget {
  const _IssueHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = context.theme.colorScheme.tertiary;
    return Row(
      children: [
        Icon(icon, size: 20.r, color: color),
        SizedBox(width: 8.w),
        Text(label, style: context.textTheme.labelLarge?.copyWith(color: color)),
      ],
    );
  }
}
