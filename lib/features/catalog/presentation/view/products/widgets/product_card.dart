part of '../view.dart';

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final stockVisual = _stockVisual(colorScheme);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(imageUrl: product.imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.textTheme.titleMedium),
                      ),
                      if (product.hasDiscount) ...[SizedBox(width: 8.w), _DiscountBadge(percentage: product.discountPercentage)],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.62)),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}', style: context.textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                      if (product.hasDiscount) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '\$${product.originalPrice.toStringAsFixed(2)}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                            decorationColor: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: stockVisual.backgroundColor, borderRadius: BorderRadius.circular(999.r)),
                    child: Text(stockVisual.label, style: context.textTheme.labelSmall?.copyWith(color: stockVisual.foregroundColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StockVisual _stockVisual(ColorScheme colorScheme) {
    if (product.isOutOfStock) {
      return _StockVisual(label: 'Out of stock', backgroundColor: colorScheme.errorContainer, foregroundColor: colorScheme.onErrorContainer);
    }
    if (product.stock <= 5) {
      return _StockVisual(label: 'Only ${product.stock} left', backgroundColor: colorScheme.tertiaryContainer, foregroundColor: colorScheme.onTertiaryContainer);
    }
    return _StockVisual(label: 'In stock', backgroundColor: colorScheme.secondaryContainer, foregroundColor: colorScheme.onSecondaryContainer);
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 104.r,
        height: 112.r,
        fit: BoxFit.cover,
        placeholder: (context, _) => ColoredBox(
          color: colorScheme.surfaceContainer,
          child: Center(
            child: SizedBox.square(dimension: 24.r, child: const CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
        errorWidget: (context, _, _) => ColoredBox(
          color: colorScheme.surfaceContainer,
          child: Center(child: Icon(Icons.image_not_supported_outlined, color: colorScheme.onSurface.withValues(alpha: 0.55))),
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(999.r)),
      child: Text('-$percentage%', style: context.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer)),
    );
  }
}

class _StockVisual {
  const _StockVisual({required this.label, required this.backgroundColor, required this.foregroundColor});

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}
