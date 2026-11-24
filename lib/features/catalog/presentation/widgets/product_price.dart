import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/product.dart';

class ProductPrice extends StatelessWidget {
  const ProductPrice({required this.product, this.currentPriceStyle, this.originalPriceStyle, super.key});

  final Product product;
  final TextStyle? currentPriceStyle;
  final TextStyle? originalPriceStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('\$${product.price.toStringAsFixed(2)}', style: currentPriceStyle ?? context.textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
        if (product.hasDiscount) ...[
          SizedBox(width: 8.w),
          Text(
            '\$${product.originalPrice.toStringAsFixed(2)}',
            style:
                originalPriceStyle ?? context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, decoration: TextDecoration.lineThrough, decorationColor: colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
