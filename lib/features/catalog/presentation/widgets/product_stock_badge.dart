import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/product.dart';

class ProductStockBadge extends StatelessWidget {
  const ProductStockBadge({required this.product, super.key}) : _detailed = false;

  const ProductStockBadge.detailed({required this.product, super.key}) : _detailed = true;

  final Product product;
  final bool _detailed;

  @override
  Widget build(BuildContext context) {
    final scheme = context.theme.colorScheme;
    final (label, icon, background, foreground) = switch (product) {
      Product(isOutOfStock: true) => ('Out of stock', Icons.cancel_rounded, scheme.errorContainer, scheme.onErrorContainer),
      Product(stock: final stock) when stock <= 5 => ('Only $stock left', Icons.inventory_2_rounded, scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _ => ('In stock', Icons.check_circle_rounded, scheme.primaryContainer, scheme.onPrimaryContainer),
    };
    final style = _detailed ? context.textTheme.titleSmall : context.textTheme.labelSmall;
    final text = Text(label, style: style?.copyWith(color: foreground));

    return Container(
      padding: _detailed ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h) : EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999.r)),
      child: _detailed
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18.r, color: foreground),
                SizedBox(width: 7.w),
                text,
              ],
            )
          : text,
    );
  }
}
