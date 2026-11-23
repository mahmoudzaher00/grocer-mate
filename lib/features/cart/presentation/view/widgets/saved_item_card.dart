part of '../view.dart';

class _SavedItemCard extends StatelessWidget {
  const _SavedItemCard({required this.item, required this.cart, required this.isSelected, required this.onSelectionChanged, required this.onMoveToCart});

  final CartItem item;
  final Cart cart;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onMoveToCart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final product = item.product;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: ShadowManager.cardShadow(colorScheme.shadow),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NetworkImageWidget(image: product.imageUrl, width: 88.r, height: 104.r, radius: 14.r, fit: BoxFit.cover, bgColor: colorScheme.surfaceContainer),
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
                        child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.titleMedium),
                      ),
                    ],
                  ),
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.62)),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.lineSubtotal.formatCurrency(currencySymbol: cart.pricing.currencySymbol),
                          style: context.textTheme.titleLarge?.copyWith(color: colorScheme.primary),
                        ),
                      ),
                      Text('Qty ${item.quantity}', style: context.textTheme.labelLarge),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(onPressed: onMoveToCart, icon: const Icon(Icons.shopping_cart_checkout_rounded), label: const Text('Move to Cart')),
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
