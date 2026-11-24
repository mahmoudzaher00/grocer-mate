part of '../view.dart';

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline),
        boxShadow: AppShadows.cardShadow(colorScheme.shadow),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(product: product),
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
                          if (product.hasDiscount) ...[SizedBox(width: 8.w), ProductDiscountBadge(percentage: product.discountPercentage)],
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
                      ProductPrice(product: product),
                      SizedBox(height: 10.h),
                      ProductStockBadge(product: product),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return ProductImageHero(
      productId: product.id,
      child: NetworkImageWidget(image: product.imageUrl, width: 104.r, height: 112.r, radius: 12.r, fit: BoxFit.cover, bgColor: colorScheme.surfaceContainer),
    );
  }
}
