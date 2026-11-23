import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/product.dart';

class ProductStockBadge extends StatelessWidget {
  const ProductStockBadge({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final visual = _resolveVisual(colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: visual.backgroundColor, borderRadius: BorderRadius.circular(999.r)),
      child: Text(visual.label, style: context.textTheme.labelSmall?.copyWith(color: visual.foregroundColor)),
    );
  }

  _StockVisual _resolveVisual(ColorScheme colorScheme) {
    if (product.isOutOfStock) {
      return _StockVisual(label: 'Out of stock', backgroundColor: colorScheme.errorContainer, foregroundColor: colorScheme.onErrorContainer);
    }
    if (product.stock <= 5) {
      return _StockVisual(label: 'Only ${product.stock} left', backgroundColor: colorScheme.tertiaryContainer, foregroundColor: colorScheme.onTertiaryContainer);
    }
    return _StockVisual(label: 'In stock', backgroundColor: colorScheme.secondaryContainer, foregroundColor: colorScheme.onSecondaryContainer);
  }
}

class _StockVisual {
  const _StockVisual({required this.label, required this.backgroundColor, required this.foregroundColor});

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
}
