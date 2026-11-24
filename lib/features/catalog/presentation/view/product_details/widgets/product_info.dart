part of '../view.dart';

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.productDetails});

  final ProductDetails productDetails;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final product = productDetails.product;

    return _ProductDetailsSection(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 16.w, 24.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProductSummary(product: product),
                SizedBox(height: 20.h),
                _DetailsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined, size: 22.r, color: colorScheme.primary),
                          SizedBox(width: 10.w),
                          Text('Description', style: context.textTheme.titleLarge),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(productDetails.description, style: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.72), height: 1.5)),
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

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.headlineLarge?.copyWith(fontSize: 28.sp, height: 1.15),
        ),
        SizedBox(height: 6.h),
        Text(
          product.brand,
          style: context.textTheme.titleLarge?.copyWith(color: colorScheme.primary, fontSize: 17.sp),
        ),
        SizedBox(height: 26.h),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16.w,
          runSpacing: 12.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ProductRating(rating: product.rating),
                SizedBox(
                  height: 32.h,
                  child: VerticalDivider(width: 1, thickness: 1, color: colorScheme.outlineVariant),
                ),
                ProductPrice(
                  product: product,
                  currentPriceStyle: context.textTheme.headlineLarge?.copyWith(color: colorScheme.primary, fontSize: 30.sp),
                  originalPriceStyle: context.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, decoration: TextDecoration.lineThrough, decorationColor: colorScheme.onSurfaceVariant),
                ),
                if (product.hasDiscount) ProductDiscountBadge(percentage: product.discountPercentage),
              ],
            ),
            ProductStockBadge.detailed(product: product),
          ],
        ),
        SizedBox(height: 24.h),
        Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
      ],
    );
  }
}

class _ProductRating extends StatelessWidget {
  const _ProductRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 26.r, color: context.theme.colorScheme.tertiary),
        SizedBox(width: 6.w),
        Text(rating.toStringAsFixed(1), style: context.textTheme.titleLarge?.copyWith(fontSize: 18.sp)),
      ],
    );
  }
}
