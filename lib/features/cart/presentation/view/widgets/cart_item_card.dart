part of '../view.dart';

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.cart, required this.isSelected, required this.onSelectionChanged, required this.onSaveForLater});

  final CartItem item;
  final Cart cart;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onSaveForLater;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final product = item.product;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWidget(
              image: product.imageUrl,
              width: 88.r,
              height: 104.r,
              radius: 14.r,
              fit: BoxFit.cover,
              bgColor: colorScheme.surfaceContainer,
              onTap: () => Navigator.of(context).pushNamed(productDetailsRoute, arguments: product),
              semanticLabel: 'View ${product.title} details',
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(value: isSelected, onChanged: (value) => onSelectionChanged(value ?? false), visualDensity: VisualDensity.compact),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(productDetailsRoute, arguments: product),
                          child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.titleMedium),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove ${product.title}',
                        onPressed: () => context.read<CartBloc>().add(CartItemRemoved(product.id)),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error, size: 22.r),
                      ),
                    ],
                  ),
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.62)),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.lineSubtotal.formatCurrency(currencySymbol: cart.pricing.currencySymbol),
                          style: context.textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                        ),
                      ),
                      QuantityStepper(
                        compact: true,
                        quantity: item.quantity,
                        maximum: product.stock,
                        onChanged: (quantity) => context.read<CartBloc>().add(CartQuantityChanged(productId: product.id, quantity: quantity)),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(onPressed: onSaveForLater, icon: const Icon(Icons.bookmark_add_outlined), label: const Text('Save for later')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
